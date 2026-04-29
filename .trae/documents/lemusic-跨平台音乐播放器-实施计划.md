# cn.lemwood.lemusic（LeMusic）跨平台音乐播放器实施计划

## Summary（目标概述）
构建一个跨平台音乐播放器 **cn.lemwood.lemusic**，首发支持 **Android + Windows/macOS**。MVP 具备 **统一搜索、统一播放、歌单（本地）** 三大能力，并通过“源插件化（Source Adapter）”接入：**QQ 音乐、酷狗、网易云音乐、番茄畅听**。严格遵循约束：**仅使用官方开放 API / SDK**；若某平台无法获得可用官方接口，则在产品能力上**明确降级**（例如仅跳转官方 App/网页）。

---

## Current State Analysis（现状与约束）
### 已知需求与决策（来自用户确认）
1. 平台：**Android + Windows/macOS**。
2. 接入方式：仅接受 **官方开放 API / SDK（推荐）**。
3. MVP 功能：**搜索 + 播放 + 歌单**。

### 外部可用性调研要点（Plan 阶段 Web 调研结论）
> 该部分只陈述“能从公开官方页面确认的事实”，并将不确定项设计为可插拔/可降级。

1. **QQ 音乐**：存在官方开发者平台 OpenAPI 文档；文档提到频控（默认 500 次/分钟）、签名校验、以及 **非中国大陆 IP 可能被拒绝访问**等约束；并提示“听歌流水上报”等合规要求（若使用 SDK 可能免处理）。  
   - 参考： https://developer.y.qq.com/docs/openapi
2. **酷狗**：存在官方“mini 酷狗（组件化播放器）”文档，支持 Android/iOS/H5/小程序；H5 侧通过官方 JS 初始化（appid + ticket），ticket 需服务端通过官方网关获取且有效期 2 小时，建议缓存。  
   - 参考：H5 接入 https://open.kugou.com/docs/mini-player/#/h5?v=3  
   - 参考：ticket 获取 https://open.kugou.com/docs/mini-player/#/ticket
3. **网易云音乐**：公开页可确认“开放平台入口存在”，但公开页无法直接确认可立刻接入的具体 API/SDK、申请门槛与返回播放链路规则（可能需要入驻/商务后获取完整文档）。  
   - 参考： https://music.163.com/st/developer
4. **番茄畅听**：未检索到可供第三方统一搜索/播放/歌单接入的公开官方 API/SDK 文档。  
   - 结论：MVP 必须做能力降级（external open / 跳转）。

### 关键约束总结
1. **合规/风控**：密钥、签名、票据等必须放在服务端；客户端不能直连含敏感鉴权信息的接口。
2. **能力不一致**：不同源的“播放形态”可能不同（直链播放 / WebView 官方组件 / 外部打开），需要统一抽象与清晰 UI 提示。
3. **地域限制**：QQ 音乐 OpenAPI 的地域限制要求 BFF 部署在合规地域（预计中国大陆）。

---

## Proposed Changes（方案与改动清单）

### 1) 总体架构：客户端 + BFF（后端聚合层）+ 源插件
**目标**：把“平台差异、鉴权差异、频控/缓存/审计”集中在 BFF，客户端只消费统一 API，并用统一播放器门面（Player Facade）编排多种播放执行器。

#### 1.1 客户端（Flutter）职责
- 统一 UI：搜索、播放页、歌单页、设置页（源启用/降级提示）。
- 统一领域模型（Track/Playlist/Playability）。
- `PlayerFacade` 维护队列与播放状态，并根据 `Playability` 选择执行器：
  - `DirectAudioEngine`：拿到可播放 URL 时用内置播放器播放。
  - `WebPlayerEngine`：酷狗 mini 酷狗等官方 H5 组件，用 WebView + JS bridge 控制。
  - `ExternalOpenEngine`：只能跳转官方 App/网页（番茄畅听、网易云未获资质时）。

#### 1.2 BFF（Backend For Frontend）职责
- 对客户端提供统一 REST API：搜索、曲目详情、解析播放、获取酷狗 ticket 等。
- 源插件实现：QQ/酷狗/网易云（预留）；番茄默认不在 BFF 聚合（仅 external open）。
- 通用能力：缓存（Redis）、限流、熔断、结构化日志、调用审计、错误码标准化。

> **技术选型（决策完成）**
> - 客户端：Flutter（Android + Windows + macOS 单代码库）
> - BFF：NestJS（Node.js）+ Redis（缓存/限流），理由：模块化与生态完善，便于做插件化源适配与中间件（限流/日志）。
>   - 若团队更熟 Kotlin，也可等价替换为 Ktor；但本计划以 NestJS 为唯一执行路径。

---

### 2) 领域模型与能力矩阵（必须先定，后续才可并行开发）
#### 2.1 统一数据模型（客户端与服务端共享一份 schema）
建议在仓库内建立 `packages/shared/`（或在 app 与 bff 复制同构定义，MVP 可先复制，后续再抽包）。

**Track（曲目）**
- `source`: `qqmusic | kugou | netease | fanqie`
- `trackId`: string（源内唯一 id，或 hash）
- `title`, `artists[]`, `album?`, `durationMs?`, `coverUrl?`
- `playability`: `direct_stream | embedded_web | external`（见下）

**Playability（可播放方式）**
- `DirectStream`：`url`, `headers?`, `expiresAt?`
- `EmbeddedWeb`：`provider`（kugou），`initPayload`（appid/ticket/track hash 等）
- `ExternalOpen`：`url`（deeplink 优先，fallback 为 https）

**Playlist（歌单，MVP：本地）**
- `playlistId`, `name`, `items: TrackRef[]`

#### 2.2 源能力（capabilities）固定 schema
定义 `capabilities` 用于“有则启用、无则降级”的自动编排：
- `search: boolean`
- `playbackMode: direct_stream | embedded_web | external`
- `playlist: local_only | remote_read | remote_write`
- `auth: none | oauth | sdk_managed`

并在产品内提供“源能力说明/提示”页面（避免用户困惑）。

---

### 3) 代码与目录结构（单仓库 Monorepo）
> 若当前仓库为空：按此结构初始化；若已有仓库：在不破坏现有结构前提下映射到同等模块。

#### 3.1 仓库结构（建议）
- `apps/lemusic_app/`（Flutter）
  - `lib/`
    - `core/`（网络、错误、日志、共享模型）
    - `features/search/`
    - `features/player/`
    - `features/playlist/`
    - `sources/`（客户端源适配：决定 UI 与播放执行器走向）
      - `source_api.dart`（capabilities + 接口）
      - `qqmusic_source.dart`（调用 BFF）
      - `kugou_source.dart`（调用 BFF 获取 ticket，并走 WebView 播放）
      - `netease_source.dart`（默认 external 或调用 BFF 预留接口）
      - `fanqie_source.dart`（external only）
    - `widgets/`
  - `android/`（包名 `cn.lemwood.lemusic`、后台播放/通知栏）
  - `windows/`, `macos/`
- `services/lemusic_bff/`（NestJS）
  - `src/`
    - `app.module.ts`
    - `http/`（controllers/dto）
    - `sources/`
      - `qqmusic/`（官方 OpenAPI 适配、签名、缓存、限流、合规流水预留）
      - `kugou/`（gw 换 ticket + 2h 缓存）
      - `netease/`（预留：拿到资质后实现）
    - `common/`（缓存、限流、错误码、日志中间件）
    - `config/`（env 校验、密钥加载）
- `docs/`
  - `capabilities.md`（源能力矩阵与降级规则）
  - `compliance.md`（频控、地域限制、流水上报、压测限制等清单）

---

### 4) BFF API 设计（对客户端稳定、对外部源可变）
#### 4.1 统一 API（最小集合）
1. `GET /v1/sources`  
   - 返回每个源的 `capabilities` 与“当前可用/降级原因”。
2. `GET /v1/search?q=...&sources=qqmusic,kugou,netease`  
   - 聚合搜索结果；对不参与聚合的源（fanqie）返回可选“跳转卡片”或在 `sources` 中直接标记不支持搜索。
3. `GET /v1/tracks/:source/:trackId`  
   - 返回 Track 详情与 `playability`（必要时包含短期凭证）。
4. `POST /v1/kugou/ticket`（或内部服务函数）  
   - 返回酷狗 `ticket`（2h 有效），BFF 负责缓存与续期。

#### 4.2 服务端通用中间件（必须实现）
- **缓存**：对搜索结果/详情做短缓存，降低外部调用频率。
- **限流**：对每个源独立限流，默认遵循 QQ OpenAPI 500 次/分钟等约束；并对单用户/单 IP 做保护。
- **审计日志**：记录源、接口、耗时、错误码、命中缓存、traceId（用于平台验收与问题排查）。

---

### 5) 客户端播放实现（多执行器并存）
#### 5.1 DirectAudioEngine（直链播放）
适用：当某源（例如 QQ 音乐在你的合作/权限下）能返回可播放 URL 且允许第三方播放器播放。
- Flutter 插件建议：
  - `just_audio`（播放）
  - `audio_service`（Android 后台、通知栏、耳机线控）
- 注意：部分源可能要求 DRM/加密/专用 SDK；若遇到则回退到 `embedded_web` 或 `external`。

#### 5.2 WebPlayerEngine（WebView 官方组件播放：酷狗 mini 酷狗）
适用：酷狗官方 mini 酷狗 H5 组件。
实现要点：
1. 客户端向 BFF 请求 `ticket`（短期票据，BFF 缓存 2 小时）。  
2. WebView 加载官方脚本与页面，按官方文档初始化 `appid + ticket`，并通过 JS bridge 执行播放/暂停/切歌、监听事件同步状态。  
3. 统一把 WebView 播放状态映射到 `PlayerFacade` 的状态机（playing/buffering/error 等）。

#### 5.3 ExternalOpenEngine（外部打开/跳转）
适用：番茄畅听（MVP）、网易云（未获资质前）、以及任何不允许直链/内嵌的播放场景。
- Android：优先 deeplink（若官方公开支持），否则 https。
- Desktop：用系统默认浏览器打开。
- 产品提示：在播放按钮旁标注“将跳转至官方应用/网页”。

---

## Assumptions & Decisions（假设与关键决策）
1. **允许引入自建 BFF**：因为官方接口普遍涉及签名/密钥/频控/审计，客户端直连不可取。
2. **MVP 歌单为本地歌单**：跨源“远端歌单同步/写入”需要用户授权与平台权限，风险与工期显著更高，放在下一阶段。
3. **网易云/番茄按降级处理**：在未获取明确“官方可接入 API/SDK 与播放链路”前，不阻塞 MVP；UI 上必须清晰标注降级原因。
4. **部署地域**：BFF 需部署在满足 QQ 音乐 OpenAPI 访问要求的地域（预计中国大陆），并配置可观测性用于验收与排障。
5. **包名**：Android applicationId 固定为 `cn.lemwood.lemusic`。

---

## Verification（验证与验收步骤）
### A. 合规与接入验证（逐源）
1. QQ 音乐
   - 申请 appid 与所需权限；在 BFF 实现签名、缓存、限流与错误映射。
   - 验证在目标部署地域可稳定访问；验证频控触发时系统能降级与提示（不崩溃）。
2. 酷狗
   - 在 BFF 打通 `ticket` 获取并缓存（2 小时有效）。
   - 在客户端 WebView 完成初始化与播放控制；验证播放状态能回传并驱动统一 UI。
3. 网易云
   - 验证开放平台申请流程能否获取技术文档/沙箱；若未获得，确认 external 跳转链路在三端可用。
4. 番茄畅听
   - 验证 external 打开策略（deeplink/网页）在 Android 与 Desktop 可用，并在 UI 中明确提示“外部播放”。

### B. MVP 产品验收（跨源统一体验）
1. 统一搜索：同一关键词返回分源结果；每条结果标注来源与可播放方式（直播/WebView/跳转）。
2. 统一播放：队列可混合不同来源 Track；切歌时能正确选择执行器并保持播放状态一致。
3. 本地歌单：创建/编辑/删除、添加跨源歌曲、从歌单一键播放队列；重启应用后数据可恢复。
4. 稳定性：断网/频控/接口异常时有可理解的错误提示与重试策略；BFF 日志能定位问题。


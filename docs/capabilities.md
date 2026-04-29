# 源能力矩阵（capabilities）

> 约束：仅允许官方开放 API / SDK；无法满足时必须明确降级（不做逆向/第三方接口）。

| 来源 | 搜索 | 播放方式（MVP） | 歌单（MVP） | 当前状态 | 降级/备注 |
|---|---:|---|---|---|---|
| QQ 音乐 | ✅（计划） | external（默认） | 本地歌单 | **stub** | 需接入 QQ 音乐官方 OpenAPI：签名/鉴权/频控/缓存；可能需要听歌流水上报与验收；非中国大陆 IP 可能被拒 |
| 酷狗 | ✅（计划） | embedded_web（mini 酷狗 H5） | 本地歌单 | **stub** | 需开通酷狗开放平台并实现 ticket 获取（2h 有效期，服务端缓存）；客户端 WebView + JS bridge 控制 |
| 网易云 | ❌（MVP） | external | 本地歌单 | **降级** | 公开页可确认开放平台入口存在，但未获得可立即接入的 API/SDK 与播放链路授权，拿到资质后再升级 |
| 番茄畅听 | ❌（MVP） | external | 本地歌单 | **降级** | 未发现可用官方开放 API/SDK（MVP 仅外部跳转） |

## 统一 Playability 映射
- `direct_stream`：可拿到可播放 URL（需平台官方允许）
- `embedded_web`：官方 Web 组件/SDK（例：酷狗 mini-player H5）
- `external`：系统浏览器/唤起官方 App（deeplink 优先）


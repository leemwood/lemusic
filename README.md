# LeMusic（cn.lemwood.lemusic）

跨平台音乐播放器（Android + Windows/macOS），MVP：统一搜索、统一播放、歌单（本地），以“源插件化”方式接入 QQ 音乐、酷狗、网易云、番茄畅听；严格仅使用官方开放 API/SDK，无法接入时降级为外部跳转。

## 目录
- `apps/lemusic_app/`：Flutter 客户端
- `services/lemusic_bff/`：NestJS BFF（统一 API、缓存/限流、源适配）
- `docs/`：能力矩阵与合规说明

## 文档
- 实施计划：见 `.trae/documents/lemusic-跨平台音乐播放器-实施计划.md`

## 本地运行（BFF）
```bash
cd services/lemusic_bff
npm install
npm run start:dev
```

验证接口：
```bash
curl http://localhost:3000/v1/sources
curl "http://localhost:3000/v1/search?q=周杰伦"
curl http://localhost:3000/v1/tracks/qqmusic/qq_stub_1
```

# lemusic_app（Flutter 客户端）

本目录已放入 `lib/` 与 `pubspec.yaml` 的 MVP 骨架代码。

由于当前环境未内置 Flutter SDK，未执行 `flutter create` 自动生成三端工程壳（`android/ windows/ macos/` 等）。在你的开发机上建议：

1. 进入本目录，初始化工程壳（如果还没有）：
   - `flutter create . --org cn.lemwood --project-name lemusic`
2. 确认 `android/app/build.gradle` 中的 `applicationId` 为 `cn.lemwood.lemusic`
3. 安装依赖并运行：
   - `flutter pub get`
   - `flutter run -d android`

开发期默认 BFF 地址为 `http://localhost:3000`（见 `lib/sources/bff_client.dart`），真机调试需替换为局域网 IP。


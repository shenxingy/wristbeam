# Wristbeam

小小动作，触及更多设备。

[English](README.md) · [路线图](ROADMAP.md) · [参与贡献](CONTRIBUTING.md) · [社区讨论](https://github.com/shenxingy/wristbeam/discussions)

Wristbeam 是一个逐步探索“从手腕控制自己的设备”的 MIT 开源项目。
名字来自 **wrist（手腕）+ beam（光束）**：让一个小动作，触及正在使用的屏幕。

第一步从床边阅读开始：iPhone 里打开网页，Apple Watch 转表冠滚动，
或点上下箭头翻一屏。当前原型只需要手机和手表，不需要额外硬件、服务器或账号。
电脑、不同操作系统、浏览器和播放器是后续拓展方向，目前还没有实现。

**当前状态：代码原型，尚未验证原生 App 构建及真机运行。** 网页滚动模块已通过
Chromium 测试；开发环境是 Linux，没有 Xcode 和配对设备。没有安装包或 TestFlight
版本，不能把浏览器测试通过理解为手表联动已跑通。

## 一点一点拓展

1. **先做好阅读**：编译安装、真机翻页、断线恢复、垂腕后继续操作。
2. **再连接一台电脑**：先验证 Mac 上的 Chrome，明确配对设备和受控标签页。
3. **逐步支持更多系统**：Windows、Linux 分别安装和测试，验证后才标为支持。
4. **探索 Safari 和播放器**：Safari 桌面版与 iOS 版分别实验；播放器先从自己
   可控的播放界面开始，再接入公开 API。
5. **为其他设备留入口**：有真实使用者和维护者，再增加新的手表或输入设备。

详细完成条件见 [ROADMAP.md](ROADMAP.md)，参与方式见 [社区计划](docs/community.md)。
没有承诺发布日期，也不把未来苹果开放更多权限作为前提；系统能力变化时，再增加适配。

## 第一版做什么

- 自带网页阅读器，打开 HTTPS 网站；首次启动有一篇离线示例文章。
- 表冠小幅滚动；箭头每次翻 85% 屏高，保留上下文。
- 显示连接、加载、断线、超时及页面边界状态。
- 可选择让 iPhone 阅读期间保持屏幕常亮。
- 中英文界面，跟随系统外观。

只控制这个阅读器里的网页，不控制 Safari、微信、Kindle 等其他 App。
Safari 扩展可以作为后续方向。第一版不含自动滚动和自定义手势识别，
**不承诺手表熄屏、垂腕后仍能持续操作**。复杂嵌套页面也需要兼容性测试。

## 在 Mac 上安装开发版

需要完整 Xcode 16 或更新版本、iOS/watchOS SDK、XcodeGen 2.44+，以及配对的
iPhone（iOS 17+）和 Apple Watch（watchOS 10+）。具体版本组合尚待验证。

```bash
brew install xcodegen
cp Config/Local.xcconfig.example Config/Local.xcconfig
```

在 `Config/Local.xcconfig` 填入自己的签名 Team ID 和唯一的 Bundle ID 前缀。
这个文件不会提交到 Git。手机与手表的标识会一起更新。然后：

```bash
xcodegen generate
open Wristbeam.xcodeproj
```

1. 在 Xcode 设置 Apple 账号，按设备提示配置签名、信任及开发者模式。
2. 选择 `Wristbeam` scheme，在 iPhone 上运行。
3. 选择 `WristbeamWatch` scheme，在配对的手表上运行。
4. 手机保持显示阅读器，手表打开遥控界面；看到“可以翻页了”后试读示例。
5. 再从手机和手表主屏直接启动，脱离 Xcode 调试器验证垂腕、休眠和重连。

这里不需要把手表配对成鼠标，也不需要给 App 开启系统辅助功能控制权限。

## 如何参与

欢迎用中文或英文发 [Issue](https://github.com/shenxingy/wristbeam/issues/new/choose)
和 [Discussion](https://github.com/shenxingy/wristbeam/discussions)。不写代码也可以贡献。
目前最需要的是真机证据：能否编译安装、连续翻页是否顺畅、停一会儿后怎样恢复、
在你常读的网站上有没有问题。报告中请写设备型号、系统版本，以及是否连接调试器。
测试命令见 [英文 README](README.md#checks)。

开源许可证见 [LICENSE](LICENSE)。

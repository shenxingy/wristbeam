# WristScroll

手机架着读，手表控制翻页。

[English](README.md) · [真机验证清单](docs/validation.md)

这是一个 MIT 开源原型：iPhone 里打开网页，Apple Watch 转表冠滚动，
或点上下箭头翻一屏。运行时只需要手机和手表，不需要额外硬件、服务器或账号。

**当前状态：代码原型，尚未验证原生 App 构建及真机运行。** 网页滚动模块已通过
Chromium 测试；开发环境是 Linux，没有 Xcode 和配对设备。没有安装包或 TestFlight
版本，不能把浏览器测试通过理解为手表联动已跑通。

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
open WristScroll.xcodeproj
```

1. 在 Xcode 设置 Apple 账号，按设备提示配置签名、信任及开发者模式。
2. 选择 `WristScroll` scheme，在 iPhone 上运行。
3. 选择 `WristScrollWatch` scheme，在配对的手表上运行。
4. 手机保持显示阅读器，手表打开遥控界面；看到“可以翻页了”后试读示例。
5. 再从手机和手表主屏直接启动，脱离 Xcode 调试器验证垂腕、休眠和重连。

这里不需要把手表配对成鼠标，也不需要给 App 开启系统辅助功能控制权限。

## 如何参与

目前最需要的是真机证据：能否编译安装、连续翻页是否顺畅、停一会儿后怎样恢复、
在你常读的网站上有没有问题。报告中请写设备型号、系统版本，以及是否连接调试器。
测试命令见 [英文 README](README.md#checks)。

开源许可证见 [LICENSE](LICENSE)。

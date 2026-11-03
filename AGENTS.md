# 仓库代理指南

## 适用范围与规则来源

- 本文件适用于整个仓库，供智能编码代理开发、审查和验证时使用。
- 项目为 Objective-C iOS 富文本框架 YYText，不是 Web 或 uni-app 项目。
- 本次检查未发现已有 AGENTS.md、CLAUDE.md、.cursorrules、
  .cursor/rules/ 或 .github/copilot-instructions.md，无额外规则需要合并。
- 如后续添加目录级规则，修改该目录前先读取，并保留本文件的通用约束。
- 事实依据优先采用源码、工程文件和 podspec；README 中部分要求属于历史说明。

## 项目结构

- `YYText/`：实际发布的框架源码，仅包含 Objective-C `.h` 和 `.m`。
- `YYText/YYText.h`：聚合头，支持 framework 导入及直接集成源码两种方式。
- `YYText/YYLabel.{h,m}`：富文本展示、交互高亮及异步显示入口。
- `YYText/YYTextView.{h,m}`：富文本编辑、输入、选区和撤销重做入口。
- `YYText/Component/`：布局、行信息、输入模型及内部 UI 组件。
- `YYTextLayout`、`YYTextLine`：CoreText 排版结果、绘制及几何查询。
- `YYTextInput`：文本位置、范围等输入模型；`YYTextDebugOption`：调试显示。
- 同目录包含键盘管理、选区、放大镜、效果窗口及容器视图。
- `YYText/String/`：文本属性模型、Markdown/表情解析、归档、RunDelegate、Ruby 注音。
- `YYText/Utility/`：富文本、段落、剪贴板、UIView 分类和底层工具。
- 同目录包含异步绘制层、弱引用代理、RunLoop 事务等实现。
- `Framework/YYText.xcodeproj`：框架工程，包含 `YYText` 和 `YYTextTests` target，共享 scheme 为 `YYText`。
- `Framework/YYTextTests/`：框架的 XCTest 测试源码。
- `Framework/Info.plist`：框架元数据；Framework 目录不是另一份源码。
- `Demo/YYTextDemo.xcodeproj`：演示应用工程，应用目标为 `YYTextDemo`。
- `Demo/YYTextDemo/`：AppDelegate、单窗口 SceneDelegate、入口控制器和 `YYText*Example.{h,m}` 示例。
- 示例覆盖属性、附件、异步显示、编辑、表情、Markdown、复制粘贴、撤销等。
- `Demo/YYTextDemo/YYImage/` 及 `*+YYAdd` 等：随示例内置的支持代码。
- `Demo/YYTextDemo/Assets.xcassets/`：应用图片资源。
- `Demo/YYTextDemo/Base.lproj/`：LaunchScreen.storyboard；`EmoticonQQ.bundle/`：表情资源。
- `Demo/YYTextDemo/` 下另有 PNG 和 Info.plist 等应用资源。
- `Demo/DemoSnapshot/`：README 展示用截图或动图，不是自动化快照测试。
- `Attributes/`：属性效果图片、架构图及 PDF 文档，不是运行时框架资源。
- `README.md`：中英文使用、集成及示例说明；`LICENSE`：MIT 许可。
- `YYText.podspec`：CocoaPods 发布配置；`.travis.yml`：历史 CI 构建配置。
- Demo 不是自动化测试套件。

## 环境与兼容性

- 编译需要 macOS、完整 Xcode 和 iOS SDK；只有 Command Line Tools 不够。
- Objective-C 使用 ARC，工程的 C 语言标准为 `gnu11`。
- podspec、Demo 和 Framework 的最低部署目标统一为 iOS 15.0。
- 集成应用必须使用 UIScene 窗口生命周期；窗口特效和键盘管理不再兼容传统全局窗口路径。
- 本机验证工具链为 Xcode 26.6 / iOS 26.5；iOS 15 实际运行需另行验证，Xcode 8 CI 仅供历史参考。
- 不为消除 SDK 警告而擅自提高最低版本、修改签名或批量升级工程。
- 仓库未提供 Podfile；直接构建已有工程不需要先运行 `pod install`。
- CocoaPods 发布 `YYText/**/*.{h,m}`，并将其下所有 `.h` 声明为公开头文件。
- 新增头文件时必须考虑公开 API 暴露，不要假定放在子目录就是私有头。

## 构建命令

以下命令均从仓库根目录执行，要求本机已选择有效的 Xcode。
它们依据现有工程配置整理，不代表在每个 SDK 上均已验证通过。

```sh
# 查看工具链、SDK 和工程目标
xcodebuild -version
xcodebuild -showsdks
xcodebuild -list -project Framework/YYText.xcodeproj
xcodebuild -list -project Demo/YYTextDemo.xcodeproj

# 历史 CI 的核心构建命令，不依赖 xcpretty
xcodebuild clean build -project Framework/YYText.xcodeproj -scheme YYText

# 模拟器框架构建，避免真机签名要求
xcodebuild build -project Framework/YYText.xcodeproj -scheme YYText \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO

# Demo 没有提交共享 scheme，使用明确的 target 构建
xcodebuild build -project Demo/YYTextDemo.xcodeproj -target YYTextDemo \
  -configuration Debug -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO
```

- 日常增量验证使用 `build`；需要排除缓存问题时再使用 `clean build`。
- 修改公共代码后优先构建 Framework；涉及交互、资源或示例时也构建 Demo。
- 运行演示：在 Xcode 打开 Demo 工程，选择 `YYTextDemo` 和可用模拟器后运行。
- Demo 由 SceneDelegate 程序化创建窗口，根控制器为现有 ViewController 导航类，不使用 Main.storyboard。
- 现代 SDK 可能暴露旧 API 或部署目标兼容问题，应记录具体报错再处理。

## Lint 与静态检查

- 仓库未配置专用 lint、clang-format 或统一格式化脚本，不要虚构对应命令。
- 可用 Clang 静态分析补充检查，但它不是风格 lint 或单元测试：

```sh
xcodebuild analyze -project Framework/YYText.xcodeproj -scheme YYText \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
git diff --check
```

- 修改 podspec 时可在安装 CocoaPods 后执行 `pod lib lint YYText.podspec`。
- `pod lib lint` 是额外的本地集成校验，需要相应工具链，可能需要联网；不是现有 CI 步骤。

## 测试与单个用例

- `Framework/YYTextTests/YYTextTests.m` 包含 `YYTextTests` XCTest 类；共享 `YYText` scheme 的 Test action 包含 `YYTextTests` target。
- 修复问题时使用对应 `YYText*Example` 手工复现，记录设备、系统、步骤和结果。
- 编辑相关至少关注选区、中文组合输入、键盘切换、复制粘贴及撤销重做。
- 布局和绘制相关关注空文本、零尺寸、截断、竖排、附件及同步/异步一致性。
- 归档相关关注序列化往返、已有数据兼容性和无效输入。
- 使用可用模拟器运行完整套件或单个测试方法，将 `<模拟器UDID>` 替换为实际值：

```sh
xcodebuild test -project Framework/YYText.xcodeproj -scheme YYText \
  -destination 'platform=iOS Simulator,id=<模拟器UDID>' \
  CODE_SIGNING_ALLOWED=NO

xcodebuild test -project Framework/YYText.xcodeproj -scheme YYText \
  -destination 'platform=iOS Simulator,id=<模拟器UDID>' \
  -only-testing:YYTextTests/YYTextTests/testAttributedStringArchiveRoundTrip \
  CODE_SIGNING_ALLOWED=NO
```

- 运行其他单个测试方法时替换方法名；仅运行某个测试类时省略最后的 `/测试方法`。
- 可用 `xcrun simctl list devices available` 查询本机可用的模拟器 UDID。
- 无法执行构建或测试时明确说明原因，不将静态阅读或手工验证描述为测试通过。

## 代码风格与 API

- 遵循相邻代码：通常四空格缩进、左花括号同行、对象指针写作 `Type *name`。
- 不进行全文件格式化、无关空白清理或批量重排 imports。
- `.m` 通常先导入自身头文件；本地头使用 `#import "..."`，系统头使用 `<...>`。
- 保留公开头的 `__has_include(<YYText/YYText.h>)` 双路径导入模式。
- 头文件只引入必要依赖；可行时使用 `@class`、`@protocol` 前向声明。
- 类名和公共符号沿用 `YYText`/`YY` 前缀；分类文件命名为 `Type+YYText`。
- 分类方法和属性沿用 `yy_` 前缀，方法、属性及局部变量使用 lowerCamelCase。
- 私有实例变量沿用 `_name`；局部辅助函数优先 `static`，避免新增全局符号。
- 尺寸用 `CGFloat`，索引用 `NSUInteger`/`NSInteger`，布尔用 `BOOL`，范围用 `NSRange`。
- 构造方法优先 `instancetype`；枚举与选项沿用 `NS_ENUM`、`NS_OPTIONS`。
- 保持既有 `NS_ASSUME_NONNULL_BEGIN/END`、`nullable` 和轻量泛型约定。
- 属性所有权要明确：对象按语义使用 strong/weak/copy，block 使用 copy。
- 保留 `#pragma mark` 分区、许可证头和公开 API 的文档注释。
- 修改 API 时同步更新头文件说明及相关示例，避免无需求的签名、默认值变更。

## 错误处理、内存与并发

- 沿用现有方法的失败约定，如 `nil`、`NO` 或提前返回；不能一律改成抛异常。
- 验证空输入、`NSNotFound`、范围越界及无效绘制尺寸，避免整数溢出或错误范围运算。
- 断言用于开发期不变量，不能替代对外部输入的必要校验。
- ARC 不管理所有 Core Foundation 对象；检查 Create/Copy 与 Release 是否配对。
- 审查 `__bridge`、`__bridge_retained` 和所有权转移，覆盖失败与取消路径的释放。
- 遵守头文件的线程约定：布局计算可在允许的后台路径运行，UIKit 更新回主线程。
- 异步绘制修改必须保留取消检查、结果提交及完成回调的语义，避免过期结果覆盖。
- block、代理、定时器与通知应检查循环引用和生命周期，复用现有弱引用代理工具。
- 使用新系统 API 时核对可用性；不要顺带删除已有兼容处理或更换整套绘制实现。

## 协作与交付

- 开始修改前查看 `git status` 和相关 diff，保留用户已有修改，不回退无关工作。
- 减少不必要的行为变化；修复和适配应保持原代码的用途、逻辑含义及未涉及的既有行为。
- 不扩大任务范围，不顺带修改旧实现。确需改动任务范围外的旧实现时，先说明具体问题、严重程度和影响并询问用户；只有问题很严重且必须立即处理时才例外，并明确记录原因与改动。
- 改动局限于任务范围，默认不修改 Demo 内置依赖、发布版本或全局工程设置。
- 新增源码时检查两个工程的文件引用、Sources/Headers 阶段和所需的聚合头导出。
- 新增资源时检查 Demo 的 Resources 阶段；podspec 当前没有配置资源打包。
- 不提交 build、DerivedData、xcuserdata、签名凭据或本机路径，不擅自提交或推送。
- 交付说明列出实际变更、实际执行的验证及未验证项；新增测试入口后更新本文。

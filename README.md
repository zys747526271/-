随机视频展示墙
这是一个轻量级的本地网页应用，用于创建一个动态、随机且美观的视频展示墙。它能够扫描指定文件夹内的视频文件，并在一个可交互的网页上展示它们。

✨ 功能特性

随机视频布局：每次刷新页面，都会从视频列表中随机选取一部分进行展示，并且每个视频的尺寸都会随机缩放，创造出一种错落有致的视觉效果。 


响应式设计：网页会根据浏览器窗口的大小动态调整显示的视频数量，无需刷新页面。 


沉浸式播放：单击任意视频即可进入全屏播放模式，再次单击即可退出。 


便捷导航：通过页面左右两侧的箭头按钮，可以轻松地翻页浏览更多的视频。 


即时信息：鼠标悬停在视频上时，会显示该视频的文件名。 


自动播放：所有显示的视频都会自动静音循环播放，营造出动态的背景墙效果。 


高度可定制：可以轻松修改背景样式，打造个性化的展示效果。 

自动化列表生成：提供一个 PowerShell 脚本，可以自动扫描视频文件夹并生成所需的 videoList.js 文件。

📁 文件结构
.
├── 📂 video/                # 存放你的所有视频文件
│   ├── video1.mp4
│   ├── video2.mp4
│   └── ...
├── 📜 index.html            # 网页的主体结构
├── 📜 style.css             # 控制网页的样式和外观
├── 📜 script.js             # 实现所有交互功能的 JavaScript 代码
├── 📜 videoList.js          # 由脚本生成的视频文件列表
└── 📜 GenerateVideoList.ps1 # 用于自动生成 videoList.js 的 PowerShell 脚本
🚀 使用指南
步骤 1: 准备视频文件
将你想要展示的所有视频文件（如 

.mp4, .webm 等）放入 video 文件夹中。 

步骤 2: 生成视频列表 (videoList.js)

videoList.js 文件是本项目的核心，它告诉网页要去加载哪些视频。  你可以选择手动创建这个文件，但我们强烈推荐使用提供的 PowerShell 脚本来自动完成。

使用 GenerateVideoList.ps1 脚本 (推荐):

定位脚本: 找到 GenerateVideoList.ps1 文件。

运行脚本:

方法一 (最简单): 如果你的视频文件都放在了与 index.html 同级的 video 文件夹中，只需右键单击 GenerateVideoList.ps1 文件，然后选择 "使用 PowerShell 运行"。

方法二 (指定路径): 打开 PowerShell 终端，导航到项目根目录，然后运行以下命令。这会自动扫描 video 文件夹。

PowerShell

.\GenerateVideoList.ps1 -TargetFolder ".\video\"
完成: 脚本执行后，会自动在项目根目录下创建或更新 videoList.js 文件，其中包含了 video 文件夹下所有视频文件的相对路径。

手动创建:

如果你想手动创建，可以新建一个名为 videoList.js 的文件，并按照以下格式添加你的视频文件名：

JavaScript

const videoList = [
    "20874872.gif.mp4",
    "21136825.gif.mp4",
    "79yfszfy6ex61.mp4",
    // ... 添加更多视频文件名
];
步骤 3: 浏览网页
在浏览器中直接打开 

index.html 文件即可开始体验。所有视频将开始自动播放。 

🎨 自定义
修改背景
如果你想更换网页背景，可以很方便地通过修改 CSS 文件来实现。

打开 style.css 文件。

找到最顶部的 :root 选择器部分。

修改 --background-style 变量的值。

例如，更换为一个深蓝色的渐变背景：

CSS

:root {
    /* 在这里修改背景 */
    --background-style: radial-gradient(circle, #2c3e50, #1a252f);
}
你可以使用任何有效的 CSS 背景样式，例如纯色 (

#333) 或图片 (url('path/to/your/image.jpg'))。 

📝 注意事项
由于浏览器安全策略的限制，本项目需要在本地以文件形式 (file:///...) 打开 index.html，而不是通过 Web 服务器（http://localhost）。

视频文件的数量和大小可能会影响页面的加载性能。

GenerateVideoList.ps1 脚本会递归扫描指定文件夹及其所有子文件夹。

请确保在运行 PowerShell 脚本时，您的系统允许执行本地脚本。如果遇到问题，您可能需要以管理员身份运行 PowerShell 并执行 Set-ExecutionPolicy RemoteSigned 命令。
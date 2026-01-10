# Talk With AI - 项目使用与上传指南 🚀

你好！恭喜你完成了 App 的代码编写。这份指南是专门为你准备的，它将教你如何生成 App 图标，以及如何把项目上传到 GitHub。

## 第一步：生成 App 图标 🎨

因为之前的自动命令没跑通，你需要确保你的电脑上安装了 Flutter 环境。

1.  **打开终端（命令行）**：
    在你的项目文件夹 `glass_ai_chat` 下打开终端。

2.  **运行生成命令**：
    复制下面的命令并回车：
    ```bash
    flutter pub get
    flutter pub run flutter_launcher_icons
    ```
    *如果提示“flutter 不是内部或外部命令”，说明你需要先安装 Flutter SDK 并配置环境变量。*

## 第二步：上传到 GitHub ☁️

这是把你的代码从“本地”搬家到“云端”的关键一步。

1.  **创建远程仓库**：
    -   登录 [GitHub](https://github.com)。
    -   点击右上角的 **+** -> **New repository**。
    -   Repository name 输入：`talk-with-ai`。
    -   点击 **Create repository**。

2.  **推送代码**：
    回到你的项目终端，依次执行以下三行命令（记得把 `<你的GitHub用户名>` 换成你真实的用户名）：

    ```bash
    # 1. 关联远程仓库
    git remote add origin https://github.com/<你的GitHub用户名>/talk-with-ai.git

    # 2. 确保分支名为 main
    git branch -M main

    # 3. 推送代码（这一步可能需要你输入 GitHub 账号密码或 Token）
    git push -u origin main
    ```

3.  **成功！**
    刷新 GitHub 页面，你应该就能看到你的代码啦！

## 第三步：自动打包 APK (云端打包) 📦

不需要在你电脑上安装任何环境，我已经为你配置了 GitHub Actions。

1.  **提交配置**：
    确保你已经把 `.github/workflows/android_build.yml` 文件推送到了 GitHub。
    ```bash
    git add .
    git commit -m "Enable auto build"
    git push
    ```

2.  **等待打包**：
    -   打开 GitHub 仓库页面，点击上方的 **Actions** 标签。
    -   你会看到一个正在运行的任务。等待它变成绿色（约 5-10 分钟）。

3.  **下载**：
    -   点进那个绿色的任务。
    -   在页面最底部 **Artifacts** 区域，点击 **app-release** 下载。
    -   解压后发送到手机安装即可！

## 关于 App 功能 ✨

-   **AI 对话**：支持 OpenAI 和 Gemini 模型。
-   **玻璃拟态 UI**：超好看的透明磨砂效果。
-   **自定义设置**：可以改 API Key、换背景、调字体。

祝你编程愉快！如果有问题，随时回来问我。

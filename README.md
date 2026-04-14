# OpenGet - 智能提示词优化工具

<div align="center">

![OpenGet Logo](https://img.shields.io/badge/OpenGet-Prompt%20Optimizer-blue?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?style=for-the-badge&logo=flutter)
![Build Status](https://img.shields.io/github/actions/workflow/status/xiaoxuan0820-ctrl/openget/flutter-ci.yml?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**一款智能提示词优化工具，帮助你将自然语言转换为更精准、专业的AI指令。**

[功能介绍](#功能介绍) • [快速开始](#快速开始) • [构建指南](#构建指南) • [技术栈](#技术栈)

</div>

---

## 📱 功能介绍

### 核心功能

| 功能 | 描述 |
|------|------|
| **结构化拆解** | 将模糊想法拆解为目标、背景、要求、输出格式等清晰模块 |
| **专业术语转换** | 将口语化表达转换为专业、规范的AI可理解语言 |
| **一键复制** | 优化结果支持一键复制，方便快捷 |

### 界面预览

- 🎨 简洁工具型设计，清爽好用
- 🔵 蓝白色系主色调，专业高效
- 📱 跨平台支持 (iOS & Android)

---

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.24.0+
- Dart 3.5.0+
- iOS 12.0+ / Android API 21+

### 本地运行

```bash
# 克隆项目
git clone https://github.com/YOUR_USERNAME/openget.git
cd openget

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 构建 APK

```bash
flutter build apk --debug
```

### 构建 iOS (macOS)

```bash
flutter build ios --simulator --no-codesign
```

---

## 🔨 构建指南

### GitHub Actions (推荐)

项目已配置 GitHub Actions，每次 push 到 main 分支会自动构建：

| 平台 | 构建类型 | 触发条件 |
|------|----------|----------|
| Android | Debug APK | push/PR |
| iOS | Simulator | push/PR |
| Android | Release AAB | push to main |

**Android Release 构建需要配置以下 Secrets：**
- `KEYSTORE_FILE`: keystore 文件 (Base64)
- `KEYSTORE_PASSWORD`: keystore 密码
- `KEY_ALIAS`: key 别名
- `KEY_PASSWORD`: key 密码

### Codemagic (备选方案)

1. 访问 [Codemagic](https://codemagic.io)
2. 连接 GitHub 仓库
3. 使用项目根目录的 `codemagic.yaml` 配置
4. 开始构建

**免费额度：**
- 每月 500 分钟构建时间
- 支持 iOS & Android

### 手动构建

#### Android

```bash
# Debug
flutter build apk --debug

# Release (需要签名)
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

#### iOS (需要 macOS)

```bash
# Simulator
flutter build ios --simulator --no-codesign

# Device (需要签名)
flutter build ios --release
```

---

## 🛠 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.24.0 |
| 语言 | Dart 3.5.0 |
| AI 能力 | 智谱 AI GLM-4-Flash |
| 状态管理 | Provider |
| HTTP 客户端 | http |

---

## 📁 项目结构

```
OpenGet/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── core/
│   │   ├── theme.dart            # 主题配置
│   │   └── constants.dart        # 常量定义
│   ├── models/
│   │   └── prompt_result.dart    # 数据模型
│   ├── services/
│   │   └── glm_service.dart      # GLM API 服务
│   ├── prompts/
│   │   └── system_prompts.dart   # System Prompt 模板
│   ├── pages/
│   │   └── home_page.dart        # 主页面
│   └── widgets/
│       ├── input_section.dart    # 输入区域组件
│       └── result_section.dart   # 结果展示组件
├── config/
│   └── api_config.dart          # API 配置
├── docs/
│   └── README.md                # 项目文档
├── .github/
│   └── workflows/
│       └── flutter-ci.yml       # GitHub Actions 配置
├── codemagic.yaml               # Codemagic 配置
└── pubspec.yaml                 # Flutter 依赖配置
```

---

## 🔧 API 配置

项目使用智谱 AI GLM-4-Flash 模型。

**配置文件：** `lib/services/glm_service.dart`

```dart
class _ApiConfig {
  static const String apiKey = 'YOUR_API_KEY';
  static const String endpoint = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String model = 'glm-4-flash';
}
```

> ⚠️ 请替换为您自己的 API Key，建议通过环境变量配置。

---

## 📄 许可证

本项目基于 MIT 许可证开源。

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

<div align="center">

**Made with ❤️ using Flutter**

</div>

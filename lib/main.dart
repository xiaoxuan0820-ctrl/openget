/// OpenGet - 提示词优化工具
/// 应用入口文件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========== 全局错误捕获（用于排查闪退问题）==========
  
  // 捕获Flutter框架级错误
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔥 Flutter Error: ${details.exceptionAsString()}');
    debugPrint('StackTrace: ${details.stack}');
    FlutterError.presentError(details);
  };
  
  // ========== 系统UI配置 ==========
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 锁定竖屏方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  debugPrint('🚀 OpenGet 启动中...');
  
  runApp(const OpenGetApp());
  
  debugPrint('✅ OpenGet 初始化完成');
}

/// OpenGet 应用主类
class OpenGetApp extends StatelessWidget {
  const OpenGetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

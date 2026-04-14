/// OpenGet - 提示词优化工具
/// 应用入口文件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========== 全局错误捕获（用于排查闪退问题）==========
  
  // 捕获Flutter框架级错误
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔥 Flutter Error: ${details.exceptionAsString()}');
    debugPrint('StackTrace: ${details.stack}');
    
    // 如果是发布模式，记录错误但不崩溃
    FlutterError.presentError(details);
  };
  
  // 捕获未被捕获的异步错误
  PlatformDispatcher.instance.onError = (Object error, StackTrace? stackTrace) {
    debugPrint('🔥 Platform Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
    return true; // 返回true表示已处理，不会崩溃
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
      title: 'OpenGet',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      home: const _HomePageWrapper(),
    );
  }
  
  ThemeData _buildLightTheme() {
    const Color primaryColor = Color(0xFF2196F3);
    const Color backgroundColor = Color(0xFFFAFAFA);
    const Color surfaceColor = Color(0xFFFFFFFF);
    const Color textPrimary = Color(0xFF212121);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: const Color(0xFF64B5F6),
        surface: surfaceColor,
        error: const Color(0xFFF44336),
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// 首页包装器 - 添加错误边界
class _HomePageWrapper extends StatefulWidget {
  const _HomePageWrapper();

  @override
  State<_HomePageWrapper> createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<_HomePageWrapper> {
  @override
  void initState() {
    super.initState();
    debugPrint('📱 HomePageWrapper 初始化');
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: const _HomePageContent(),
    );
  }
}

/// 错误边界组件
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  
  const ErrorBoundary({required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? _errorMessage;
  StackTrace? _stackTrace;
  
  @override
  void initState() {
    super.initState();
    debugPrint('🛡️ ErrorBoundary 初始化');
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  '应用出错',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return widget.child;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    debugPrint('⚠️ ErrorBoundary 捕获错误: $error');
    debugPrint('StackTrace: $stackTrace');
    
    setState(() {
      _errorMessage = error.toString();
      _stackTrace = stackTrace;
    });
  }
}

/// 主页内容
class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    // 延迟导入避免循环依赖
    return const _HomePage();
  }
}

/// 临时首页 - 稍后会被完整页面替换
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

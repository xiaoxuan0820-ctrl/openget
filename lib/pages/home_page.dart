/// 主页面
/// OpenGet - 提示词优化工具

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/prompt_result.dart';
import '../services/glm_service.dart';
import '../widgets/input_section.dart';
import '../widgets/result_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _inputController = TextEditingController();
  final GlmService _glmService = GlmService();
  
  LoadingState _loadingState = LoadingState.idle;
  PromptResult? _result;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_fix_high, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: AppTheme.textSecondary),
          onPressed: _showAboutDialog,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          // 输入区域
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: InputSection(
              controller: _inputController,
              isLoading: _loadingState == LoadingState.loading,
              onOptimize: _handleOptimize,
            ),
          ),

          // 分割线
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),

          // 结果区域
          Expanded(
            child: _buildResultArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea() {
    switch (_loadingState) {
      case LoadingState.idle:
        return _buildIdleState();
      case LoadingState.loading:
        return _buildLoadingState();
      case LoadingState.success:
        return _buildSuccessState();
      case LoadingState.error:
        return _buildErrorState();
    }
  }

  /// 空状态
  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            '输入你的需求，开始优化提示词',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '我们会将你的自然语言转换为专业AI指令',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  /// 加载状态
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '正在优化中...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '分析你的需求，生成专业提示词',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 成功状态
  Widget _buildSuccessState() {
    if (_result == null) return const SizedBox();
    return ResultSection(result: _result!);
  }

  /// 错误状态
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '优化失败',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? '发生未知错误',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重新尝试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理优化
  Future<void> _handleOptimize() async {
    final input = _inputController.text.trim();
    
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入需要优化的提示词'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _loadingState = LoadingState.loading;
      _errorMessage = null;
    });

    try {
      final result = await _glmService.optimizePrompt(input);
      setState(() {
        _result = result;
        _loadingState = LoadingState.success;
      });
    } on PromptException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _loadingState = LoadingState.error;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '发生错误: ${e.toString()}';
        _loadingState = LoadingState.error;
      });
    }
  }

  /// 重试
  void _handleRetry() {
    _handleOptimize();
  }

  /// 关于对话框
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_fix_high, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.appName),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '版本: ${AppConstants.appVersion}',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 12),
            Text(
              AppConstants.appDescription,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '一款智能提示词优化工具，帮助你将自然语言转换为更精准、专业的AI指令。',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}

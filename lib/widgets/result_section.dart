/// 结果展示组件
/// OpenGet - 提示词优化工具

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/prompt_result.dart';

class ResultSection extends StatelessWidget {
  final PromptResult result;

  const ResultSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor, size: 24),
              const SizedBox(width: 8),
              Text(
                '优化结果',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 结构化拆解
          _buildSectionCard(
            context,
            title: '【目标】',
            content: result.goal.isNotEmpty ? result.goal : '未识别到目标',
            color: AppTheme.tagGoal,
            icon: Icons.flag,
          ),
          
          _buildSectionCard(
            context,
            title: '【背景】',
            content: result.background.isNotEmpty ? result.background : '无需额外背景',
            color: AppTheme.tagBackground,
            icon: Icons.info_outline,
          ),
          
          _buildSectionCard(
            context,
            title: '【要求】',
            content: result.requirements.isNotEmpty ? result.requirements : '无特殊要求',
            color: AppTheme.tagRequirement,
            icon: Icons.rule,
          ),
          
          _buildSectionCard(
            context,
            title: '【输出格式】',
            content: result.outputFormat.isNotEmpty ? result.outputFormat : '未指定',
            color: AppTheme.tagFormat,
            icon: Icons.article_outlined,
          ),

          const SizedBox(height: 24),

          // 优化后的完整提示词
          _buildOptimizedPromptSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String content,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedPromptSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryLight.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_fix_high, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 10),
                const Text(
                  '✨ 优化后的完整提示词',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              result.optimizedPrompt.isNotEmpty 
                  ? result.optimizedPrompt 
                  : result.originalInput,
              style: const TextStyle(
                fontSize: 15,
                height: 1.8,
                fontFamily: 'monospace',
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          // 复制按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy, size: 20),
                label: const Text('一键复制'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final textToCopy = result.optimizedPrompt.isNotEmpty 
        ? result.optimizedPrompt 
        : result.originalInput;
    
    Clipboard.setData(ClipboardData(text: textToCopy));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('已复制到剪贴板'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

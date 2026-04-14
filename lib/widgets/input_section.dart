/// 输入区域组件
/// OpenGet - 提示词优化工具

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class InputSection extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onOptimize;
  final bool isLoading;

  const InputSection({
    super.key,
    required this.controller,
    required this.onOptimize,
    required this.isLoading,
  });

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _charCount = widget.controller.text.length;
    widget.controller.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    setState(() {
      _charCount = widget.controller.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(Icons.edit_note, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              '输入你的需求',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 输入框
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            enabled: !widget.isLoading,
            maxLines: 6,
            maxLength: AppConstants.maxInputLength,
            decoration: InputDecoration(
              hintText: '例如：帮我写一封商务邮件，邀请客户参加产品发布会...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              counterText: '',
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        
        // 字符计数
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '清晰的需求 = 更好的优化结果',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '$_charCount / ${AppConstants.maxInputLength}',
                style: TextStyle(
                  fontSize: 12,
                  color: _charCount > AppConstants.maxInputLength 
                      ? AppTheme.errorColor 
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 优化按钮
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onOptimize,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              elevation: 2,
            ),
            child: widget.isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '优化中...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_fix_high, size: 22),
                      SizedBox(width: 8),
                      Text(
                        '开始优化',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCharCount);
    super.dispose();
  }
}

/// 提示词优化结果数据模型
/// OpenGet - 提示词优化工具

/// 优化结果模型
class PromptResult {
  /// 目标 - 明确用户的核心意图
  final String goal;
  
  /// 背景 - 上下文信息
  final String background;
  
  /// 要求 - 约束条件
  final String requirements;
  
  /// 输出格式 - 期望的结果形式
  final String outputFormat;
  
  /// 优化后的完整提示词
  final String optimizedPrompt;
  
  /// 原始输入
  final String originalInput;
  
  /// 创建时间
  final DateTime createdAt;

  PromptResult({
    required this.goal,
    required this.background,
    required this.requirements,
    required this.outputFormat,
    required this.optimizedPrompt,
    required this.originalInput,
    required this.createdAt,
  });

  /// 从API响应解析结果
  factory PromptResult.fromApiResponse(String originalInput, String response) {
    final goal = _extractSection(response, '【目标】', '【背景】') ?? 
                 _extractSection(response, '目标', '背景') ??
                 '';
    
    final background = _extractSection(response, '【背景】', '【要求】') ??
                       _extractSection(response, '背景', '要求') ??
                       '';
    
    final requirements = _extractSection(response, '【要求】', '【输出格式】') ??
                         _extractSection(response, '要求', '输出格式') ??
                         '';
    
    final outputFormat = _extractSection(response, '【输出格式】', '【优化后的完整提示词】') ??
                        _extractSection(response, '【输出格式】', '【最终优化结果】') ??
                        _extractSection(response, '输出格式', '优化后的完整提示词') ??
                        '';
    
    final optimizedPrompt = _extractFinalPrompt(response);

    return PromptResult(
      goal: goal.trim(),
      background: background.trim(),
      requirements: requirements.trim(),
      outputFormat: outputFormat.trim(),
      optimizedPrompt: optimizedPrompt.trim(),
      originalInput: originalInput,
      createdAt: DateTime.now(),
    );
  }

  /// 提取章节内容
  static String? _extractSection(String text, String startTag, String endTag) {
    try {
      final startIndex = text.indexOf(startTag);
      if (startIndex == -1) return null;
      
      final contentStart = startIndex + startTag.length;
      var endIndex = text.indexOf(endTag, contentStart);
      if (endIndex == -1) {
        final nextTagIndex = text.indexOf('【', contentStart);
        if (nextTagIndex != -1) {
          endIndex = nextTagIndex;
        } else {
          endIndex = text.length;
        }
      }
      
      return text.substring(contentStart, endIndex).trim();
    } catch (e) {
      return null;
    }
  }

  /// 提取最终优化后的提示词
  static String _extractFinalPrompt(String text) {
    final endTags = ['【优化后的完整提示词】', '【最终优化结果】', '【优化后的提示词】', '最终提示词：'];
    var endIndex = text.length;
    
    for (final tag in endTags) {
      final index = text.indexOf(tag);
      if (index != -1 && index < endIndex) {
        endIndex = index + tag.length;
        break;
      }
    }
    
    final codeBlockRegex = RegExp(r'```[\w]*\n?([\s\S]*?)```');
    final match = codeBlockRegex.firstMatch(text);
    if (match != null) {
      return match.group(1)?.trim() ?? text.substring(endIndex).trim();
    }
    
    return text.substring(endIndex).trim();
  }

  /// 检查结果是否有效
  bool get isValid {
    return goal.isNotEmpty || 
           background.isNotEmpty || 
           requirements.isNotEmpty || 
           outputFormat.isNotEmpty || 
           optimizedPrompt.isNotEmpty;
  }

  @override
  String toString() {
    return 'PromptResult(goal: $goal, background: $background, requirements: $requirements, outputFormat: $outputFormat)';
  }
}

/// 状态枚举
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// 异常类
class PromptException implements Exception {
  final String message;
  final String? code;

  PromptException(this.message, {this.code});

  @override
  String toString() => 'PromptException: $message';
}

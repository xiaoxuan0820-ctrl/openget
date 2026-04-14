/// GLM API 服务
/// OpenGet - 提示词优化工具

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prompt_result.dart';
import '../prompts/system_prompts.dart';

/// API配置
class _ApiConfig {
  static const String apiKey = '0f664bbe473a4af9a0531afcce56be40.JH5XPebgLYdPHjSU';
  static const String endpoint = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String model = 'glm-4-flash';
  static const int timeout = 30000;
  static const double temperature = 0.7;
}

/// GLM API服务类
class GlmService {
  static final GlmService _instance = GlmService._internal();
  factory GlmService() => _instance;
  GlmService._internal();

  /// 调用GLM API进行提示词优化
  Future<PromptResult> optimizePrompt(String userInput) async {
    // 输入验证
    if (userInput.trim().isEmpty) {
      throw PromptException('请输入需要优化的提示词');
    }
    
    if (userInput.trim().length < 5) {
      throw PromptException('输入内容过短，请提供更详细的需求描述');
    }

    if (userInput.trim().length > 2000) {
      throw PromptException('输入内容过长，请精简您的需求（限制2000字符）');
    }

    try {
      final response = await _callGlmApi(userInput);
      return PromptResult.fromApiResponse(userInput, response);
    } catch (e) {
      if (e is PromptException) rethrow;
      throw PromptException('优化失败: ${e.toString()}');
    }
  }

  /// 调用GLM API
  Future<String> _callGlmApi(String userInput) async {
    final url = Uri.parse(_ApiConfig.endpoint);
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_ApiConfig.apiKey}',
    };

    final body = jsonEncode({
      'model': _ApiConfig.model,
      'messages': [
        {
          'role': 'system',
          'content': SystemPrompts.promptOptimizer,
        },
        {
          'role': 'user', 
          'content': SystemPrompts.getUserPrompt(userInput),
        },
      ],
      'temperature': _ApiConfig.temperature,
      'max_tokens': 2048,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        Duration(milliseconds: _ApiConfig.timeout),
        onTimeout: () {
          throw PromptException('请求超时，请检查网络连接后重试');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'];
          final content = message['content'] as String?;
          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
        throw PromptException('API返回数据格式异常');
      } else if (response.statusCode == 401) {
        throw PromptException('API密钥无效或已过期');
      } else if (response.statusCode == 429) {
        throw PromptException('请求过于频繁，请稍后重试');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ?? '未知错误';
        throw PromptException('API错误: $errorMsg');
      }
    } on PromptException {
      rethrow;
    } catch (e) {
      throw PromptException('网络请求失败: ${e.toString()}');
    }
  }
}

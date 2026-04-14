/// GLM API 服务
/// OpenGet - 提示词优化工具
/// 增强版 - 针对鸿蒙系统优化

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/prompt_result.dart';
import '../prompts/system_prompts.dart';

/// API配置
class _ApiConfig {
  // ⚠️ 请替换为您自己的API Key
  static const String apiKey = '0f664bbe473a4af9a0531afcce56be40.JH5XPebgLYdPHjSU';
  static const String endpoint = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String model = 'glm-4-flash';
  
  // 超时设置（毫秒）
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 60000;
  
  // 温度参数
  static const double temperature = 0.7;
  
  // 最大token数
  static const int maxTokens = 2048;
}

/// GLM API服务类
class GlmService {
  static final GlmService _instance = GlmService._internal();
  factory GlmService() => _instance;
  GlmService._internal();

  /// 调用GLM API进行提示词优化
  Future<PromptResult> optimizePrompt(String userInput) async {
    debugPrint('🔄 开始优化提示词...');
    debugPrint('📝 输入长度: ${userInput.length} 字符');
    
    // 输入验证
    if (userInput.trim().isEmpty) {
      debugPrint('⚠️ 输入为空');
      throw PromptException('请输入需要优化的提示词');
    }
    
    if (userInput.trim().length < 5) {
      debugPrint('⚠️ 输入过短: ${userInput.length} 字符');
      throw PromptException('输入内容过短，请提供更详细的需求描述');
    }

    if (userInput.trim().length > 2000) {
      debugPrint('⚠️ 输入过长: ${userInput.length} 字符');
      throw PromptException('输入内容过长，请精简您的需求（限制2000字符）');
    }

    try {
      debugPrint('🌐 开始调用GLM API...');
      final response = await _callGlmApi(userInput);
      debugPrint('✅ API调用成功，响应长度: ${response.length} 字符');
      
      final result = PromptResult.fromApiResponse(userInput, response);
      debugPrint('✅ 解析结果完成');
      
      return result;
    } catch (e) {
      debugPrint('❌ 优化失败: $e');
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
      'Accept': 'application/json',
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
      'max_tokens': _ApiConfig.maxTokens,
    });

    debugPrint('📤 发送请求到: ${_ApiConfig.endpoint}');
    
    try {
      // 创建HTTP客户端
      final client = http.Client();
      
      try {
        final request = http.Request('POST', url);
        request.headers.addAll(headers);
        request.body = body;
        
        // 使用send方法发送请求，可以获取更多响应信息
        final streamedResponse = await client.send(request).timeout(
          const Duration(milliseconds: _ApiConfig.connectionTimeout),
          onTimeout: () {
            debugPrint('⏰ 请求超时');
            throw PromptException('连接超时，请检查网络连接后重试');
          },
        );
        
        // 获取完整响应
        final response = await http.Response.fromStream(streamedResponse).timeout(
          const Duration(milliseconds: _ApiConfig.receiveTimeout),
          onTimeout: () {
            debugPrint('⏰ 响应超时');
            throw PromptException('响应超时，请稍后重试');
          },
        );
        
        debugPrint('📥 收到响应: HTTP ${response.statusCode}');
        
        return _handleResponse(response);
        
      } finally {
        client.close();
      }
      
    } on PromptException {
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('⏰ 超时异常: $e');
      throw PromptException('请求超时，请检查网络连接后重试');
    } on SocketException catch (e) {
      debugPrint('🔌 网络异常: $e');
      throw PromptException('网络连接失败，请检查网络设置');
    } on FormatException catch (e) {
      debugPrint('📄 格式异常: $e');
      throw PromptException('数据格式错误');
    } on http.ClientException catch (e) {
      debugPrint('🌐 HTTP异常: $e');
      throw PromptException('网络请求失败: ${e.message}');
    } catch (e) {
      debugPrint('❓ 未知异常: $e (${e.runtimeType})');
      throw PromptException('请求失败: ${e.toString()}');
    }
  }

  /// 处理API响应
  String _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List?;
        
        if (choices == null || choices.isEmpty) {
          debugPrint('⚠️ 响应中没有choices');
          throw PromptException('API返回数据格式异常');
        }
        
        final message = choices[0]['message'];
        if (message == null) {
          debugPrint('⚠️ 响应中没有message');
          throw PromptException('API返回数据格式异常');
        }
        
        final content = message['content'] as String?;
        if (content == null || content.isEmpty) {
          debugPrint('⚠️ 响应中没有content');
          throw PromptException('API返回数据为空');
        }
        
        return content;
        
      } on FormatException {
        debugPrint('⚠️ JSON解析失败');
        throw PromptException('API返回数据格式异常');
      }
    } else if (response.statusCode == 401) {
      debugPrint('🔑 API认证失败');
      throw PromptException('API密钥无效或已过期');
    } else if (response.statusCode == 403) {
      debugPrint('🚫 访问被拒绝');
      throw PromptException('访问被拒绝，请联系管理员');
    } else if (response.statusCode == 429) {
      debugPrint('⚠️ 请求过于频繁');
      throw PromptException('请求过于频繁，请稍后重试');
    } else if (response.statusCode >= 500) {
      debugPrint('🖥️ 服务器错误: ${response.statusCode}');
      throw PromptException('服务器维护中，请稍后重试');
    } else {
      // 尝试解析错误信息
      try {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 
                        errorData['message'] ?? 
                        '未知错误';
        debugPrint('❌ API错误: $errorMsg');
        throw PromptException('API错误: $errorMsg');
      } catch (e) {
        if (e is PromptException) rethrow;
        debugPrint('❌ 未知错误: HTTP ${response.statusCode}');
        throw PromptException('请求失败: HTTP ${response.statusCode}');
      }
    }
  }
}

/// 诊断方法 - 用于排查问题
class GlmServiceDiagnostic {
  /// 检查网络连接
  static Future<bool> checkNetwork() async {
    try {
      debugPrint('🌐 检查网络连接...');
      final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
      debugPrint('✅ 网络连接正常: ${result.length} 个地址');
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('❌ 网络连接失败: $e');
      return false;
    }
  }
  
  /// 检查API端点
  static Future<bool> checkApiEndpoint() async {
    try {
      debugPrint('🔍 检查API端点...');
      final url = Uri.parse(_ApiConfig.endpoint);
      final result = await InternetAddress.lookup(url.host)
        .timeout(const Duration(seconds: 5));
      debugPrint('✅ API端点可访问: ${url.host}');
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('❌ API端点不可访问: $e');
      return false;
    }
  }
  
  /// 打印诊断信息
  static Future<void> printDiagnostic() async {
    debugPrint('========== OpenGet 诊断信息 ==========');
    debugPrint('API Endpoint: ${_ApiConfig.endpoint}');
    debugPrint('API Model: ${_ApiConfig.model}');
    debugPrint('API Key: ${_ApiConfig.apiKey.substring(0, 10)}...');
    
    final networkOk = await checkNetwork();
    debugPrint('网络连接: ${networkOk ? "✅ 正常" : "❌ 失败"}');
    
    if (networkOk) {
      final apiOk = await checkApiEndpoint();
      debugPrint('API端点: ${apiOk ? "✅ 可访问" : "❌ 不可访问"}');
    }
    
    debugPrint('平台: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    debugPrint('Dart版本: ${Platform.version}');
    debugPrint('========================================');
  }
}

/// API配置文件
/// OpenGet - 提示词优化工具

class ApiConfig {
  // GLM-4-Flash API 配置
  static const String apiKey = '0f664bbe473a4af9a0531afcce56be40.JH5XPebgLYdPHjSU';
  static const String endpoint = 'https://open.bigmodel.cn/api/paas/v4/chat/completions';
  static const String model = 'glm-4-flash';
  
  // 请求超时时间（毫秒）
  static const int timeout = 30000;
  
  // 最大输入长度
  static const int maxInputLength = 2000;
  
  // 温度参数（创造性越低越稳定）
  static const double temperature = 0.7;
}

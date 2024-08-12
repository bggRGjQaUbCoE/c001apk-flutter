class GlobalData {
  // 私有构造函数
  GlobalData._();

  // 单例实例
  static final GlobalData _instance = GlobalData._();

  // 获取全局实例
  factory GlobalData() => _instance;

  // ignore: non_constant_identifier_names
  String SESSID = '';
  String uid = '';
  String username = '';
  String token = '';
}

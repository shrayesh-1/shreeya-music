AppConfig appConfig = AppConfig(version: 26, codeName: '2.0.1');

class AppConfig {
  int version;
  String codeName;
  Uri updateUri = Uri.parse(
      'https://api.github.com/repos/jhelumcorp/shreeya/releases/latest');
  AppConfig({required this.version, required this.codeName});
}

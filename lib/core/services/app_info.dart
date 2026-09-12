/// Ilova haqidagi o'zgarmas ma'lumot.
///
/// Nega alohida: versiyani `PackageInfo` dan **mantiq ichida** o'qish
/// taqiqlangan (13.4) va uni har ekranda qayta o'qish ham keraksiz. U ishga
/// tushishda bir marta olinadi (`AppStartup`) va shu yerda turadi.
final class AppInfo {
  String _version = '';

  /// Bo'sh satr — hali o'qilmagan.
  String get version => _version;

  void save(String value) => _version = value;
}

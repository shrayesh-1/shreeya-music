import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../ytmusic/ytmusic.dart';

Box _box = Hive.box('SETTINGS');

class SettingsManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final List<ThemeMode> _themeModes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark
  ];
  late Map<String, String> _location;
  late Map<String, String> _language;
  final List<AudioQuality> _audioQualities = [
    AudioQuality.high,
    AudioQuality.low
  ];
  List<WindowEffect> get windowEffectList => [
        WindowEffect.disabled,
        WindowEffect.acrylic,
        WindowEffect.mica,
        WindowEffect.tabbed,
        WindowEffect.aero,
      ];
  AudioQuality _streamingQuality = AudioQuality.high;
  AudioQuality _downloadQuality = AudioQuality.high;
  bool _skipSilence = false;
  Color? _accentColor;
  bool _amoledBlack = true;
  bool _dynamicColors = false;
  WindowEffect _windowEffect = WindowEffect.disabled;
  bool _equalizerEnabled = false;
  List<double> _equalizerBandsGain = [];
  bool _loudnessEnabled = false;
  double _loudnessTargetGain = 0.0;

  ThemeMode get themeMode => _themeMode;
  List<ThemeMode> get themeModes => _themeModes;
  Map<String, String> get location => _location;
  List<Map<String, String>> get locations => _countries;
  Map<String, String> get language => _language;
  List<Map<String, String>> get languages => _languages;
  List<AudioQuality> get audioQualities => _audioQualities;
  AudioQuality get streamingQuality => _streamingQuality;
  AudioQuality get downloadQuality => _downloadQuality;
  bool get skipSilence => _skipSilence;

  Color? get accentColor => _accentColor;
  bool get amoledBlack => _amoledBlack;
  bool get dynamicColors => _dynamicColors;
  WindowEffect get windowEffect => _windowEffect;
  bool get equalizerEnabled => _equalizerEnabled;
  List<double> get equalizerBandsGain => _equalizerBandsGain;
  bool get loudnessEnabled => _loudnessEnabled;
  double get loudnessTargetGain => _loudnessTargetGain;

  Map get settings => _box.toMap();
  SettingsManager() {
    _init();
  }
  _init() {
    _themeMode = _themeModes[_box.get('THEME_MODE', defaultValue: 0)];
    _language = _languages.firstWhere((language) =>
        language['value'] == _box.get('LANGUAGE', defaultValue: 'ne'));
    _accentColor = _box.get('ACCENT_COLOR') != null
        ? Color(_box.get('ACCENT_COLOR'))
        : null;
    _amoledBlack = _box.get('AMOLED_BLACK', defaultValue: true);
    _dynamicColors = _box.get('DYNAMIC_COLORS', defaultValue: false);
    _windowEffect = windowEffectList.firstWhere((el) =>
        el.name.toUpperCase() ==
        _box.get('WINDOW_EFFECT',
            defaultValue: WindowEffect.disabled.name.toUpperCase()));

    _location = _countries.firstWhere((country) =>
        country['value'] == _box.get('LOCATION', defaultValue: 'IN'));

    _streamingQuality =
        _audioQualities[_box.get('STREAMING_QUALITY', defaultValue: 0)];
    _downloadQuality =
        _audioQualities[_box.get('DOWNLOAD_QUALITY', defaultValue: 0)];
    _skipSilence = _box.get('SKIP_SILENCE', defaultValue: false);
    _equalizerEnabled = _box.get('EQUALIZER_ENABLED', defaultValue: false);
    _loudnessEnabled = _box.get('LOUDNESS_ENABLED', defaultValue: false);
    _loudnessTargetGain = _box.get('LOUDNESS_TARGET_GAIN', defaultValue: 0.0);
    _equalizerBandsGain =
        _box.get('EQUALIZER_BANDS_GAIN', defaultValue: []).cast<double>();
  }

  setThemeMode(ThemeMode mode) async {
    _box.put('THEME_MODE', _themeModes.indexOf(mode));
    _themeMode = mode;
    if (Platform.isWindows) {
      await Window.setEffect(
        effect: _windowEffect,
        dark: getDarkness(_themeModes.indexOf(mode)),
      );
    }
    notifyListeners();
  }

  setwindowEffect(WindowEffect effect) async {
    _box.put('WINDOW_EFFECT', effect.name.toUpperCase());
    _windowEffect = effect;

    await Window.setEffect(
      effect: _windowEffect,
      dark: getDarkness(_themeModes.indexOf(_themeMode)),
    );

    notifyListeners();
  }

  set location(Map<String, String> value) {
    _box.put('LOCATION', value['value']);
    _location = value;
    GetIt.I<YTMusic>().refreshContext();
    notifyListeners();
  }

  set language(Map<String, String> value) {
    _box.put('LANGUAGE', value['value']);
    _language = value;
    GetIt.I<YTMusic>().refreshContext();
    notifyListeners();
  }

  set streamingQuality(AudioQuality value) {
    _box.put('STREAMING_QUALITY', _audioQualities.indexOf(value));
    _streamingQuality = value;
    notifyListeners();
  }

  set downloadQuality(AudioQuality value) {
    _box.put('DOWNLOAD_QUALITY', _audioQualities.indexOf(value));
    _downloadQuality = value;
    notifyListeners();
  }

  set skipSilence(bool value) {
    _box.put('SKIP_SILENCE', value);
    _skipSilence = value;
    notifyListeners();
  }

  set accentColor(Color? color) {
    int? c = color?.value;
    _box.put('ACCENT_COLOR', c);
    _accentColor = color;
    notifyListeners();
  }

  set amoledBlack(bool val) {
    _box.put('AMOLED_BLACK', val);
    _amoledBlack = val;
    notifyListeners();
  }

  set dynamicColors(bool isMaterial) {
    _box.put('DYNAMIC_COLORS', isMaterial);
    _dynamicColors = isMaterial;
    notifyListeners();
  }

  set equalizerEnabled(bool enabled) {
    _box.put('EQUALIZER_ENABLED', enabled);
    _equalizerEnabled = enabled;
    notifyListeners();
  }

  set equalizerBandsGain(List<double>? value) {
    if (value != null) {
      _box.put('EQUALIZER_BANDS_GAIN', value);
      _equalizerBandsGain = value;
      notifyListeners();
    }
  }

  Future<void> setEqualizerBandsGain(int index, double value) async {
    _equalizerBandsGain[index] = value;
    await _box.put('EQUALIZER_BANDS_GAIN', equalizerBandsGain);
    notifyListeners();
  }

  set loudnessEnabled(enabled) {
    _box.put('LOUDNESS_ENABLED', enabled);
    _loudnessEnabled = enabled;
    notifyListeners();
  }

  set loudnessTargetGain(double value) {
    _box.put('LOUDNESS_TARGET_GAIN', value);
    _loudnessTargetGain = value;
    notifyListeners();
  }

  Future<void> setSettings(Map value) async {
    await Future.forEach(value.entries, (entry) async {
      await _box.put(entry.key, entry.value);
    });
    notifyListeners();
    _init();
  }
}

bool getDarkness(int themeMode) {
  if (themeMode == 0) {
    return MediaQueryData.fromView(
                    WidgetsBinding.instance.platformDispatcher.views.first)
                .platformBrightness ==
            Brightness.dark
        ? true
        : false;
  } else if (themeMode == 2) {
    return true;
  }
  return false;
}

enum AudioQuality { high, low }

List<Map<String, String>> _countries = [
 
  {"name": "India", "value": "NP"},
  {"name": "Nepal", "value": "IN"},
  {"name": "United Kingdom", "value": "GB"},
  {"name": "United States", "value": "US"}
  
];

List<Map<String, String>> _languages = [
  {"name": "English", "value": "en-IN"},
  {"name": "नेपाली", "value": "ne"},
  
];

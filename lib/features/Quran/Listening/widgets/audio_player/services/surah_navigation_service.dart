import '../../../../reading/models/surah_model.dart';

// خدمة إدارة التنقل بين السور والتحقق من حدود المصحف الشريف
class SurahNavigationService {
  List<SurahModel> _surahList;
  SurahModel _currentSurah;

  SurahNavigationService({
    required SurahModel initialSurah,
    List<SurahModel>? surahList,
  })  : _currentSurah = initialSurah,
        _surahList = surahList ?? [];

  // قائمة السور الحالية
  List<SurahModel> get surahList => _surahList;

  // السورة المحددة حالياً
  SurahModel get currentSurah => _currentSurah;

  // تحديث قائمة السور
  void updateSurahList(List<SurahModel> list) {
    _surahList = list;
  }

  // تحديث السورة الحالية
  void updateCurrentSurah(SurahModel surah) {
    _currentSurah = surah;
  }

  // موقع السورة الحالية في القائمة
  int get currentSurahIndex {
    if (_surahList.isEmpty) return -1;
    return _surahList.indexWhere((s) => s.number == _currentSurah.number);
  }

  // التحقق من وجود سورة سابقة مع مراعاة السورة الأولى
  bool get hasPrevious {
    if (_currentSurah.number <= 1) return false;
    if (_surahList.isNotEmpty) {
      return currentSurahIndex > 0;
    }
    return true;
  }

  // التحقق من وجود سورة تالية مع مراعاة السورة الأخيرة
  bool get hasNext {
    if (_currentSurah.number >= 114) return false;
    if (_surahList.isNotEmpty) {
      return currentSurahIndex >= 0 && currentSurahIndex < _surahList.length - 1;
    }
    return true;
  }

  // جلب السورة السابقة إن وجدت
  SurahModel? get previousSurah {
    if (!hasPrevious) return null;
    final index = currentSurahIndex;
    if (index > 0 && index < _surahList.length) {
      return _surahList[index - 1];
    }
    return null;
  }

  // جلب السورة التالية إن وجدت
  SurahModel? get nextSurah {
    if (!hasNext) return null;
    final index = currentSurahIndex;
    if (index >= 0 && index < _surahList.length - 1) {
      return _surahList[index + 1];
    }
    return null;
  }

  // التحقق من صحة رقم السورة داخل حدود المصحف (1 إلى 114)
  bool isValidSurahNumber(int number) => number >= 1 && number <= 114;
}

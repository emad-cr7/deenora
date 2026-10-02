/// Represents the prayer call audio type: Adhan or Iqama.
enum MuadhinType {
  adhan,
  iqama;

  /// Default display label in English
  String get label => englishLabel;

  /// English display label
  String get englishLabel {
    switch (this) {
      case MuadhinType.adhan:
        return 'Adhan';
      case MuadhinType.iqama:
        return 'Iqama';
    }
  }

  /// Arabic display label
  String get arabicLabel {
    switch (this) {
      case MuadhinType.adhan:
        return 'أذان';
      case MuadhinType.iqama:
        return 'إقامة';
    }
  }
}

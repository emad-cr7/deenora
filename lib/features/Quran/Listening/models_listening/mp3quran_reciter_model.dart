class Mp3QuranReciter {
  final int id;
  final String name;
  final String letter;
  final List<Mp3QuranMoshaf> moshaf;

  const Mp3QuranReciter({
    required this.id,
    required this.name,
    required this.letter,
    required this.moshaf,
  });

  factory Mp3QuranReciter.fromJson(Map<String, dynamic> json) {
    return Mp3QuranReciter(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      letter: json['letter'] as String? ?? '',
      moshaf: (json['moshaf'] as List<dynamic>? ?? [])
          .map((e) => Mp3QuranMoshaf.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Mp3QuranMoshaf {
  final int id;
  final String name;
  final String server;
  final int surahTotal;
  final int moshafType;
  final String surahList;

  const Mp3QuranMoshaf({
    required this.id,
    required this.name,
    required this.server,
    required this.surahTotal,
    required this.moshafType,
    required this.surahList,
  });

  factory Mp3QuranMoshaf.fromJson(Map<String, dynamic> json) {
    return Mp3QuranMoshaf(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      server: json['server'] as String? ?? '',
      surahTotal: json['surah_total'] as int? ?? 0,
      moshafType: json['moshaf_type'] as int? ?? 0,
      surahList: json['surah_list'] as String? ?? '',
    );
  }

  /// Parses the comma-separated surah_list into a Set of surah numbers.
  Set<int> get surahNumbers {
    return surahList
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toSet();
  }

  /// Generates the 3-digit padded MP3 URL for a given surah number
  String? getAudioUrl(int surahNumber) {
    if (!surahNumbers.contains(surahNumber)) {
      return null;
    }
    final baseServer = server.endsWith('/') ? server : '$server/';
    final paddedNumber = surahNumber.toString().padLeft(3, '0');
    return '$baseServer$paddedNumber.mp3';
  }
}

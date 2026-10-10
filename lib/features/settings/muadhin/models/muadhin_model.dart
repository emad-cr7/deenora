import 'package:deenora/features/settings/muadhin/models/muadhin_audio_model.dart';

class MuadhinModel {
  final String id;
  final String nameAr;
  final String categoryAr;
  final String locationAr;
  final bool isMosque;
  final String imageUrl;
  final MuadhinAudioModel adhan;
  final MuadhinAudioModel iqama;

  const MuadhinModel({
    required this.id,
    required this.nameAr,
    required this.categoryAr,
    required this.locationAr,
    required this.isMosque,
    required this.imageUrl,
    required this.adhan,
    required this.iqama,
  });


  factory MuadhinModel.fromJson(Map<String, dynamic> json) {
    return MuadhinModel(
      id: json['id'] as String,
      nameAr: (json['name'] as Map<String, dynamic>)['ar'] as String,
      categoryAr: json['categoryAr'] as String,
      locationAr: (json['location'] as Map<String, dynamic>)['ar'] as String,
      isMosque: json['isMosque'] as bool,
      imageUrl: json['image'] as String,
      adhan: MuadhinAudioModel.fromJson(
        json['adhan'] as Map<String, dynamic>,
      ),
      iqama: MuadhinAudioModel.fromJson(
        json['iqama'] as Map<String, dynamic>,
      ),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'categoryAr': categoryAr,
      'locationAr': locationAr,
      'isMosque': isMosque,
      'image': imageUrl,
      'adhan': adhan.toJson(),
      'iqama': iqama.toJson(),
    };
  }
}

class ChapterAudioModel {
  final int chapterId;
  final String audioUrl;

  ChapterAudioModel({required this.chapterId, required this.audioUrl});

  factory ChapterAudioModel.fromJson(Map<String, dynamic> json) {
    return ChapterAudioModel(
      chapterId: json['chapter_id'] as int,
      audioUrl: json['audio_url'] as String,
    );
  }
}
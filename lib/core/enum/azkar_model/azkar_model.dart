class AzkarModel {
  final int id;
  final String text;
  final int count;

  AzkarModel({required this.id, required this.text, required this.count});

  Map<String, dynamic> toJson() {
    return {'id': this.id, 'text': this.text, 'count': this.count};
  }

  factory AzkarModel.fromJson(Map<String, dynamic> map) {
    return AzkarModel(
      id: map['id'] as int,
      text: map['text'] as String,
      count: map['count'] as int,
    );
  }
}



class Vocab {
  String greek;
  String english;
  String type;
  String gender;

  Vocab({
    required this.greek,
    required this.english,
    required this.type,
    required this.gender,
  });


  factory Vocab.fromJson(Map<String, dynamic> json) {
    return Vocab(
      greek: json['greek'],
      english: json['english'],
      type: json['type'],
      gender: json['gender'],
    );
  }
}

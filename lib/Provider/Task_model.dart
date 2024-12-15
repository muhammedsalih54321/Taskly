class Task {
  final int? key; // Hive key
  final String title;
  final List<String> times;

  Task({this.key, required this.title, required this.times});

  Map<String, dynamic> toMap() => {
        "Title": title,
        "Times": times,
      };

  factory Task.fromMap(int key, Map<dynamic, dynamic> map) {
    return Task(
      key: key,
      title: map['Title'],
      times: List<String>.from(map['Times'] ?? []),
    );
  }
}

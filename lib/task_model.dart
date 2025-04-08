class Task {
  String id;
  String name;
  bool isDone;
  String day;
  String hour;

  Task({
    required this.id,
    required this.name,
    this.isDone = false,
    required this.day,
    required this.hour,
  });

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['name'] ?? '',
      isDone: data['isDone'] ?? false,
      day: data['day'] ?? '',
      hour: data['hour'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'isDone': isDone, 'day': day, 'hour': hour};
  }
}

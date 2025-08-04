class Supply {
  final String id;
  final String name;

  Supply({required this.id, required this.name});

  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  String toString() {
    return 'Supply{name: $name}';
  }
}

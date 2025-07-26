class Group {
  final int id;
  final String name;
  final String? description;
  final int creatorId;

  Group({required this.id, required this.name, this.description, required this.creatorId});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      creatorId: json['creator_id'],
    );
  }
}

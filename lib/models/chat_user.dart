class ChatUser {
  final String id;        // <-- Add this
  final String name;
  final String email;
  final String about;
  final String images;
  final bool isOnline;
  final bool active;
  final int age;
  final String pushToken;

  ChatUser({
    required this.id,     // <-- required in constructor
    required this.name,
    required this.email,
    required this.about,
    required this.images,
    required this.isOnline,
    required this.active,
    required this.age,
    required this.pushToken,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? '',     // <-- Add this
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      about: json['about'] ?? '',
      images: json['images'] ?? '',
      isOnline: json['isOnline'] ?? false,
      active: json['active'] ?? false,
      age: json['age'] ?? 0,
      pushToken: json['pushToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,     // <-- Add this
      'name': name,
      'email': email,
      'about': about,
      'images': images,
      'isOnline': isOnline,
      'active': active,
      'age': age,
      'pushToken': pushToken,
    };
  }
}
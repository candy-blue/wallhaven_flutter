class User {
  final String username;
  final String avatar; // url to avatar
  final Map<String, String> avatarUrls;

  User({
    required this.username,
    required this.avatar,
    required this.avatarUrls,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final avatars = Map<String, String>.from(json['avatar'] ?? {});
    // Wallhaven avatar object has "200px", "128px", "32px", "20px" keys usually
    String bestAvatar = avatars['200px'] ?? avatars['128px'] ?? avatars['32px'] ?? '';
    
    return User(
      username: json['username'] ?? 'Anonymous',
      avatar: bestAvatar,
      avatarUrls: avatars,
    );
  }
}

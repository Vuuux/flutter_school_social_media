//Hmmie đại diện cho người bạn khác trừ bạn
class Ctuer {
  late String name;
  late String email;
  late String community;
  late String bio;
  late String gender;
  late String major;
  late String id;
  late String avatar;
  late String nickname;
  late bool isAnon;
  late String anonBio;
  late String anonInterest;
  late String anonAvatar;
  late int fame;
  late String media;
  late String course;
  late String playlist;
  late String address;

  Ctuer(
      {this.id = "",
      this.name = "",
      this.nickname = "",
      this.email = "",
      this.community = "",
      this.bio = "",
      this.gender = "",
      this.major = "",
      this.avatar = "",
      this.isAnon = false,
      this.anonBio = "",
      this.anonInterest = "",
      this.anonAvatar = "",
      this.fame = 0,
      this.media = "",
      this.course = "",
      this.playlist = "",
      this.address = ""});

  factory Ctuer.fromJson(Map<String, dynamic> data) {
    return Ctuer(
      id: data['id'],
      name: data['name'],
      nickname: data['nickname'],
      email: data['email'],
      community: data['community'],
      bio: data['bio'],
      gender: data['gender'],
      major: data['major'],
      avatar: data['pPic'],
      isAnon: data['isAnon'],
      anonBio: data['anonBio'],
      anonInterest: data['anonInterest'],
      anonAvatar: data['anonAvatar'],
      fame: data['fame'],
      media: data['media'],
      course: data['course'],
      playlist: data['playlist'],
      address: data['address'],
    );
  }
}

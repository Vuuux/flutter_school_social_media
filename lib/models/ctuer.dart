//Hmmie đại diện cho người bạn khác trừ bạn
class Ctuer {
  final String name;
  final String email;
  final String community;
  final String bio;
  final String gender;
  final String major;
  final String id;
  final String avatar;
  final String nickname;
  bool isAnon;
  final String anonBio;
  final String anonInterest;
  final String anonAvatar;
  final int fame;
  final String media;
  final String course;
  final String playlist;
  final String address;

  Ctuer(
      {this.name = "",
        this.email = "",
        this.community ="",
        this.bio= "",
        this.gender = "",
        this.major = "",
        this.id = "",
        this.avatar = "",
        this.nickname = "",
        this.isAnon = false,
        this.anonBio ="",
        this.anonInterest = "",
        this.anonAvatar = "",
        this.fame = 0,
        this.media = "",
        this.course = "",
        this.playlist = "",
        this.address = ""
      });
}


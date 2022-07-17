class ReviewClass {
  int status;
  String msg;
  List<Data> data;

  ReviewClass({this.status, this.msg, this.data});

  ReviewClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String name;
  String profilePic;
  int userId;
  String ratting;
  String review;

  Data({this.name, this.profilePic, this.userId, this.ratting, this.review});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    profilePic = json['profile_pic'];
    userId = json['user_id'];
    ratting = json['ratting'];
    review = json['review'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['profile_pic'] = this.profilePic;
    data['user_id'] = this.userId;
    data['ratting'] = this.ratting;
    data['review'] = this.review;
    return data;
  }
}

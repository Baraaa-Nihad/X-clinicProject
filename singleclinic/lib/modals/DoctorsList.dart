class DoctorsList {
  int status;
  String msg;
  Data data;

  DoctorsList({this.status, this.msg, this.data});

  DoctorsList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  int currentPage;
  List<InnerData> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  String nextPageUrl;
  String path;
  int perPage;
  String prevPageUrl;
  int to;
  int total;

  Data(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <InnerData>[];
      json['data'].forEach((v) {
        data.add(new InnerData.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'].toString();
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'].toString();
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class InnerData {
  int id;
  String name;
  String email;
  String password;
  String phoneNo;
  String workingHour;
  String aboutUs;
  String service;
  String image;
  String facebookId;
  String twitterId;
  String googleId;
  String instagramId;
  String createdAt;
  String updatedAt;
  String departmentName;

  InnerData(
      {this.id,
        this.name,
        this.email,
        this.password,
        this.phoneNo,
        this.workingHour,
        this.aboutUs,
        this.service,
        this.image,
        this.facebookId,
        this.twitterId,
        this.googleId,
        this.instagramId,
        this.createdAt,
        this.updatedAt,
        this.departmentName});

  InnerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phoneNo = json['phone_no'];
    workingHour = json['working_hour'];
    aboutUs = json['about_us'];
    service = json['service'];
    image = json['image'];
    facebookId = json['facebook_id'];
    twitterId = json['twitter_id'];
    googleId = json['google_id'];
    instagramId = json['instagram_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    departmentName = json['department_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone_no'] = this.phoneNo;
    data['working_hour'] = this.workingHour;
    data['about_us'] = this.aboutUs;
    data['service'] = this.service;
    data['image'] = this.image;
    data['facebook_id'] = this.facebookId;
    data['twitter_id'] = this.twitterId;
    data['google_id'] = this.googleId;
    data['instagram_id'] = this.instagramId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['department_name'] = this.departmentName;
    return data;
  }
}

class DoctorsAndServices {
  int status;
  String msg;
  Data data;

  DoctorsAndServices({this.status, this.msg, this.data});

  DoctorsAndServices.fromJson(Map<String, dynamic> json) {
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
  List<Doctor> doctor;
  List<Services> services;

  Data({this.doctor, this.services});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['doctor'] != null) {
      doctor = <Doctor>[];
      json['doctor'].forEach((v) {
        doctor.add(new Doctor.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services.add(new Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.doctor != null) {
      data['doctor'] = this.doctor.map((v) => v.toJson()).toList();
    }
    if (this.services != null) {
      data['services'] = this.services.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Doctor {
  var id;
  int userId;
  String name;

  Doctor({this.userId, this.name, this.id});

  Doctor.fromJson(Map<String, dynamic> json) {
    userId = int.parse(json['user_id']);
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['id'] = this.id;
    return data;
  }
}

class Services {
  int id;
  String name;
  String expectedTime;

  Services({this.id, this.name, this.expectedTime});

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    expectedTime = json['expected_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['expected_time'] = this.expectedTime;
    return data;
  }
}

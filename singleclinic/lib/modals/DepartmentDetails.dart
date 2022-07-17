class DepartmentDetails {
  int status;
  String msg;
  Data data;

  DepartmentDetails({this.status, this.msg, this.data});

  DepartmentDetails.fromJson(Map<String, dynamic> json) {
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
  int id;
  String name;
  String description;
  String emergencyNo;
  String image;
  List<Service> service;

  Data(
      {this.id,
        this.name,
        this.description,
        this.emergencyNo,
        this.image,
        this.service});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    emergencyNo = json['emergency_no'];
    image = json['image'];
    if (json['service'] != null) {
      service = <Service>[];
      json['service'].forEach((v) {
        service.add(new Service.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['emergency_no'] = this.emergencyNo;
    data['image'] = this.image;
    if (this.service != null) {
      data['service'] = this.service.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Service {
  int id;
  String name;
  String price;
  String priceFor;

  Service({this.id, this.name, this.price, this.priceFor});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    priceFor = json['price_for'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['price_for'] = this.priceFor;
    return data;
  }
}

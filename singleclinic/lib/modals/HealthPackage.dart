class HealthPackage {
  int status;
  String msg;
  List<Data> data;

  HealthPackage({this.status, this.msg, this.data});

  HealthPackage.fromJson(Map<String, dynamic> json) {
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
  int id;
  String name;
  String price;
  int departmentId;
  String description;
  String createdAt;
  String updatedAt;
  String isDelete;
  String departmentName;

  Data(
      {this.id,
        this.name,
        this.price,
        this.departmentId,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.departmentName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    departmentId = json['department_id'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isDelete = json['is_delete'];
    departmentName = json['department_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['department_id'] = this.departmentId;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['department_name'] = this.departmentName;
    return data;
  }
}

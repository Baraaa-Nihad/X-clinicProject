class UpcomingAppointments {
  int status;
  String msg;
  Data data;

  UpcomingAppointments({this.status, this.msg, this.data});

  UpcomingAppointments.fromJson(Map<String, dynamic> json) {
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
  int userId;
  int departmentId;
  int id;
  String name;
  String date;
  String time;
  String phoneNo;
  String status;
  String messages;
  String departmentName;
  int serviceId;
  String doctorName;
  String image;
  String serviceName;

  InnerData(
      {this.userId,
        this.departmentId,
        this.id,
        this.name,
        this.date,
        this.time,
        this.phoneNo,
        this.status,
        this.doctorName,
        this.messages,
        this.serviceId,
        this.departmentName,
        this.image,
        this.serviceName});

  InnerData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    departmentId = json['department_id'];
    id = json['id'];
    doctorName = json['doctor_name'];
    name = json['name'];
    date = json['date'];
    time = json['time'].toString();
    phoneNo = json['phone_no'];
    status = json['status'];
    messages = json['messages'];
    serviceId = json['service_id'];
    departmentName = json['department_name'];
    image = json['image'];
    serviceName = json['service_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['department_id'] = this.departmentId;
    data['id'] = this.id;
    data['name'] = this.name;
    data['date'] = this.date;
    data['time'] = this.time;
    data['phone_no'] = this.phoneNo;
    data['status'] = this.status;
    data['messages'] = this.messages;
    data['service_id'] = this.serviceId;
    data['department_name'] = this.departmentName;
    data['image'] = this.image;
    data['service_name'] = this.serviceName;
    return data;
  }
}

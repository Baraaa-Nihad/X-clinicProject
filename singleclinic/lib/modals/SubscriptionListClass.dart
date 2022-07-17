class SubscriptionListClass {
  int status;
  String msg;
  List<Data> data;

  SubscriptionListClass({this.status, this.msg, this.data});

  SubscriptionListClass.fromJson(Map<String, dynamic> json) {
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
  String date;
  String time;
  String amount;
  String name;
  String status;

  Data({this.date, this.time, this.amount, this.name, this.status});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    time = json['time'];
    amount = json['amount'];
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['time'] = this.time;
    data['amount'] = this.amount;
    data['name'] = this.name;
    data['status'] = this.status;
    return data;
  }
}

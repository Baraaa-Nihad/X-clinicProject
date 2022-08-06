import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/modals/DepartmentsList.dart';
import 'package:singleclinic/modals/DoctorsAndServices.dart';

import '../main.dart';
import '../modals/UpcomingAppointmrnts.dart';

class BookAppointment extends StatefulWidget {
  @override
  _BookAppointmentState createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  String departmentValue;
  String doctorValue;
  String serviceValue;

  UpcomingAppointments doctorAppointments;
  List<InnerData> doctorList = [];

  int doctorId;
  int serviceId;
  int departmentId;
  int userId;

  var docId = 0;
  String selectedFormattedDate;
  TextEditingController nameController;
  TextEditingController phoneController;
  String date;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String _hour, _minute, _time = " ";

  DoctorsAndServices doctorsAndServices;
  bool isLoadingDoctorAndServices = false;
  bool isAppointmentMadeSuccessfully = false;
  List<String> monthsList = [
    "",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  DepartmentsList departmentsList;

  String message = "";
  String max_delay_time = "";

  @override
  void initState() {
    super.initState();
    selectedFormattedDate = selectedDate.year.toString() +
        "-" +
        (selectedDate.month.toString().length == 1
            ? "0" + selectedDate.month.toString()
            : selectedDate.month.toString()) +
        "-" +
        (selectedDate.day.toString().length == 1
            ? "0" + selectedDate.day.toString()
            : selectedDate.day.toString());
    _time = "اختر الوقت";
    getDepartmentsList();
    SharedPreferences.getInstance().then((value) {
      userId = value.getInt("id");
      nameController = TextEditingController(text: value.getString("name"));
      phoneController =
          TextEditingController(text: value.getString("phone_no"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: LIGHT_GREY_SCREEN_BG,
            appBar: AppBar(
              leading: Container(),
              flexibleSpace: header(),
              elevation: 0,
              backgroundColor: WHITE,
            ),
            body: body(),
          ),
        ));
  }

  header() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                  ),
                  constraints: BoxConstraints(maxWidth: 30, minWidth: 10),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  APPOINTMENT_NOW,
                  style: TextStyle(
                      color: NAVY_BLUE,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return departmentsList == null
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton(
                          isExpanded: true,
                          hint: Text(
                            SELECT_DEPARTMENT,
                          ),
                          value: departmentValue,
                          items: List.generate(departmentsList.data.length,
                              (index) {
                            return DropdownMenuItem(
                              value: departmentsList.data[index].name,
                              child: Text(
                                departmentsList.data[index].name.toString(),
                                style: TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                setState(() {
                                  departmentId = departmentsList.data[index].id;
                                });
                                fetchDoctorsAndServices(
                                    departmentsList.data[index].id);
                              },
                              key: UniqueKey(),
                            );
                          }),
                          icon: Image.asset(
                            "assets/bookappointment/down-arrow.png",
                            height: 15,
                            width: 15,
                          ),
                          onChanged: (val) {
                            print(val);
                            setState(() {
                              departmentValue = val.toString();
                            });
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        DropdownButton(
                          isExpanded: true,
                          hint: Text(
                            isLoadingDoctorAndServices
                                ? LOADING
                                : SELECT_DOCTOR,
                          ),
                          value: doctorValue,
                          icon: Image.asset(
                            "assets/bookappointment/down-arrow.png",
                            height: 15,
                            width: 15,
                          ),
                          items: doctorsAndServices == null
                              ? []
                              : List.generate(
                                  doctorsAndServices.data.doctor.length,
                                  (index) {
                                  return DropdownMenuItem(
                                    value: doctorsAndServices
                                        .data.doctor[index].name,
                                    child: Text(doctorsAndServices
                                        .data.doctor[index].name),
                                    key: UniqueKey(),
                                    onTap: () {
                                      setState(() {
                                        doctorId = doctorsAndServices
                                            .data.doctor[index].userId;
                                        docId = doctorsAndServices
                                            .data.doctor[index].id;
                                      });
                                    },
                                  );
                                }),
                          onChanged: (val) {
                            print(val);
                            setState(() {
                              doctorValue = val.toString();
                            });
                            fetchDoctorAppointments(selectedFormattedDate);
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        DropdownButton(
                          isExpanded: true,
                          hint: Text(
                            isLoadingDoctorAndServices
                                ? LOADING
                                : SELECT_SERVICES,
                          ),
                          icon: Image.asset(
                            "assets/bookappointment/down-arrow.png",
                            height: 15,
                            width: 15,
                          ),
                          value: serviceValue,
                          items: doctorsAndServices == null
                              ? []
                              : List.generate(
                                  doctorsAndServices.data.services.length,
                                  (index) {
                                  return DropdownMenuItem(
                                    value: doctorsAndServices
                                            .data.services[index].name +
                                        index.toString(),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${doctorsAndServices.data.services[index].expectedTime.toString()} دقيقة ",
                                          textDirection: TextDirection.rtl,
                                        ),
                                        Text(doctorsAndServices
                                            .data.services[index].name),
                                      ],
                                    ),
                                    key: UniqueKey(),
                                    onTap: () {
                                      setState(() {
                                        serviceId = doctorsAndServices
                                            .data.services[index].id;
                                      });
                                    },
                                  );
                                }),
                          onChanged: (val) {
                            print(val);
                            setState(() {
                              serviceValue = val.toString();
                            });
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          NAME,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              isCollapsed: true),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: LIGHT_GREY_TEXT),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          PHONE_NUMBER,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              isCollapsed: true),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: LIGHT_GREY_TEXT),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          DATE,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                selectedFormattedDate.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: LIGHT_GREY_TEXT),
                              ),
                              Divider(
                                color: LIGHT_GREY_TEXT,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "الأوقات المحجوزة:",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[800]),
                        ),
                        doctorList.isEmpty
                            ? Text(
                                "لا توجد مواعيد محجوزة ",
                                style: TextStyle(color: Colors.grey),
                              )
                            : Container(
                                width: double.infinity,
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 1,
                                          childAspectRatio: 5,
                                          mainAxisSpacing: 5),
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: doctorList == null
                                      ? 0
                                      : doctorList.length,
                                  itemBuilder: (context, index) {
                                    return timeDetails(index);
                                  },
                                ),
                              ),
                        Divider(
                          color: Colors.green,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          TIME,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        InkWell(
                          onTap: () {
                            _selectTime(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                _time,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: LIGHT_GREY_TEXT),
                              ),
                              Divider(
                                color: LIGHT_GREY_TEXT,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "مدة التأخير القصوى المتوقعة",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        TextField(
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade500, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade500, width: 0.5),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade500, width: 0.5),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              max_delay_time = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          MESSAGE,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        TextField(
                          maxLines: 3,
                          minLines: 1,
                          style:
                              TextStyle(color: LIGHT_GREY_TEXT, fontSize: 14),
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: LIGHT_GREY_TEXT, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: LIGHT_GREY_TEXT, width: 0.5),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: LIGHT_GREY_TEXT, width: 0.5),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              message = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomButtons(),
            ],
          );
  }

  bottomButtons() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                bookAppointment();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(12, 5, 12, 15),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: LIME,
                ),
                child: Center(
                  child: Text(
                    ADD_APPOINTMENT,
                    style: TextStyle(
                        color: WHITE,
                        fontWeight: FontWeight.w700,
                        fontSize: 17),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        currentDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        print(selectedDate.toString().substring(0, 10));
        selectedFormattedDate = selectedDate.year.toString() +
            "-" +
            (selectedDate.month.toString().length == 1
                ? "0" + selectedDate.month.toString()
                : selectedDate.month.toString()) +
            "-" +
            (selectedDate.day.toString().length == 1
                ? "0" + selectedDate.day.toString()
                : selectedDate.day.toString());
      });
    fetchDoctorAppointments(selectedFormattedDate);
  }

  Future<Null> _selectTime(BuildContext context) async {
    TimeOfDay picked = await showTimePicker(
      context: context,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
      initialTime: selectedTime,
    );

    setState(() {
      selectedTime = picked;
    });

    if (picked != null) {
      if (DateTime.now().minute >= selectedTime.minute &&
          DateTime.now().hour >= selectedTime.hour &&
          DateTime.now().day == selectedDate.day) {
        messageDialog('Alert', 'يجب أن يكون الوقت في المستقبل ');
        print(selectedTime);
        print(DateTime.now().hour);
      } else {
        setState(() {
          selectedTime = picked;
          _hour = selectedTime.hour < 10
              ? "0" + selectedTime.hour.toString()
              : selectedTime.hour.toString();
          _minute = selectedTime.minute < 10
              ? "0" + selectedTime.minute.toString()
              : selectedTime.minute.toString();
          _time = _hour + ":" + _minute;
          print(_time);
        });
      }
    } else {
      setState(() {
        selectedTime = TimeOfDay.now();
      });
    }
  }

  getDepartmentsList() async {
    print('Getting departments');

    final response = await get(Uri.parse("$SERVER_ADDRESS/api/getdepartment"));

    print(response.request);

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        departmentsList = DepartmentsList.fromJson(jsonResponse);
      });
    }
  }

  fetchDoctorsAndServices(int id) async {
    setState(() {
      doctorValue = null;
      serviceValue = null;
      isLoadingDoctorAndServices = true;
      print(doctorValue.toString());
      doctorsAndServices = null;
    });
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/getdoctorandservicebydeptid?department_id=$id"));
    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        doctorsAndServices = DoctorsAndServices.fromJson(jsonResponse);
        isLoadingDoctorAndServices = false;
      });
    }
  }

  bookAppointment() async {
    if (serviceId == null || _time == "اختر الوقت" || max_delay_time == "") {
      messageDialog("Error", ENTER_ALL_FIELDS_TO_MAKE_APPOINTMENT);
    }
    int j = 0;
    for (int i = 0; i < doctorList.length; i++) {
      int finish = (doctorList[i].maxDelayTime != null
              ? int.parse(doctorList[i].maxDelayTime)
              : 0) +
          int.parse(doctorList[i].serviceTime);
      var dd = getTime1(doctorList[i].time, finish);
      TimeOfDay _timedb = TimeOfDay(
          hour: int.parse(doctorList[i].time.split(":")[0]),
          minute: int.parse(doctorList[i].time.split(":")[1]));
      TimeOfDay _selectedtime = TimeOfDay(
          hour: int.parse(_time.split(":")[0]),
          minute: int.parse(_time.split(":")[1]));

      if (_selectedtime.minute >= _timedb.minute &&
          _selectedtime.hour >= _timedb.hour &&
          _selectedtime.minute <= dd.minute &&
          _selectedtime.hour <= dd.hour) {
        j = j + 1;
      }
    }
    if (int.parse(max_delay_time) > 20 || int.parse(max_delay_time) < 0) {
      messageDialog("Error", "مدة التأخير القصوى يجب ان لا تتجاوز 20 دقيقة");
    } else if (j > 0) {
      messageDialog("Error", "لا يمكنك الحجز في هذا الزمن");
    } else {
      dialog();
      print("department_id:" +
          departmentId.toString() +
          "\n" +
          "service_id:" +
          serviceId.toString() +
          "\n" +
          "doctor_id:" +
          doctorId.toString() +
          "\n" +
          "name:" +
          nameController.text +
          "\n" +
          "phone_no:" +
          phoneController.text +
          "\n" +
          "date:" +
          selectedDate.toString().substring(0, 10) +
          "\n" +
          "time:" +
          _time +
          "\n" +
          "user_id:" +
          userId.toString() +
          "\n" +
          "messages:" +
          message);
      final response =
          await post(Uri.parse("$SERVER_ADDRESS/api/bookappointment"), body: {
        "department_id": departmentId.toString(),
        "service_id": serviceId.toString(),
        "doctor_id": doctorId.toString(),
        "name": nameController.text,
        "phone_no": phoneController.text,
        "date": selectedDate.toString().substring(0, 10),
        "time": _time,
        "user_id": userId.toString(),
        "messages": message,
        "max_delay_time": max_delay_time
      });

      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        print("Success");
        setState(() {
          Navigator.pop(context);
          messageDialog("Successful", jsonResponse['msg']);
          isAppointmentMadeSuccessfully = true;
        });
      } else {
        Navigator.pop(context);
        messageDialog("Error", jsonResponse['msg']);
      }
    }
  }

  dialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              PROCESSING,
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Text(
                      PLEASE_WAIT_WHILE_MAKING_APPOINTMENT,
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  messageDialog(String s1, String s2) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              s1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (isAppointmentMadeSuccessfully) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabBarScreen(),
                        ));
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(backgroundColor: LIME),
                child: Text(
                  OK,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: WHITE,
                  ),
                ),
              ),
            ],
          );
        });
  }

  getTime(String time, int fin) {
    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
    var mm = _startTime.minute + fin;
    var hh = _startTime.hourOfPeriod;
    if (mm >= 60) {
      return "${hh + 1}:${mm % 60}";
    } else if (mm >= 120) {
      return "${hh + 2}:${mm % 120}";
    } else if (mm >= 180) {
      return "${hh + 3}:${mm % 180}";
    } else if (mm >= 240) {
      return "${hh + 4}:${mm % 240}";
    } else {
      return "${hh}:${mm}";
    }
  }

  getTime1(String time, int fin) {
    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
    var mm = _startTime.minute + fin;
    var hh = _startTime.hour;
    if (mm >= 60) {
      return TimeOfDay(hour: hh + 1, minute: mm % 60);
    } else if (mm >= 120) {
      return TimeOfDay(hour: hh + 2, minute: mm % 120);
    } else if (mm >= 180) {
      return TimeOfDay(hour: hh + 3, minute: mm % 180);
    } else if (mm >= 240) {
      return TimeOfDay(hour: hh + 4, minute: mm % 240);
    } else {
      return TimeOfDay(hour: hh, minute: mm);
    }
  }

  timeDetails(int index) {
    int finish = (doctorList[index].maxDelayTime != null
            ? int.parse(doctorList[index].maxDelayTime)
            : 0) +
        int.parse(doctorList[index].serviceTime);
    var dd = getTime(doctorList[index].time, finish);
    return Container(
      margin: EdgeInsets.only(left: 5),
      height: 15,
      width: 95,
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getTime(doctorList[index].time, 0),
              style: TextStyle(color: WHITE, fontSize: 8),
            ),
            Text(
              " - ",
              style: TextStyle(color: WHITE, fontSize: 12),
            ),
            Text(
              dd,
              style: TextStyle(color: WHITE, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  fetchDoctorAppointments(String date) async {
    setState(() {
      doctorList.clear();
      doctorAppointments = null;
    });

    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/getdoctorbookedappointment?user_id=$doctorId&&date=$date"));
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      print(jsonResponse);
      print(jsonResponse);
      print(response.request.url);
      print(doctorId);
      print(date);
      setState(() {
        doctorAppointments = UpcomingAppointments.fromJson(jsonResponse);
        doctorList.addAll(doctorAppointments.data.data);
      });
    }
  }
}

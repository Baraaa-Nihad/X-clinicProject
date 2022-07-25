import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/modals/DoctorsAndServices.dart';

import '../main.dart';

class AutoselectBookAppointment extends StatefulWidget {
  final int departmentId;
  final int doctorId;
  final String doctorName;
  final String departmentName;

  AutoselectBookAppointment(
      this.departmentId, this.doctorName, this.departmentName, this.doctorId);

  @override
  _AutoselectBookAppointmentState createState() =>
      _AutoselectBookAppointmentState();
}

class _AutoselectBookAppointmentState extends State<AutoselectBookAppointment> {
  String doctorValue;
  String serviceValue;
  int doctorId;
  int serviceId;
  int departmentId;
  int userId;
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

  String message = "";
  String max_delay_time = "";

  @override
  void initState() {
    super.initState();
    selectedFormattedDate = selectedDate.day.toString() +
        " " +
        monthsList[selectedDate.month] +
        ", " +
        selectedDate.year.toString();
    _time = "اختر الوقت";
    SharedPreferences.getInstance().then((value) {
      setState(() {
        userId = value.getInt("id");
        nameController = TextEditingController(text: value.getString("name"));
        phoneController =
            TextEditingController(text: value.getString("phone_no"));
      });
    });
    fetchDoctorsAndServices(widget.departmentId);
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IgnorePointer(
                    child: TextField(
                      controller:
                          TextEditingController(text: widget.departmentName),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          isCollapsed: true),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  IgnorePointer(
                    child: TextField(
                      controller:
                          TextEditingController(text: widget.doctorName),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          isCollapsed: true),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  DropdownButton(
                    isExpanded: true,
                    hint: Text(
                      isLoadingDoctorAndServices ? LOADING : SELECT_SERVICES,
                    ),
                    icon: Image.asset(
                      "assets/bookappointment/down-arrow.png",
                      height: 15,
                      width: 15,
                    ),
                    value: serviceValue,
                    items: doctorsAndServices == null
                        ? []
                        : List.generate(doctorsAndServices.data.services.length,
                            (index) {
                            return DropdownMenuItem(
                              value:
                                  doctorsAndServices.data.services[index].name +
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
                    height: 50,
                  ),
                  Text(
                    NAME,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                        color: Colors.grey),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    PHONE_NUMBER,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                        color: Colors.grey),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    DATE,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                          selectedFormattedDate,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "الأوقات المتاحة للحجز في هذا اليوم:",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.green),
                  ),
                  Divider(
                    color: Colors.green,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    TIME,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                              color: Colors.grey),
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "مدة التأخير القصوى المتوقعة",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  TextField(
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 0.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 0.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 0.5),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  TextField(
                    maxLines: 3,
                    minLines: 1,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 0.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 0.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 0.5),
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
        selectedFormattedDate = selectedDate.day.toString() +
            " " +
            monthsList[selectedDate.month] +
            ", " +
            selectedDate.year.toString();
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
      initialTime: selectedTime,
    );

    selectedTime = picked;

    print(DateTime.now().minute);
    print(selectedTime.minute);
    print(DateTime.now().minute > selectedTime.minute);
    print(DateTime.now().hour >= selectedTime.hour);
    print(DateTime.now().day == selectedDate.day);

    if (picked != null) if ((DateTime.now().minute >= selectedTime.minute &&
        DateTime.now().hour >= selectedTime.hour &&
        DateTime.now().day == selectedDate.day)) {
      messageDialog('Alert', 'يجب أن يكون الوقت في المستقبل ');
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
        "$SERVER_ADDRESS/api/getdoctorandservicebydeptid?department_id=${widget.departmentId}"));
    final jsonResponse = jsonDecode(response.body);

    print(response.request);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        doctorsAndServices = DoctorsAndServices.fromJson(jsonResponse);
        isLoadingDoctorAndServices = false;
      });
    }
  }

  bookAppointment() async {
    if (serviceId == null || _time == "اختر الوقت") {
      messageDialog("Error", ENTER_ALL_FIELDS_TO_MAKE_APPOINTMENT);
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
        "department_id": widget.departmentId.toString(),
        "service_id": serviceId.toString(),
        "doctor_id": widget.doctorId.toString(),
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
                style: TextButton.styleFrom(
                  backgroundColor: LIME,
                ),
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
}

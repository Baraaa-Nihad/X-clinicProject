import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AllText.dart';
import '../main.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String name = "";
  TextEditingController nameController;
  String emailAddress = "";
  TextEditingController emailController;
  String phoneNumber = "";
  TextEditingController phoneController;
  String querytopic = "";
  String Message = "";
  String path = "";
  int id;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    return   Directionality(
        textDirection: TextDirection.rtl, child: SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          leading: Container(),
          backgroundColor: WHITE,
          flexibleSpace: header(),
        ),
        body: body(),
      ),
    ),
    );
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
                  CONTACT_US,
                  style:GoogleFonts.cairo(
                    textStyle:  TextStyle(
                        color: BLACK, fontSize: 16, fontWeight: FontWeight.w700),),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          NAME,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),)

                        ),
                        TextFormField(
                          controller: nameController,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "ادخل اسمك";
                            }
                            return null;
                          },
                          onSaved: (val) => name = val,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                              color: LIGHT_GREY_TEXT,
                            ),),

                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                          ),
                          onChanged: (val) {
                            setState(() {
                              name = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          EMAIL_ADDRESS,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),),),
                        TextFormField(
                          controller: emailController,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "ادخل البريد الالكتروني الخاص بك";
                            } else if (!EmailValidator.validate(val)) {
                              return "ادخل ايميل صحيح";
                            }
                            return null;
                          },
                          onSaved: (val) => emailAddress = val,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                                color: LIGHT_GREY_TEXT,),),


                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                          ),
                          onChanged: (val) {
                            setState(() {
                              emailAddress = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          PHONE_NUMBER,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),),),
                        TextFormField(
                          controller: phoneController,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Enter your phone number";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                          onSaved: (val) => phoneNumber = val,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                              color: LIGHT_GREY_TEXT,),),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                          ),
                          onChanged: (val) {
                            setState(() {
                              phoneNumber = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          YOUR_QUERY_TOPIC,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),),),
                        TextFormField(
                          validator: (val) {
                            if (val.isEmpty) {
                              return "ادخل موضوع الاستعلام الخاص بك";
                            }
                            return null;
                          },
                          onSaved: (val) => querytopic = val,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                              color: LIGHT_GREY_TEXT,),),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                          ),
                          onChanged: (val) {
                            setState(() {
                              querytopic = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          MESSAGE,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),),),
                        TextFormField(
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Enter your message";
                            }
                            return null;
                          },
                          maxLines: 4,
                          minLines: 1,
                          onSaved: (val) => Message = val,
                          style:GoogleFonts.cairo(
                            textStyle: TextStyle(
                              color: LIGHT_GREY_TEXT,),),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                              color: LIGHT_GREY_TEXT,
                              width: 0.5,
                            )),
                          ),
                          onChanged: (val) {
                            setState(() {
                              Message = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          button(),
        ],
      ),
    );
  }

  button() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              if (formKey.currentState.validate()) {
                formKey.currentState.save();
                submit();
              }
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: LIME,
              ),
              child: Center(
                child: Text(
                  SUBMIT,
                  style:GoogleFonts.cairo(
                  textStyle:  TextStyle(
                      color: WHITE, fontWeight: FontWeight.w700, fontSize: 17),
                  ),

    ),


              ),
            ),
          ),
        )
      ],
    );
  }

  submit() async {
    processingDialog(PLEASE_WAIT_FOR_A_WHILE);
    Response response;
    Dio dio = new Dio();

    FormData formData = FormData.fromMap({
      "name": name,
      "email": emailAddress,
      "topic": querytopic,
      "phone": phoneNumber,
      "message": Message,
    });
    response =
        await dio.post(SERVER_ADDRESS + "/api/contactus", data: formData);
    if (response.statusCode == 200 && response.data['status'] == 1) {
      print(response.toString());
      Navigator.pop(context);
      messageDialog(DONE, response.data['msg']);
    } else {
      Navigator.pop(context);
      print("Error" + response.toString());
      errorDialog(response.data['msg']);
    }
  }

  errorDialog(message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Icon(
                  Icons.error,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  message,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        });
  }

  processingDialog(message) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(LOADING),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 14),
                  ),
                )
              ],
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
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(backgroundColor: LIME),
                child: Text(
                  OK,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                  ),
                ),
              ),
            ],
          );
        });
  }

  loadInfo() async {
    await SharedPreferences.getInstance().then((value) {
      setState(() {
        nameController = TextEditingController(text: value.getString("name"));
        emailController = TextEditingController(text: value.getString("email"));
        phoneController =
            TextEditingController(text: value.getString("phone_no"));
        id = value.getInt("id");
      });
    });
    print("Data loaded");
  }
}

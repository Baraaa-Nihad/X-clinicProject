import 'dart:io';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/screens/ForgetPassword.dart';
import 'package:singleclinic/screens/SignUpScreen.dart';
import 'package:singleclinic/services/AuthService.dart';
import '../AllText.dart';
import '../main.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String name = "";
  String email = "";
  String password = "";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String image = "";

  @override
  Widget build(BuildContext context) {
    return   Directionality(
        textDirection: TextDirection.rtl, child: SafeArea(
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: WHITE,
          flexibleSpace: header(),
          leading: Container(),
        ),
        body: body(),
      ),
    )
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/X-clinic.png",
                  height: 40,
                  width: 40,
                ),
                SizedBox(width: 5,),
                Text(
                  LOGIN,
                   style:GoogleFonts.cairo(
                  textStyle:  TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:BLACK),
                ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                EMAIL_ADDRESS,
                style:GoogleFonts.cairo(
                  textStyle:  TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:BLACK),
                ),
              ),

              TextFormField(
                validator: (val) {
                  if (!EmailValidator.validate(email)) {
                    return "أدخل بريد الكتروني صالح";
                  }
                  return null;
                },
                onSaved: (val) => email = val,
                style:GoogleFonts.cairo(
                  textStyle:  TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:LIGHT_GREY_TEXT),
                ),


                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  isCollapsed: true,
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                ),
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                PASSWORD,
                style:GoogleFonts.cairo(
                  textStyle:  TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:BLACK),
                ),
              ),
              TextFormField(
                validator: (val) {
                  if (val.isEmpty) {
                    return "أدخل كلمة المرور";
                  }
                  return null;
                },
                onSaved: (val) => password = val,
                style:GoogleFonts.cairo(
                  textStyle:  TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:BLACK),
                ),



                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  isCollapsed: true,
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                ),
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgetPassword()));
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    FORGET_PASSWORD,
                    style:GoogleFonts.cairo(
                      textStyle:  TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color:NAVY_BLUE),
                    ),


                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (formKey.currentState.validate()) {
                          formKey.currentState.save();
                          loginIntoAccount(1);
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
                            LOGIN,
                            style:GoogleFonts.cairo(
                              textStyle:  TextStyle(
                                  color: WHITE,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17),

                          ),

                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ليس لديك حساب ؟",
                style:GoogleFonts.cairo(
                  textStyle: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 12)
                ),


                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },

                    child: Text(
                      " تسجيل حساب جديد",
                      style:GoogleFonts.cairo(
                          textStyle: TextStyle(color: NAVY_BLUE, fontSize: 14,fontWeight: FontWeight.bold)
                      ),


                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: LIGHT_GREY_TEXT,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "أو",
                    style:GoogleFonts.cairo(
                        textStyle: TextStyle(
                            color: LIGHT_GREY_TEXT,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                    ),


                  ),


                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Divider(
                      color: LIGHT_GREY_TEXT,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Row(
              //   children: [
                  // Expanded(
                  //   child: InkWell(
                  //     borderRadius: BorderRadius.circular(50),
                  //     onTap: () {
                  //       facebookLogin();
                  //     },
                  //     child: Container(
                  //       margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  //       height: 50,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(25),
                  //         color: NAVY_BLUE.withOpacity(0.7),
                  //       ),
                  //       child: Stack(
                  //         children: [
                  //           Row(
                  //             children: [
                  //               Expanded(
                  //                 child: Image.asset(
                  //                   "assets/loginregister/facebook_btn.png",
                  //                   fit:BoxFit.cover,
                                    
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           Center(
                  //             child: Text(
                  //               CONTINUE_WITH_FACEBOOK,
                  //               style:GoogleFonts.cairo(
                  //                   textStyle:TextStyle(
                  //                       color: WHITE,
                  //                       fontSize: 15,
                  //                       fontWeight: FontWeight.bold),
                  //               ),
                  //               ),



                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // )
              //   ],
              // ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        googleLogin();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: NAVY_BLUE.withOpacity(0.7),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    "assets/loginregister/google_btn.png",
                                    fit: BoxFit.cover,
                                   
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: Text(
                                CONTINUE_WITH_GOOGLE,
                                style:GoogleFonts.cairo(
                                  textStyle:TextStyle(
                                      color: WHITE,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Platform.isIOS
                  ? Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: NAVY_BLUE.withOpacity(0.7),
                            ),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Image.asset(
                                        "assets/loginregister/appleid.png",
                                      ),
                                    ),
                                  ],
                                ),


                                Center(
                                  child: Text(
                                    CONTINUE_WITH_APPLE_ID,
                                    style: TextStyle(
                                        color: WHITE,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),




                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
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
                  message.toString(),
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

  loginIntoAccount(int type) async {
    processingDialog(PLEASE_WAIT_WHILE_LOGGING_INTO_ACCOUNT);
    Response response;
    Dio dio = new Dio();

    FormData formData = type == 1
        ? FormData.fromMap({
            "email": email,
            "password": password,
            "device_token": await firebaseMessaging.getToken(),
            "device_type": "$type",
          })
        : FormData.fromMap({
            "name": name,
            "email": email,
            "image": image,
            "device_token": await firebaseMessaging.getToken(),
            "device_type": "$type",
          });
    response = await dio
        .post(
            SERVER_ADDRESS +
                "/api/userlogin?login_type=$type&device_token=${await firebaseMessaging.getToken()}&device_type=1&email=$email",
            data: formData)
        .catchError((e) {
      print("ERROR : $e");
      if (type == 2) {
        googleLogin();
      } else {
        Navigator.pop(context);
        print("Error" + e.toString());
        errorDialog(e.toString());
      }
    });

    print(response.realUri);
    print(response.data);

    if (response != null &&
        response.statusCode == 200 &&
        response.data['status'] == 1) {
      print(response.toString());
      FirebaseDatabase.instance
          .reference()
          .child(response.data['data']['id'].toString())
          .update({
        "name": response.data['data']['name'],
        "usertype": response.data['data']['usertype'],
        "profile": response.data['data']['usertype'].toString() == "1"
            ? "profile/" +
                response.data['data']['profile_pic'].toString().split("/").last
            : "doctor/" +
                response.data['data']['profile_pic'].toString().split("/").last,
      }).then((value) async {
        print("\n\nData added in cloud firebase\n\n");
        FirebaseDatabase.instance
            .reference()
            .child(response.data['data']['id'].toString())
            .child("TokenList")
            .set({"device": await firebaseMessaging.getToken()}).then(
                (value) async {
          print("\n\nData added in firebase database\n\n");
          await SharedPreferences.getInstance().then((value) {
            value.setBool("isLoggedIn", true);
            value.setString("name", response.data['data']['name'] ?? "");
            value.setString("email", response.data['data']['email'] ?? "");
            value.setString(
                "phone_no", response.data['data']['phone_no'] ?? "");
            value.setString("password", password ?? "");
            value.setString(
                "profile_pic", response.data['data']['profile_pic'] ?? "");
            value.setInt("id", response.data['data']['id']);
            value.setString("usertype", response.data['data']['usertype']);
            value.setString("uid", response.data['data']['id'].toString());
          });

          print("\n\nData added in device\n\n");

          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TabBarScreen(),
              ));
        }).catchError((e) {
          Navigator.pop(context);
        });
      }).catchError((e) {
        Navigator.pop(context);
      });
    } else {
      Navigator.pop(context);
      print("Error" + response.toString());
    }
  }

  facebookLogin() async {
    dynamic result = await AuthService.facebookLogin();

    if (result != null) {
      if (result is String) {
        errorDialog('${result}');
      } else if (result is Map) {
        
        setState(() {
          name = result['name'];
          email = result['email'] ?? "null";
          image = result['profile'] ?? " ";
        });
        loginIntoAccount(3);
      } else {
        errorDialog('حدث خطأ ما اثناء تسجيل الدخول');
      }
    } else {
      errorDialog('حدث خطأ ما اثناء تسجيل الدخول');
    }
  }

  googleLogin() async {
    await _googleSignIn.signIn().then((value) {
      value.authentication.then((googleKey) {
        print(googleKey.idToken);
        print(googleKey.accessToken);
        print(value.email);
        print(value.displayName);
        print(value.photoUrl);
        setState(() {
          name = value.displayName;
          email = value.email;
          image = value.photoUrl;
        });

        loginIntoAccount(2);
      }).catchError((e) {
        print(e.toString());
        errorDialog(e.toString());
      });
    }).catchError((e) {
      print(e.toString());
      errorDialog(e.toString());
    });
  }
}

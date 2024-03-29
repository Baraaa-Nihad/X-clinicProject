import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:singleclinic/main.dart';
import 'package:http/http.dart' as http;
import '../AllText.dart';
import 'package:google_fonts/google_fonts.dart';
class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String email = "";
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: WHITE,
              flexibleSpace: header(),
              elevation: 0,
            ),
            body: body(),
          ),
        ));
  }

  body() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          SizedBox(
            height: 40,
          ),
          Image.asset(
            "assets/X-clinic.png",
            height: 170,
            width: 170,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  ENTER_THE_EMAIL_ADDRESS_ASSOCIATED_WITH_YOUR_ACCOUNT,
                  style:GoogleFonts.cairo(
                    textStyle:TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: BLACK,),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  WE_WILL_EMAIL_YOU_A_LINK_TO_RESET_YOUR_PASSWORD,
                  style:GoogleFonts.cairo(
                    textStyle:TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, color: LIGHT_GREY_TEXT,),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                validator: (val) {
                  if (val.isEmpty) {
                    return "Enter your email";
                  } else if (!EmailValidator.validate(val)) {
                    return "Enter valid email address";
                  }
                  return null;
                },
                onSaved: (val) => email = val,
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.all(5),
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                  disabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: LIGHT_GREY_TEXT, width: 0.5)),
                ),
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          button()
        ],
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
                    color: BLACK,
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
                  FORGET_PASSWORD,
                  style:GoogleFonts.cairo(
                    textStyle:TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: NAVY_BLUE,),
                  ),

                ),
              ],
            ),
          ),
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
                callApi();
              }
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(25, 5, 25, 15),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: LIME,
              ),
              child: Center(
                child: Text(
                  SEND,
                  style:GoogleFonts.cairo(
                    textStyle:TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: WHITE,),
                  ),

                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  callApi() async {
    processingDialog('Please wait while sending email');

    var request = http.Request(
        'GET', Uri.parse('$SERVER_ADDRESS/api/forgotpassword?email=${email}'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      
      /*   if(jsonResponse['status'] == 0){
        errorDialog(jsonResponse['msg']);
      }else{
        messageDialog(SUCCESSFUL, jsonResponse['msg']);
      }*/
      if (jsonResponse['msg'] == 'Email Not Found') {
        Navigator.pop(context);
        messageDialog("خطأ", "الايميل غير موجود");
      } else {
        Navigator.pop(context);
        messageDialog(
            "حسنا", "سيتم ارسال رسالة بها كلمة السر الجديدة الى ايميلك ");
      }
    } else {
      print(response.reasonPhrase);
      errorDialog(response.reasonPhrase);
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
                    style:GoogleFonts.cairo(
                      textStyle:TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700, color: LIGHT_GREY_TEXT,),
                    ),

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
              style:GoogleFonts.cairo(
                textStyle:TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: LIGHT_GREY_TEXT,),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style:GoogleFonts.cairo(
                    textStyle:TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: LIGHT_GREY_TEXT,),
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
                style: TextButton.styleFrom(
                  backgroundColor: LIME,
                ),
                child: Text(
                  OK,
                  style:GoogleFonts.cairo(
                    textStyle:TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: LIGHT_GREY_TEXT,),
                  ),
                ),
              ),
            ],
          );
        });
  }
}

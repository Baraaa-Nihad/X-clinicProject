import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';

import '../main.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  String name = "";
  TextEditingController nameController;
  String emailAddress = "";
  TextEditingController emailController;
  String phoneNumber = "";
  TextEditingController phoneController;
  String password = "";
  TextEditingController passController;
  TextEditingController confirmPassController;
  String confirmPassword = "";
  String path = "";
  String imageUrl = "";
  int id;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {
      setState(() {
        imageUrl = value.getString("profile_pic");
        id = value.getInt("id");
        nameController = TextEditingController(text: value.getString("name"));
        emailController = TextEditingController(text: value.getString("email"));
        phoneController =
            TextEditingController(text: value.getString("phone_no"));
        password = confirmPassword = value.getString("password");
        passController =
            TextEditingController(text: value.getString("password"));
        confirmPassController =
            TextEditingController(text: value.getString("password"));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          backgroundColor: WHITE,
          flexibleSpace: header(),
          elevation: 0,
        ),
        body: body(),
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
                  PROFILE_UPDATE,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: Container(
                              height: 140,
                              width: 140,
                              child: path.isEmpty
                                  ? CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: Uri.parse(imageUrl).toString(),
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Container(
                                                  child: Center(
                                                      child: Icon(
                                        Icons.account_circle,
                                        size: 140,
                                        color: LIGHT_GREY_TEXT,
                                      ))),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        child: Center(
                                          child: Icon(
                                            Icons.account_circle,
                                            size: 140,
                                            color: LIGHT_GREY_TEXT,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      File(path),
                                      height: 140,
                                      width: 140,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Container(
                            height: 137,
                            width: 137,
                            child: InkWell(
                              onTap: () {
                                showSheet();
                              },
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Image.asset(
                                  "assets/loginregister/edit.png",
                                  height: 35,
                                  width: 35,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        TextFormField(
                          controller: nameController,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Enter your name";
                            }
                            return null;
                          },
                          onSaved: (val) => name = val,
                          style: TextStyle(
                            color: LIGHT_GREY_TEXT,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(5),
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        IgnorePointer(
                          ignoring: emailController.text != 'null',
                          child: TextFormField(
                            controller: emailController,
                            validator: (val) {
                              if (val.isEmpty) {
                                return "Enter your email address";
                              } else if (!EmailValidator.validate(val)) {
                                return "Enter correct email";
                              }
                              return null;
                            },
                            onSaved: (val) => emailAddress = val,
                            style: TextStyle(
                              color: LIGHT_GREY_TEXT,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              contentPadding: EdgeInsets.all(5),
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
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          PHONE_NUMBER,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
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
                          style: TextStyle(
                            color: LIGHT_GREY_TEXT,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(5),
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
                          PASSWORD,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        TextFormField(
                          controller: passController,
                          obscureText: true,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Enter your password";
                            }
                            return null;
                          },
                          onSaved: (val) => password = val,
                          style: TextStyle(
                            color: LIGHT_GREY_TEXT,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(5),
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
                              password = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          CONFIRM_PASSWORD,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        TextFormField(
                          controller: confirmPassController,
                          obscureText: true,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Enter your password";
                            } else if (val != password) {
                              return "Password mismatch";
                            }
                            return null;
                          },
                          onSaved: (val) => confirmPassword = val,
                          style: TextStyle(
                            color: LIGHT_GREY_TEXT,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(5),
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
                              confirmPassword = val;
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
                updateProfile();
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
                  UPDATE,
                  style: TextStyle(
                      color: WHITE,
                      fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  final picker = ImagePicker();

  Future getImage({bool fromGallery = false}) async {
    final pickedFile = await picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        setState(() {
          path = File(pickedFile.path).path;
        });
      } else {
        print('No image selected.');
      }
    });
  }

  updateProfile() async {
    processingDialog(PLEASE_WAIT_WHILE_UPDATING_PROFILE);
    Response response;
    Dio dio = new Dio();

    print(emailAddress);
    print(id.toString());

    FormData formData = path.isEmpty
        ? FormData.fromMap({
            "user_id": id.toString(),
            "name": name,
            "email": emailAddress,
            "password": password,
            "phone": phoneNumber,
          })
        : FormData.fromMap({
            "user_id": id.toString(),
            "name": name,
            "email": emailAddress,
            "password": password,
            "phone": phoneNumber,
            "image": await MultipartFile.fromFile(path, filename: "upload.jpg"),
          });

    response =
        await dio.post(SERVER_ADDRESS + "/api/editprofile", data: formData);

    print(response.realUri);

    if (response.statusCode == 200 && response.data['status'] == 1) {
      print(response.toString());

      await SharedPreferences.getInstance().then((value) {
        value.setString("name", response.data['data']['name']);
        value.setString("email", response.data['data']['email']);
        value.setString("phone_no", response.data['data']['phone_no']);
        value.setString("profile_pic", response.data['data']['profile_pic']);
        value.setString("password", response.data['data']['new_password']);
      });

      Navigator.pop(context);
      Navigator.pop(context, true);
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

  showSheet() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  TAKE_A_PICTURE,
                ),
                leading: CircleAvatar(
                  backgroundColor: LIME,
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: WHITE,
                    ),
                  ),
                ),
                subtitle: Text(
                  TAKE_A_PICTURE_DESC,
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  getImage(fromGallery: false);
                },
              ),
              ListTile(
                title: Text(
                  PICK_FROM_GALLERY,
                ),
                leading: CircleAvatar(
                  backgroundColor: LIME,
                  child: Center(
                    child: Icon(
                      Icons.photo,
                      color: WHITE,
                    ),
                  ),
                ),
                subtitle: Text(
                  PICK_FROM_GALLERY_desc,
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  getImage(fromGallery: true);
                },
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
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
                            CANCEL,
                            style: TextStyle(
                              color: WHITE,
                                fontWeight: FontWeight.w700, fontSize: 17),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
        });
  }
}

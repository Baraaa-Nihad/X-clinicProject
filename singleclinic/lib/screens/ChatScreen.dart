import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:singleclinic/chatModule/MyPhotoViewer.dart';
import 'package:singleclinic/chatModule/MyVideoPlayer.dart';
import 'package:singleclinic/chatModule/MyVideoThumbnail.dart';
import 'package:singleclinic/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String userName;
  final String uid;
  final String userProfile;

  ChatScreen(this.userName, this.uid, {this.userProfile = ""});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  int listCount = 0;
  bool showButton = false;
  String myUid;
  String globalMessage = "";
  String channelId;
  String message = "";
  ScrollController _lvScrollCtrl = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  int perPage = 20;
  bool isLoading = false;
  bool showLoadingIndicator = false;
  bool isUserOnline = false;
  String userStatus = "";
  TextField textField;
  String lastMessageDate;
  DateTime dateTimeNext;
  int myMessages = 0;
  int yourMessages = 0;
  Timestamp timestamp;
  String lastMessageUid = "";
  String myName = "";
  bool isSeenStatusExist = false;
  FilePickerResult file;
  Uint8List image;
  String trimmedVideoPath;
  File croppedFile;
  VideoPlayerController videoPlayerController;

  bool isFileUploading = false;
  double uploadingProgress = 0.0;
  Uint8List fileThumbnail;
  String myProfilePicture = "";
  bool isFirstMessage = false;
  List<String> monthsList = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  Future future;
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  final DatabaseReference databaseReference2 =
      FirebaseDatabase.instance.reference();
  final DatabaseReference databaseReference3 =
      FirebaseDatabase.instance.reference();
  FlutterUploader uploader = FlutterUploader();

  Map<String, StreamSubscription> _resultSubscription = {};

  Map<String, UploadItem> _tasks = {};
  var ds;
  bool isTyping = false;
  String imageLink = "";
  Timer timer = Timer(Duration(seconds: 1), () {});
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String token = "";
  String name = "";
  List<String> tokensList = [];
  int requestStatus;
  DatabaseReference seenRef;
  var seenRefListner;
  var checkSeenRefListner;
  int messageCount = 0;
  List<String> pendingMessagesList = [];
  bool showLoading = true;
  String currentTime;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getCurrentTime();
    loadUserProfile();
    doesSendNotification(widget.uid, false);
    print(widget.uid);
    getMyUid();
    _lvScrollCtrl.addListener(() {
      if (_lvScrollCtrl.position.maxScrollExtent ==
          _lvScrollCtrl.position.pixels) {
        setState(() {
          showLoadingIndicator = true;
          perPage += 20;
          print(showLoadingIndicator);
        });
      }
    });
    checkSeenStatus();
    getUserPreference();
    markAsSeen();
    SharedPreferences.getInstance().then((value) {
      value.remove("payload");
      print("0-> Chat Screen Payload : ${value.getString("payload")}");
    });

    uploader.result.listen((result) {
      if (result.response != null) {
        if (result.response != null) {
          print(
              'IN MAIN APP RESULT: ${result.response} \nFOR: ${result.taskId}');
        }
        var tmp = <String, UploadItem>{}..addAll(_tasks);
        tmp.putIfAbsent(result.taskId, () => UploadItem());

        uploadDataWithBackgroundService(result.taskId, result);
      }
    }, onError: (ex, stacktrace) {
      print('exception: $ex');
      print('stacktrace: $stacktrace');
    });
    super.initState();
  }

  getCurrentTime() async {
    // await FirebaseDatabase.instance.reference().child("currenttime").get().then((value){
    //   print('CURRENT TIME : ${value.value}');
    //   currentTime = value.value['time'];
    // print('CURRENT TIME : $currentTime');
    currentTime = DateTime.now().toString();

    // });
  }

  String getSendMessageTime() {
    print('CURRENT TIME : $currentTime');
    Duration duration =
        DateTime.now().difference(DateTime.parse(currentTime.toString()));
    return DateTime.parse(currentTime.toString())
        .add(duration)
        .toUtc()
        .toString();
  }

  loadUserProfile() async {
    await FirebaseDatabase.instance
        .reference()
        .child(widget.uid.toString())
        .once()
        .then((value) {
      print("loading " + widget.uid.toString());
      setState(() {
        imageLink = SERVER_ADDRESS +
            "/public/upload/" +
            value.value['profile'].toString();
        print("loaduserprofile" +
            SERVER_ADDRESS +
            "/public/upload/" +
            value.value['profile'].toString());
      });
    }).catchError((e) {});

    await FirebaseDatabase.instance
        .reference()
        .child(widget.uid)
        .child("TokenList")
        .once()
        .then((value) {
      print("----------> " + value.value.toString());
      if (value.value != null) {
        Map<dynamic, dynamic>.from(value.value).forEach((key, values) {
          setState(() {
            tokensList.add(value.value[key].toString());
          });
        });
      }
    });
    print("Test " + widget.uid.toString());
    print("Test " + myUid.toString());

    await FirebaseDatabase.instance
        .reference()
        .child(myUid)
        .once()
        .then((value) {
      if (mounted) {
        setState(() {
          name = value.value['name'].toString();
        });
      }
    });

    await FirebaseDatabase.instance
        .reference()
        .child(myUid)
        .child("chatlist")
        .child(widget.uid)
        .once()
        .then((value) {
      print("----------> " + value.value.toString());
      if (value.value != null) {
        if (mounted) {
          setState(() {
            requestStatus = value.value['status'] ?? 1;
          });
        }
      } else {
        setState(() {
          requestStatus = 1;
        });
      }
    });
  }

  uploadDataWithBackgroundService(String taskId, result) async {
    String timeNow = "";

    DatabaseReference dbRef = FirebaseDatabase.instance
        .reference()
        .child("currenttime")
        .child("time");
    dbRef.once().then((value) async {
      print("got ref");
      timeNow = value.value;

      CollectionReference collectionReference = FirebaseFirestore.instance
          .collection("Chats")
          .doc(channelId)
          .collection("All Chat");

      await collectionReference.doc(taskId.toString()).update({
        "msg": jsonDecode(result.response)['data'],
        "time": timeNow,
        "uid": myUid,
        "type": jsonDecode(result.response)['data'].toString().contains(".jpg")
            ? 1
            : 2,
      });

      if (isFirstMessage) {
        DatabaseReference dbRef = FirebaseDatabase.instance
            .reference()
            .child(myUid)
            .child("chatlist")
            .child(widget.uid);

        await dbRef.set({
          "time": timeNow,
          "last_msg": jsonDecode(result.response)['data'],
          "type":
              jsonDecode(result.response)['data'].toString().contains(".jpg")
                  ? 1
                  : 2,
          "messageCount": 0,
          "status": 1,
          "channelId": channelId
        });

        DatabaseReference dbRef2 = FirebaseDatabase.instance
            .reference()
            .child(widget.uid)
            .child("chatlist")
            .child(myUid);

        await dbRef2.once().then((value) {
          dbRef2.set({
            "time": timeNow,
            "last_msg": jsonDecode(result.response)['data'],
            "type":
                jsonDecode(result.response)['data'].toString().contains(".jpg")
                    ? 1
                    : 2,
            "messageCount":
                value.value == null ? 1 : value.value['messageCount'] + 1,
            "status": 0,
            "channelId": channelId
          });
        });
        setState(() {
          isFirstMessage = false;
        });
      } else {
        DatabaseReference dbRef = FirebaseDatabase.instance
            .reference()
            .child(myUid)
            .child("chatlist")
            .child(widget.uid);

        await dbRef.update({
          "time": timeNow,
          "last_msg": jsonDecode(result.response)['data'],
          "type":
              jsonDecode(result.response)['data'].toString().contains(".jpg")
                  ? 1
                  : 2,
          "messageCount": 0,
          "channelId": channelId
        });

        DatabaseReference dbRef2 = FirebaseDatabase.instance
            .reference()
            .child(widget.uid)
            .child("chatlist")
            .child(myUid);

        await dbRef2.once().then((value) {
          dbRef2.update({
            "time": timeNow,
            "last_msg": jsonDecode(result.response)['data'],
            "type":
                jsonDecode(result.response)['data'].toString().contains(".jpg")
                    ? 1
                    : 2,
            "messageCount":
                value.value == null ? 1 : value.value['messageCount'] + 1,
            "channelId": channelId
          });
        });
      }
    });

    for (int i = 0; i < tokensList.length; i++) {
      sendNotification(name, "Shared a file", tokensList[i]);
    }

    _resultSubscription['$taskId']?.cancel();
  }

  getMyUid() async {
    print("\n\n\n\n\n\n${widget.uid}\n\n\n\n\n\n");

    await SharedPreferences.getInstance().then((value) {
      setState(() {
        myUid = value.getString("uid");
        myProfilePicture = value.getString("profile_pic");
      });
    });
    if (widget.uid.compareTo(myUid) < 0) {
      setState(() {
        channelId = widget.uid + myUid;
      });
    } else {
      setState(() {
        channelId = myUid + widget.uid;
      });
    }
    print("channelId : " + channelId + "   $myUid" + "   ${widget.uid}");

    markAsSeen();
  }

  getMyName(myUid) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(myUid)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          myName = value['name'];
        });
      }
    });
  }

  getUserPreference() {
    ds =
        databaseReference2.child(widget.uid.toString()).onValue.listen((event) {
      setState(() {
        if (event.snapshot.value != null) {
          if (event.snapshot.value['presence'] != null) {
            if (event.snapshot.value['presence']) {
              userStatus = "Online";
            } else {
              print("last seen ${event.snapshot.value['last_seen']}");
              userStatus =
                  "last seen ${DateTime.parse(event.snapshot.value['last_seen']).toLocal().toString().substring(0, 19)}";
            }
          }
        }
      });
    });

    databaseReference3
        .child(myUid.toString())
        .child("chatlist")
        .child(widget.uid)
        .child("typing")
        .onValue
        .listen((event) {
      if (event.snapshot.value == 1) {
        setState(() {
          isTyping = true;
          showLoading = false;
        });
      } else {
        setState(() {
          isTyping = false;
          showLoading = false;
        });
      }
    });
  }

  getTypingStatus() {
    setState(() {
      timer.cancel();
      isTyping = true;
      timer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          isTyping = false;
        });
      });
    });
  }

  Timer markTypingAsZerotimer = Timer(Duration(seconds: 1), () {});

  void markAsTyping() {
    DatabaseReference db = FirebaseDatabase.instance.reference();
    db.child(widget.uid).child("chatlist").child(myUid).update(
      {"typing": 1},
    );

    db
        .child(widget.uid)
        .child("chatlist")
        .child(myUid)
        .child("typing")
        .onValue
        .listen((event) {
      markTypingAsZerotimer.cancel();
      if (event.snapshot.value == 1) {
        markTypingAsZerotimer = Timer(Duration(seconds: 1), () {
          db.child(widget.uid).child("chatlist").child(myUid).update(
            {"typing": 0},
          );
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    ds.cancel();
    seenRefListner.cancel();
    checkSeenRefListner.cancel();
    doesSendNotification(widget.uid, true);
    print("On dispose called");
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Toast.show("resumed", context);
      getUserPreference();
      checkSeenStatus();
      doesSendNotification(widget.uid, true);
    } else {
      ds.cancel();
      seenRefListner.cancel();
      checkSeenRefListner.cancel();
      doesSendNotification(widget.uid, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY,
        body: requestStatus == null
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  header(
                      widget.userName,
                      showLoading
                          ? "Loading..."
                          : isTyping
                              ? "Typing..."
                              : userStatus,
                      imageLink),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Chats/$channelId/All Chat")
                            .orderBy("time", descending: true)
                            .limit(perPage)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data.docs.length > 0) {
                            return Container(
                              child: ListView.builder(
                                controller: _lvScrollCtrl,
                                reverse: true,
                                itemCount: snapshot.data.docs.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  if (index == snapshot.data.docs.length) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        snapshot.data.docs.length > 20) {
                                      print("\n\nwaiting : loaded");

                                      return Container();
                                    } else if (snapshot.connectionState ==
                                            ConnectionState.active &&
                                        snapshot.data.docs.length > 20) {
                                      print("\n\nactive : Loading " +
                                          snapshot.hasData.toString());
                                      isLoading = true;
                                      Timer(Duration(seconds: 3), () {
                                        setState(() {
                                          isLoading =
                                              showLoadingIndicator = false;
                                        });
                                      });
                                      return isLoading
                                          ? Container(
                                              margin: EdgeInsets.all(30),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container();
                                    } else if (snapshot.data.docs.length > 20) {
                                      print(snapshot.connectionState);
                                      return Container(
                                        margin: EdgeInsets.all(0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.grey),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  } else if (index <
                                      snapshot.data.docs.length) {
                                    lastMessageUid =
                                        snapshot.data.docs[index]['uid'];
                                    lastMessageDate = snapshot
                                        .data.docs[index]['time']
                                        .toString();

                                    int k = snapshot.data.docs.length > index
                                        ? index + 1
                                        : snapshot.data.docs.length - 1;
                                    print("hhhh " +
                                        snapshot.data.docs[index]['time']
                                            .toString());

                                    int daysDifference = DateTime.now()
                                        .difference(DateTime.parse(snapshot.data.docs[index]['time']!=null?snapshot.data.docs[index]['time']:"2022-07-28 12:24:45.101440" +
                                                "Z")
                                            .toLocal())
                                        .inDays;
                                    int daysDifference2 = k >=
                                            snapshot.data.docs.length
                                        ? 3
                                        : DateTime.now()
                                            .difference(DateTime.parse(snapshot.data.docs[index]['time']!=null?snapshot.data.docs[index]['time']:"2022-07-28 12:24:45.101440" +
                                                    "Z")
                                                .toLocal())
                                            .inDays;
                                    print(
                                        "days difference : $daysDifference days difference 2 : $daysDifference2");

                                    return Column(
                                      children: [
                                        k >= snapshot.data.docs.length
                                            ? (daysDifference2 -
                                                        daysDifference) >=
                                                    1
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: Divider(
                                                          height: 10,
                                                          thickness: 0.5,
                                                          color:
                                                              LIGHT_GREY_TEXT,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        daysDifference == 0
                                                            ? "Today"
                                                            : daysDifference ==
                                                                    1
                                                                ? "Yesterday"
                                                                : "${DateTime.now().add(Duration(days: -daysDifference)).day}  ${monthsList[DateTime.now().add(Duration(days: -daysDifference)).month - 1]}, ${DateTime.now().add(Duration(days: -daysDifference)).year}",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                LIGHT_GREY_TEXT),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Divider(
                                                          height: 30,
                                                          thickness: 0.5,
                                                          color:
                                                              LIGHT_GREY_TEXT,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container()
                                            : lastMessageDate.compareTo(snapshot
                                                        .data.docs[k]['time']
                                                        .toString()) ==
                                                    0
                                                ? Container()
                                                : (daysDifference2 -
                                                            daysDifference) >=
                                                        1
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                            child: Divider(
                                                              height: 10,
                                                              thickness: 0.5,
                                                              color:
                                                                  LIGHT_GREY_TEXT,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            daysDifference == 0
                                                                ? "Today"
                                                                : daysDifference ==
                                                                        1
                                                                    ? "Yesterday"
                                                                    : "${DateTime.now().add(Duration(days: -daysDifference)).day}  ${monthsList[DateTime.now().add(Duration(days: -daysDifference)).month - 1]}, ${DateTime.now().add(Duration(days: -daysDifference)).year}",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    LIGHT_GREY_TEXT),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: Divider(
                                                              height: 30,
                                                              thickness: 0.5,
                                                              color:
                                                                  LIGHT_GREY_TEXT,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                        snapshot.data.docs[index]['uid'] == myUid
                                            ? myMessageCard(
                                                msg: snapshot.data.docs[index]
                                                    ['msg'],
                                                time: DateTime.parse(snapshot.data.docs[index]['time']!=null?snapshot.data.docs[index]['time']:"2022-07-28 12:24:45.101440" + "Z").toLocal().minute > 10
                                                    ? DateTime.parse(snapshot.data.docs[index]['time']!=null?snapshot.data.docs[index]['time']:"2022-07-28 12:24:45.101440" + "Z").toLocal().hour.toString() +
                                                        ":" +
                                                        DateTime.parse(snapshot.data.docs[index]['time']!=null?snapshot.data.docs[index]['time']:"2022-07-28 12:24:45.101440" + "Z")
                                                            .toLocal()
                                                            .minute
                                                            .toString()
                                                    : DateTime.parse(snapshot.data.docs[index]['time']!=null?snapshot.data.docs[index]['time']:"2022-07-28 12:24:45.101440" + "Z").toLocal().hour.toString() +
                                                        ":" +
                                                        "0" +
                                                        DateTime.parse(snapshot.data.docs[index]['time']!=null?snapshot.data.docs[index]['time']:snapshot.data.docs[index]['time']!=null?snapshot.data.docs[index]['time']:"2022-07-28 12:24:45.101440" + "Z")
                                                            .toLocal()
                                                            .minute
                                                            .toString(),
                                                image: imageLink,
                                                snapshot: snapshot,
                                                index: index)
                                            : messageCard(
                                                msg: snapshot.data.docs[index]
                                                    ['msg'],
                                                time: DateTime.parse(snapshot.data.docs[index]['time'] + "Z").toLocal().minute > 10
                                                    ? DateTime.parse(snapshot.data.docs[index]['time'] + "Z").toLocal().hour.toString() +
                                                        ":" +
                                                        DateTime.parse(snapshot.data.docs[index]['time'] + "Z")
                                                            .toLocal()
                                                            .minute
                                                            .toString()
                                                    : DateTime.parse(snapshot.data.docs[index]['time'] + "Z").toLocal().hour.toString() + ":" + "0" + DateTime.parse(snapshot.data.docs[index]['time'] + "Z").toLocal().minute.toString(),
                                                image: imageLink,
                                                snapshot: snapshot,
                                                index: index),
                                      ],
                                    );
                                  } else {
                                    return LinearProgressIndicator();
                                  }
                                },
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data.docs.length == 0) {
                            print("its first message");
                            Future.delayed(Duration(seconds: 1), () {
                              setState(() {
                                isFirstMessage = true;
                              });
                            });
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No Conversations",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "You didn't made any conversation yet",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: LIGHT_GREY_TEXT),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey.shade100),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Say Hi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                )
                              ],
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ),
                  isSeenStatusExist
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 15, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "seen ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: LIGHT_GREY_TEXT,
                                    fontSize: 10),
                              ),
                              Container(
                                  height: 15,
                                  width: 15,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: imageLink,
                                      fit: BoxFit.cover,
                                      placeholder: (context, string) =>
                                          Container(
                                        height: 40,
                                        width: 40,
                                      ),
                                      errorWidget: (context, err, f) => Icon(
                                        Icons.account_circle,
                                        size: 35,
                                        color: LIGHT_GREY_TEXT,
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      : Container(),
                  isFileUploading
                      ? Container(
                          color: Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  child: Image.memory(
                                    fileThumbnail,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Sending File",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: LIGHT_GREY_TEXT),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      LinearProgressIndicator(
                                        minHeight: 2,
                                        value: uploadingProgress,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.cancel,
                                  color: LIGHT_GREY_TEXT,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  statusToWidget(requestStatus),
                ],
              ),
      ),
    );
  }

  Widget myMessageCard(
      {String msg, String time, String image, snapshot, index}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 10, 0, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minWidth: 50,
                            maxWidth: MediaQuery.of(context).size.width - 100,
                          ),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            color: LIME,
                          ),
                          child: typeToWidget(
                              int.parse(
                                  snapshot.data.docs[index]['type'].toString()),
                              snapshot.data.docs[index]['msg'],
                              snapshot.data.docs[index]['uid'],
                              snapshot.data.docs[index].id,
                              snapshot,
                              index),
                        ),
                        SvgPicture.string(
                          myMessageCorner,
                          color: LIME,
                          allowDrawingOutsideViewBox: true,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: LIGHT_GREY_TEXT,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  )
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CachedNetworkImage(
                height: 35,
                width: 35,
                fit: BoxFit.cover,
                imageUrl: myProfilePicture,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Container(
                        child: Center(
                            child: Icon(Icons.account_circle,
                                color: LIGHT_GREY_TEXT, size: 35))),
                errorWidget: (context, url, error) => Container(
                  child: Center(
                    child: Icon(
                      Icons.account_circle,
                      color: LIGHT_GREY_TEXT,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget messageCard({String msg, String time, String image, snapshot, index}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 15,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CachedNetworkImage(
                height: 35,
                width: 35,
                fit: BoxFit.cover,
                imageUrl: image,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Container(
                        child: Center(
                            child: Icon(Icons.account_circle,
                                color: LIGHT_GREY_TEXT, size: 35))),
                errorWidget: (context, url, error) => Container(
                  child: Center(
                    child: Icon(
                      Icons.account_circle,
                      color: LIGHT_GREY_TEXT,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 15, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.string(
                          messageCorner,
                          allowDrawingOutsideViewBox: true,
                        ),
                        Container(
                          constraints: BoxConstraints(
                            minWidth: 50,
                            maxWidth: MediaQuery.of(context).size.width - 100,
                          ),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: WHITE,
                          ),
                          child: typeToWidget(
                              int.parse(
                                  snapshot.data.docs[index]['type'].toString()),
                              snapshot.data.docs[index]['msg'],
                              snapshot.data.docs[index]['uid'],
                              snapshot.data.docs[index].id,
                              snapshot,
                              index),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: LIGHT_GREY_TEXT,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  String myMessageCorner =
      '<svg viewBox="300.0 357.7 13.3 10.3" ><path transform="translate(300.0, 357.0)" d="M 0 0.6566162109375 C 0 0.6566162109375 1.787620544433594 4.596710205078125 5.105804443359375 7.18255615234375 C 8.423988342285156 9.768402099609375 13.27273559570313 11 13.27273559570313 11 L 0 11 L 0 0.6566162109375 Z" fill="#e7d045" stroke="none" stroke-width="1" stroke-linecap="square" stroke-linejoin="bevel" /></svg>';

  String messageCorner =
      '<svg viewBox="300.0 357.7 12.7 10.3" ><path transform="translate(300.0, 357.0)" d="M 12.73681640625 0.6566162109375 C 12.73681640625 0.6566162109375 11.02137565612793 4.596710205078125 7.83717155456543 7.18255615234375 C 4.65296745300293 9.768402099609375 0 11 0 11 L 12.73681640625 11 L 12.73681640625 0.6566162109375 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-linecap="square" stroke-linejoin="bevel" /></svg>';

  scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lvScrollCtrl.animateTo(0.0,
          duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    });
  }

  void sendMessage(int type) async {
    String timeNow = getSendMessageTime().replaceAll("Z", "");

    String msg = message;

    setState(() {
      message = "";
      showButton = false;
      isSeenStatusExist = false;
    });

    textEditingController = TextEditingController(text: "");
    await FirebaseFirestore.instance
        .collection("Chats")
        .doc(channelId)
        .collection("All Chat")
        .add({
      "msg": msg,
      "time": timeNow,
      "uid": myUid,
      "type": type,
    }).then((value) {
      print("Message sent");
    });


    if (isFirstMessage) {
      DatabaseReference dbRef = FirebaseDatabase.instance
          .reference()
          .child(myUid)
          .child("chatlist")
          .child(widget.uid);

      await dbRef.set({
        "time": timeNow,
        "last_msg": msg,
        "type": type,
        "messageCount": 0,
        "status": 1,
        "channelId": channelId
      });

      DatabaseReference dbRef2 = FirebaseDatabase.instance
          .reference()
          .child(widget.uid)
          .child("chatlist")
          .child(myUid);

      await dbRef2.once().then((value) {
        dbRef2.set({
          "time": timeNow,
          "last_msg": msg,
          "type": type,
          "messageCount": value.value == null
              ? 1
              : value.value['messageCount'] == null
                  ? 1
                  : value.value['messageCount'] + 1,
          "status": 0,
          "channelId": channelId
        });
      });
      setState(() {
        isFirstMessage = false;
      });
    } else {
      DatabaseReference dbRef = FirebaseDatabase.instance
          .reference()
          .child(myUid)
          .child("chatlist")
          .child(widget.uid);

      await dbRef.update({
        "time": timeNow,
        "last_msg": msg,
        "type": type,
        "messageCount": 0,
        "channelId": channelId
      });

      DatabaseReference dbRef2 = FirebaseDatabase.instance
          .reference()
          .child(widget.uid)
          .child("chatlist")
          .child(myUid);

      await dbRef2.once().then((value) {
        dbRef2.update({
          "time": timeNow,
          "last_msg": msg,
          "type": type,
          "messageCount": value.value == null
              ? 1
              : value.value['messageCount'] == null
                  ? 1
                  : value.value['messageCount'] + 1,
          "channelId": channelId
        });
      });
    }

    print("message count : " + messageCount.toString());

    if (messageCount >= 0) {
      setState(() {
        globalMessage = globalMessage.isEmpty ? msg : globalMessage + "`" + msg;
      });
    }

    for (int i = 0; i < tokensList.length; i++) {
      sendNotification(name, globalMessage, tokensList[i]);
    }
  }

  void sendTask(int type, String taskId) async {
    String msg = message;
    String timeNow = "";
    DatabaseReference dbRef = FirebaseDatabase.instance
        .reference()
        .child("currenttime")
        .child("time");
    dbRef.once().then((value) async {
      print("got ref");
      timeNow = value.value;
      CollectionReference collectionReference = FirebaseFirestore.instance
          .collection("Chats")
          .doc(channelId)
          .collection("All Chat");
      await collectionReference.doc(taskId).set({
        "msg": msg,
        "time": timeNow,
        "uid": myUid,
        "type": type,
      });
    });
  }

  void deleteTask(String taskId) async {
    await FirebaseFirestore.instance
        .collection("Chats")
        .doc(channelId)
        .collection("All Chat")
        .doc(taskId)
        .delete();
  }

  void updateTaskToFile(int type, String taskId) async {
    String msg = message;
    String timeNow = "";
    setState(() {
      message = "";
      showButton = false;

      isSeenStatusExist = false;
    });

    DatabaseReference dbRef = FirebaseDatabase.instance
        .reference()
        .child("currenttime")
        .child("time");
    dbRef.once().then((value) async {
      print("got ref");
      timeNow = value.value;
      print("hhhh 1 " + timeNow);
      CollectionReference collectionReference = FirebaseFirestore.instance
          .collection("Chats")
          .doc(channelId)
          .collection("All Chat");
      await collectionReference.doc(taskId).set({
        "msg": msg,
        "time": timeNow,
        "uid": myUid,
        "type": type,
      });

      if (isFirstMessage) {
        DatabaseReference dbRef = FirebaseDatabase.instance
            .reference()
            .child(myUid)
            .child("chatlist")
            .child(widget.uid);

        await dbRef.set({
          "time": timeNow,
          "last_msg": msg,
          "type": type,
          "messageCount": 0,
          "status": 1,
          "channelId": channelId
        });

        DatabaseReference dbRef2 = FirebaseDatabase.instance
            .reference()
            .child(widget.uid)
            .child("chatlist")
            .child(myUid);

        await dbRef2.once().then((value) {
          dbRef2.set({
            "time": timeNow,
            "last_msg": msg,
            "type": type,
            "messageCount":
                value.value == null ? 1 : value.value['messageCount'] + 1,
            "status": 0,
            "channelId": channelId
          });
        });
        setState(() {
          isFirstMessage = false;
        });
      } else {
        DatabaseReference dbRef = FirebaseDatabase.instance
            .reference()
            .child(myUid)
            .child("chatlist")
            .child(widget.uid);

        await dbRef.update({
          "time": timeNow,
          "last_msg": msg,
          "type": type,
          "messageCount": 0,
          "channelId": channelId
        });

        DatabaseReference dbRef2 = FirebaseDatabase.instance
            .reference()
            .child(widget.uid)
            .child("chatlist")
            .child(myUid);

        await dbRef2.once().then((value) {
          dbRef2.update({
            "time": timeNow,
            "last_msg": msg,
            "type": type,
            "messageCount":
                value.value == null ? 1 : value.value['messageCount'] + 1,
            "channelId": channelId
          });
        });
      }
    });

    for (int i = 0; i < tokensList.length; i++) {
      sendNotification(name, "Shared a file", tokensList[i]);
    }
  }

  void markAsSeen() async {
    print("mark as seen");

    seenRef = FirebaseDatabase.instance
        .reference()
        .child(myUid.toString())
        .child('chatlist')
        .child(widget.uid.toString())
        .child("messageCount");
    seenRefListner = seenRef.onValue.listen((event) {
      seenRef.set(0);
      print("mark as seen set");
    });
  }

  checkSeenStatus() async {
    checkSeenRefListner = FirebaseDatabase.instance
        .reference()
        .child(widget.uid)
        .child('chatlist')
        .child(myUid.toString())
        .child("messageCount")
        .onValue
        .listen((event) {
      if (event.snapshot.value == 0) {
        setState(() {
          messageCount = event.snapshot.value;
          pendingMessagesList.clear();
          isSeenStatusExist = true;
          globalMessage = "";
        });
      } else {
        setState(() {
          messageCount = event.snapshot.value;
          isSeenStatusExist = false;
        });
      }
    });
  }

  void pickFile() async {
    FilePickerResult f = await FilePicker.platform.pickFiles(
      allowCompression: true,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4'],
    );
    setState(() {
      file = f;
      print(f.files[0].path);
      print(file.files[0].path);
    });
    if (file.files[0].path.contains(".jpg") ||
        file.files[0].path.contains(".png") ||
        file.files[0].path.contains(".jpeg")) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: file.files[0].path,
          compressQuality: 15,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Edit Image',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: WHITE,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      setState(() {
        croppedFile = croppedFile;
      });

      Uint8List u = await croppedFile.readAsBytes();
      uploadFileToServer(u, "jpg", "file", u);
    } else if (file.files[0].path.contains(".mp4")) {
      myDialog();

      Navigator.pop(context);
    }
  }

  myDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Processing..."),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text("Please wait while processing video"),
              ],
            ),
          );
        });
  }

  uploadFileToServer(Uint8List result, String extension, String type,
      Uint8List thumbNail) async { 
    await getExternalStorageDirectory().then((value) async {
      print(value);
      

      File f2 = await File(value.path + '/0.$extension').create();
      f2.writeAsBytesSync(result);

      final tag = "image upload ${Random().nextInt(9999)}";

      await uploader.clearUploads();

      final taskId = await uploader.enqueue(
        MultipartFormDataUpload(
          url: "$SERVER_ADDRESS/api/chatuploadmedia",
          files: [FileItem(path: '${f2.path}', field: "file")],
          method: UploadMethod.POST,
          tag: tag,
        ),
      );

      setState(() {
        message = value.toString();
        sendTask(3, taskId);
      });

      setState(() {
        _tasks.putIfAbsent(
            tag,
            () => UploadItem(
                  id: taskId,
                  tag: tag,
                  type: MediaType.Video,
                  status: UploadTaskStatus.enqueued,
                ));
      });
    });
  }

  Widget typeToWidget(int type, String message, String uid, String taskId,
      AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    if (type == 1) {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyPhotoViewer(
                    SERVER_ADDRESS + "/public/upload/chat/" + message),
              ));
        },
        child: Hero(
          tag: SERVER_ADDRESS + "/public/upload/chat/" + message,
          child: ClipRRect(
            child: CachedNetworkImage(
              imageUrl: SERVER_ADDRESS + "/public/upload/chat/" + message,
              placeholder: (context, url) =>
                  Container(child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => Icon(Icons.error),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (type == 2) {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyVideoPlayer(
                      SERVER_ADDRESS + "/public/upload/chat/" + message)));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 200,
            width: 200,
            child: Stack(
              children: [
                MyVideoThumbNail(
                    SERVER_ADDRESS + "/public/upload/chat/" + message),
                Container(
                  color: Colors.black38,
                ),
                Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: WHITE,
                    size: 70,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else if (type == 3 && uid == myUid) {
      final uploader = FlutterUploader();
      return InkWell(
        onLongPress: () {},
        child: Container(
          height: 200,
          child: Stack(
            children: [
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(WHITE),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Uploading...",
                  style: TextStyle(color: WHITE),
                ),
              ),
              Center(
                child: InkWell(
                    onTap: () {
                      deleteTask(taskId);
                      uploader.cancel(taskId: taskId);
                    },
                    child: Icon(
                      Icons.cancel,
                      color: WHITE,
                    )),
              ),
            ],
          ),
        ),
      );
    } else if (type == 0) {
      return InkWell(
        onTap: () async {
          if (isURL(message)) {
            if (await canLaunch(message)) {
              await launch(message);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            message,
            style: GoogleFonts.ubuntu(
                fontSize: isURL(message) ? 18 : 15,
                color: uid == myUid ? WHITE : LIGHT_GREY_TEXT,
                fontWeight: isURL(message) ? FontWeight.w300 : FontWeight.w400,
                decoration: isURL(message)
                    ? TextDecoration.underline
                    : TextDecoration.none),
          ),
        ),
      );
    } else if (type == 3 && uid != myUid) {
      return Text(
        "Uploading file...",
        style: TextStyle(fontSize: 10),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () async {},
          child: Text(
            message,
            style: GoogleFonts.ubuntu(
                fontSize: isURL(message) ? 18 : 15,
                color: uid == myUid ? BLACK : BLACK,
                fontWeight: isURL(message) ? FontWeight.w300 : FontWeight.w400,
                decoration: isURL(message)
                    ? TextDecoration.underline
                    : TextDecoration.none),
          ),
        ),
      );
    }
  }

  getAndStoreVideoThumbnail(String path) async {
    File f = File((await getApplicationDocumentsDirectory()).path + "/" + path);
    if (f.existsSync()) {
      print("Path exists");
    } else {
      print("Not available");
      await VideoThumbnail.thumbnailFile(
        video: path,
        thumbnailPath:
            (await getApplicationDocumentsDirectory()).path + "/" + path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
    }
  }

  Widget statusToWidget(data) {
    if (data == 0) {
      return Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(color: LIGHT_GREY),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Reject",
                      style: TextStyle(fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  acceptChatRequest();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.8)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Accept",
                      style:
                          TextStyle(color: WHITE, fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (data == 1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              color: LIGHT_GREY_TEXT,
              height: 0,
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: textField = TextField(
                    minLines: 1,
                    maxLines: 6,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      hintText: "Type a message here...",
                      filled: false,
                      hintStyle: TextStyle(fontSize: 15),
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              pickFile();
                            },
                            child: Image.asset(
                              "assets/chatScreen/document.png",
                              height: 18,
                              width: 18,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);

                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            child: Image.asset(
                              "assets/chatScreen/smile.png",
                              height: 18,
                              width: 18,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    onChanged: (val) {
                      markAsTyping();
                      setState(() {
                        message = val;
                        if (val.length == 0) {
                          showButton = false;
                        } else {
                          showButton = true;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  onTap: () {
                    if (showButton) {
                      sendMessage(0);
                    }
                  },
                  child: Image.asset(
                    "assets/chatScreen/send_btn.png",
                    height: 38,
                    width: 38,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  header(String name, String status, image) {
    return SafeArea(
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: WHITE,
          boxShadow: [
            BoxShadow(
              color: LIGHT_GREY_TEXT,
              blurRadius: 10.0,
              spreadRadius: 0.1,
              offset: Offset(
                0.5,
                0.5,
              ),
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 15,
            ),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CachedNetworkImage(
                    height: 50,
                    width: 50,
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (context, string) => Container(
                      height: 40,
                      width: 40,
                    ),
                    errorWidget: (context, err, f) => Icon(
                      Icons.account_circle,
                      size: 50,
                      color: LIGHT_GREY_TEXT,
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  width: 50,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: status == "Online"
                        ? Image.asset(
                            "assets/chatScreen/status.png",
                            height: 15,
                            width: 15,
                            fit: BoxFit.contain,
                          )
                        : Container(),
                  ),
                )
              ],
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  status,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: LIGHT_GREY_TEXT),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  acceptChatRequest() async {
    await FirebaseDatabase.instance
        .reference()
        .child(myUid)
        .child('chatlist')
        .child(widget.uid)
        .update({
      "status": 1,
    }).then((value) {
      setState(() {
        requestStatus = 1;
      });
    });
  }

  unsendDialog(AsyncSnapshot<QuerySnapshot> snapshot, index) {
    return showDialog(
        context: context,
        barrierColor: Colors.black87.withOpacity(0.7),
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Remove Message",
              style: TextStyle(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Are you sure to remove this message ?",
                  style: TextStyle(fontSize: 13, color: Colors.red.shade800),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          unsendMessage(snapshot.data.docs[index].id, index,
                              snapshot.data.docs.length, snapshot);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: LIGHT_GREY_TEXT,
                          ),
                          child: Center(
                            child: Text(
                              "Remove",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  unsendMessage(String id, int index, int length,
      AsyncSnapshot<QuerySnapshot> snapshot) async {
    print("\n\n" + index.toString() + "  " + length.toString());
    if (index > 0) {
      await FirebaseFirestore.instance
          .collection("Chats")
          .doc(channelId)
          .collection("All Chat")
          .doc(id)
          .delete();
      Navigator.pop(context);
    } else if (length == 1) {
      await FirebaseFirestore.instance
          .collection("Chats")
          .doc(channelId)
          .collection("All Chat")
          .doc(id)
          .delete();
      await FirebaseDatabase.instance
          .reference()
          .child(myUid)
          .child("chatlist")
          .child(widget.uid)
          .remove();
      await FirebaseDatabase.instance
          .reference()
          .child(widget.uid)
          .child("chatlist")
          .child(myUid)
          .remove();
      Navigator.pop(context);
    } else {
      DatabaseReference documentReference = FirebaseDatabase.instance
          .reference()
          .child(myUid)
          .child('chatlist')
          .child(widget.uid);
      await documentReference.update({
        "time": snapshot.data.docs[1]['time'].toDate().toUtc().toString(),
        "last_msg": snapshot.data.docs[1]['msg'],
        "type": snapshot.data.docs[1]['type'],
      });

      DatabaseReference documentReference2 = FirebaseDatabase.instance
          .reference()
          .child(widget.uid)
          .child('chatlist')
          .child(myUid);
      await documentReference2.update({
        "time": snapshot.data.docs[1]['time'].toDate().toUtc().toString(),
        "last_msg": snapshot.data.docs[1]['msg'],
        "type": snapshot.data.docs[1]['type'],
      });
      Navigator.pop(context);

      await FirebaseFirestore.instance
          .collection("Chats")
          .doc(channelId)
          .collection("All Chat")
          .doc(id)
          .delete();
    }
  }

  typeToUnsendDialogContent(int type, String msg) {
    if (type == 1) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CachedNetworkImage(
            imageUrl: SERVER_ADDRESS + "/public/upload/chat/" + msg,
            fit: BoxFit.cover,
            placeholder: (context, s) => Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, s, y) => Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    } else if (type == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                MyVideoThumbNail(
                    SERVER_ADDRESS + "/public/upload/chat/" + message),
                Container(
                  color: Colors.black38,
                ),
                Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 70,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            msg,
            style: TextStyle(fontSize: 15),
          ),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> sendNotification(
      String userName, String message, String token) async {
    await firebaseMessaging.requestPermission(
        sound: true, badge: true, alert: true, provisional: false);

    print("\n\nMessage sent : ${token}");

    await http
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'notification': <String, dynamic>{
            'android': <String, String>{},
          },
          'data': <String, String>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'body': message,
            'title': userName,
            'channel': channelId.codeUnits[0].toString() +
                channelId.codeUnits[1].toString() +
                channelId.codeUnits.last.toString(),
            'uid': myUid.toString(),
            'channelId': channelId,
            'myName': myName,
          },
          'to': token,
        },
      ),
    )
        .then((value) {
      print("\n\nMessage sent : ${value.body}");
    }).catchError((e) {
      print("\n\nMessage sent : ${e.toString()}");
    });

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    return completer.future;
  }
}

class UploadItem {
  final String id;
  final String tag;
  final MediaType type;
  final int progress;
  final UploadTaskStatus status;

  UploadItem({
    this.id,
    this.tag,
    this.type,
    this.progress = 0,
    this.status = UploadTaskStatus.undefined,
  });

  UploadItem copyWith({UploadTaskStatus status, int progress}) => UploadItem(
      id: this.id,
      tag: this.tag,
      type: this.type,
      status: status ?? this.status,
      progress: progress ?? this.progress);

  bool isCompleted() =>
      this.status == UploadTaskStatus.canceled ||
      this.status == UploadTaskStatus.complete ||
      this.status == UploadTaskStatus.failed;
}

enum MediaType { Image, Video }

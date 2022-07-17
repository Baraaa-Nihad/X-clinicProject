import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/main.dart';
import 'package:singleclinic/modals/DoctorsList.dart';
import 'package:singleclinic/screens/BookAppointment.dart';
import 'package:singleclinic/screens/ChatScreen.dart';
import 'package:singleclinic/screens/DoctorDetail.dart';
import 'package:singleclinic/screens/DoctorList.dart';
import 'package:singleclinic/screens/LoginScreen.dart';
import 'package:singleclinic/screens/SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DoctorsList doctorsList;
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  List<InnerData> myList = [];
  String nextUrl = "";
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  String myUid = "";
  Timer timer;

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    fetchDoctorsList();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        isLoggedIn = value.getBool("isLoggedIn") ?? false;
        myUid = value.getString("uid");
      });
    }).then((value) {
      if (myUid != null) {
        updateUserPresence();
      }
    });
    WidgetsBinding.instance.addObserver(this);

    SharedPreferences.getInstance().then((value) {
      String data = value.getString("payload");
      if (data != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(data.split(",")[0], data.split(",")[1]),
            ));
      }
      print("0-> payload : ->${value.getString("payload")}");
    });

    FirebaseMessaging.onMessage.listen((event) async {
      print("\n\nonMessage: $event");
      print("\nchannel: ${event.notification}");
      await SharedPreferences.getInstance().then((value) {
        print(value.get(event.data['uid']) ?? "does not exist");
        if (value.get(event.data['uid']) ?? false) {
          notificationHelper.showMessagingNotification(
              data: event.data, context2: context);
        }
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("\n\nonAppOpened: $event");
      print("\nchannel: ${event.notification}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(event.notification.title, event.data['uid'])));
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        print("Loadmore");
        _loadMoreFunc();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    print("Dispose called");
    timer.cancel();
    Map<String, dynamic> presenceStatusFalse = {
      'presence': false,
      'last_seen': DateTime.now().toString(),
    };
    databaseReference.child(myUid).onDisconnect().update(presenceStatusFalse);
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          backgroundColor: WHITE,
          flexibleSpace: header(),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  HOME,
                  style: TextStyle(
                      color: BLACK, fontSize: 25, fontWeight: FontWeight.w800),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(),
                        ));
                  },
                  child: Image.asset(
                    "assets/homescreen/search_header.png",
                    height: 25,
                    width: 25,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        isLoggedIn ? BookAppointment() : LoginScreen(),
                  ));
            },
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      "assets/homescreen/Book-appointment-banner.png",
                      height: 180,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,

                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  height: 180,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            BOOK,
                            style: TextStyle(
                                fontSize: 17,
                                color: WHITE,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            APPOINTMENT,
                            style: TextStyle(
                                fontSize: 17,
                                color: WHITE,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            QUICKLY_CREATE_FILES,
                            style: TextStyle(
                              fontSize: 10,
                              color: WHITE,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: isLoggedIn ? 120 : 130,
                            height: 28,
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/homescreen/bookappointment.png",
                                  width: isLoggedIn ? 120 : 130,
                                  height: 28,
                                  fit: BoxFit.fill,
                                ),
                                Center(
                                  child: Text(
                                    isLoggedIn
                                        ? BOOKAPPOINTMENT
                                        : LOGIN_TO_BOOK_APPOINTMENT,
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: LIME,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DOCTOR_LIST,
                  style: TextStyle(
                      color: BLACK, fontSize: 17, fontWeight: FontWeight.w700),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DoctorList()));
                  },
                  child: Text(
                    SEE_ALL,
                    style: TextStyle(
                        color: NAVY_BLUE,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          doctorsList == null
              ? Container()
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: myList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return doctorDetailTile(
                      imageUrl: myList[index].image,
                      name: myList[index].name,
                      department: myList[index].departmentName,
                      aboutUs: myList[index].aboutUs,
                      id: myList[index].id,
                    );
                  },
                ),
          nextUrl != "null"
              ? Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  doctorDetailTile(
      {String imageUrl,
      String name,
      String department,
      String aboutUs,
      int id}) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DoctorDetails(id)));
      },
      child: Container(
        decoration: BoxDecoration(
            color: LIGHT_GREY, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  height: 72,
                  width: 72,
                  fit: BoxFit.cover,
                  imageUrl: Uri.parse(imageUrl).toString(),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
                          height: 75,
                          width: 75,
                          child: Center(child: Icon(Icons.image))),
                  errorWidget: (context, url, error) => Container(
                    height: 75,
                    width: 75,
                    child: Center(
                      child: Icon(Icons.broken_image_rounded),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        color: BLACK,
                        fontSize: 17,
                        fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: LIME,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                      child: Text(
                        department,
                        style: TextStyle(
                            color: WHITE,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          aboutUs,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: LIGHT_GREY_TEXT,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16,
            )
          ],
        ),
        margin: EdgeInsets.fromLTRB(16, 6, 16, 6),
      ),
    );
  }

  fetchDoctorsList() async {
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/listofdoctorbydepartment?department_id=0"));

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      print(response.body);

      setState(() {
        doctorsList = DoctorsList.fromJson(jsonDecode(response.body));
        myList.addAll(doctorsList.data.data);
        nextUrl = doctorsList.data.nextPageUrl;
      });
    }
  }

  void _loadMoreFunc() async {
    print(nextUrl);
    if (nextUrl != "null" && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final response = await get(
        Uri.parse("$nextUrl&department_id=0"),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        print(response.body);
        doctorsList = DoctorsList.fromJson(jsonDecode(response.body));
        setState(() {
          myList.addAll(doctorsList.data.data);
          nextUrl = doctorsList.data.nextPageUrl;
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print("\n\nLifecycle state $state");

    if (state == AppLifecycleState.resumed) {
      updateUserPresence();
    } else {
      if (timer != null) {
        timer.cancel();
      }
      Map<String, dynamic> presenceStatusFalse = {
        'presence': false,
        'last_seen': DateTime.now().toUtc().toString(),
      };

      if (myUid != null) {
        await databaseReference
            .child(myUid)
            .update(presenceStatusFalse)
            .whenComplete(() => print('Updated your presence.'))
            .catchError((e) => print(e));
      }
    }
  }

  checkIfLoggedInFromAnotherDevice() async {}

  updateUserPresence() async {
    Map<String, dynamic> presenceStatusTrue = {
      'presence': true,
      'last_seen': DateTime.now().toUtc().toString(),
    };

    await databaseReference
        .child(myUid)
        .update(presenceStatusTrue)
        .whenComplete(() => print('Updated your presence.'))
        .catchError((e) => print(e));

    Map<String, dynamic> presenceStatusFalse = {
      'presence': false,
      'last_seen': DateTime.now().toUtc().toString(),
    };

    databaseReference.child(myUid).onDisconnect().update(presenceStatusFalse);
  }

  updatePreferenceAgainAndAgain() {
    Map<String, dynamic> presenceStatusTrue = {
      'presence': true,
      'connections': true,
      'last_seen': DateTime.now().toString(),
    };

    databaseReference.child(myUid).update(presenceStatusTrue).whenComplete(() {
      updateUserPresence();
      print('Updated your presence.');
    }).catchError((e) => print(e));
  }

  alertDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: _willPopScope,
            child: AlertDialog(
              title: Text("Log Out"),
              content: Text("Your account is logged In from another device"),
              actions: [
                TextButton(
                  child: Text("ok"),
                  onPressed: () async {},
                )
              ],
            ),
          );
        });
  }

  Future<bool> _willPopScope() async {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
    return false;
  }
}

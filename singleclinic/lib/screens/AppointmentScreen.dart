import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/modals/UpcomingAppointmrnts.dart';
import 'package:singleclinic/screens/PlaceHolderScreen.dart';
import '../AllText.dart';
import '../main.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with TickerProviderStateMixin {
  TabController tabController;
  int id;
  UpcomingAppointments upcomingAppointments;
  List<InnerData> upcomingList = [];
  List<InnerData> pastList = [];
  bool isLoadingMoreUpcoming = false;
  bool isLoadingMorePast = false;
  String upcomingNextUrl;
  String pastNextUrl;
  ScrollController scrollController = ScrollController();
  ScrollController scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    SharedPreferences.getInstance().then((value) {
      id = value.getInt("id");
      fetchPastAppointments();
      fetchUpcomingAppointments();
      print(id);
    });

    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadingMoreUpcoming) {
        print("Loadmore");
        loadMoreUpcomingAppointments();
      }
    });

    scrollController2.addListener(() {
      print(scrollController2.position.pixels);
      if (scrollController2.position.pixels ==
              scrollController2.position.maxScrollExtent &&
          !isLoadingMorePast) {
        print("Loadmore 2");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          leading: Container(),
          flexibleSpace: header(),
          backgroundColor: WHITE,
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Text(UPCOMING),
              Text(PAST),
            ],
            labelPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            labelColor: NAVY_BLUE,
            labelStyle: TextStyle(
              fontSize: 11,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            indicatorColor: LIME,
            indicatorPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            unselectedLabelColor: LIGHT_GREY_TEXT,
          ),
        ),
        body: upcomingAppointments == null
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : TabBarView(
                controller: tabController,
                children: [
                  upcomingList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: PlaceHolderScreen(
                            iconPath:
                                "assets/placeholders/appointment_holder.png",
                            message: NO_APPOINTMENT_FOUND,
                            description:
                                YOUR_UPCOMING_APPOINTMENTS_WILL_BE_DISPLAYED_HERE,
                          ),
                        )
                      : SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount: upcomingList == null
                                    ? 0
                                    : upcomingList.length,
                                itemBuilder: (context, index) {
                                  return upComingAppointmentDetails(index);
                                },
                              ),
                              upcomingNextUrl != "null"
                                  ? Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                  pastList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: PlaceHolderScreen(
                            iconPath:
                                "assets/placeholders/appointment_holder.png",
                            message: NO_APPOINTMENT_FOUND,
                            description:
                                YOUR_PAST_APPOINTMENTS_WILL_BE_DISPLAYED_HERE,
                          ),
                        )
                      : SingleChildScrollView(
                          controller: scrollController2,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: pastList == null ? 0 : pastList.length,
                            itemBuilder: (context, index) {
                              return pastList == null
                                  ? Container()
                                  : pastAppointmentDetails(index);
                            },
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  header() {
    return SafeArea(
      child: Container(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    MY_APPOINTMENT,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Divider(
              color: LIGHT_GREY_TEXT,
              thickness: 0.2,
            )
          ],
        ),
      ),
    );
  }

  upComingAppointmentDetails(int index) {
    return upcomingList.length == 0
        ? Container()
        : Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.fromLTRB(15, 15, 15, 2),
            decoration: BoxDecoration(
              color: LIGHT_GREY,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        imageUrl: upcomingList[index].image,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Container(
                                height: 75,
                                width: 75,
                                child: Center(
                                    child: Icon(
                                  Icons.account_circle,
                                  size: 35,
                                ))),
                        errorWidget: (context, url, error) => Container(
                          height: 75,
                          width: 75,
                          child: Center(
                            child: Icon(
                              Icons.account_circle,
                              size: 60,
                              color: LIGHT_GREY_TEXT,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                upcomingList[index].doctorName,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              Container(
                                height: 15,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: LIME,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    upcomingList[index].status,
                                    style: TextStyle(
                                        color: WHITE,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                "assets/subscriptionList/calender.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                upcomingList[index].date,
                                style:
                                    TextStyle(color: NAVY_BLUE, fontSize: 10),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Image.asset(
                                "assets/subscriptionList/clock.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                upcomingList[index].time,
                                style:
                                    TextStyle(color: NAVY_BLUE, fontSize: 10),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  upcomingList[index].serviceName,
                                  style: TextStyle(
                                      color: LIGHT_GREY_TEXT, fontSize: 10),
                                ),
                              ),
                              Text(
                                upcomingList[index].departmentName,
                                style: TextStyle(
                                    color: LIGHT_GREY_TEXT, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        upcomingList[index].messages,
                        style: TextStyle(
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  pastAppointmentDetails(int index) {
    return pastList.length == 0
        ? Container()
        : Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.fromLTRB(15, 15, 15, 2),
            decoration: BoxDecoration(
              color: LIGHT_GREY,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        imageUrl: pastList[index].image,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Container(
                                height: 75,
                                width: 75,
                                child: Center(
                                    child: Icon(
                                  Icons.account_circle,
                                  size: 35,
                                ))),
                        errorWidget: (context, url, error) => Container(
                          height: 75,
                          width: 75,
                          child: Center(
                            child: Icon(
                              Icons.account_circle,
                              size: 60,
                              color: LIGHT_GREY_TEXT,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pastList[index].doctorName,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              Container(
                                height: 15,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: LIME,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    pastList[index].status,
                                    style: TextStyle(color: WHITE, fontSize: 8),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                "assets/subscriptionList/calender.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                pastList[index].date,
                                style:
                                    TextStyle(color: NAVY_BLUE, fontSize: 10),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Image.asset(
                                "assets/subscriptionList/clock.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                pastList[index].time,
                                style:
                                    TextStyle(color: NAVY_BLUE, fontSize: 10),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pastList[index].serviceName,
                                  style: TextStyle(
                                      color: LIGHT_GREY_TEXT, fontSize: 10),
                                ),
                              ),
                              Text(
                                pastList[index].departmentName,
                                style: TextStyle(
                                    color: LIGHT_GREY_TEXT, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pastList[index].messages,
                        style: TextStyle(
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  fetchUpcomingAppointments() async {
    setState(() {
      upcomingList.clear();
      upcomingAppointments = null;
    });
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/getuserupconmingappointment?user_id=$id"));

    print(response.request.url);

    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      print(jsonResponse);
      print(jsonResponse);
      setState(() {
        upcomingAppointments = UpcomingAppointments.fromJson(jsonResponse);
        upcomingNextUrl = upcomingAppointments.data.nextPageUrl;
        upcomingList.addAll(upcomingAppointments.data.data);
      });
    }
  }

  loadMoreUpcomingAppointments() async {
    if (upcomingNextUrl != "null" && !isLoadingMoreUpcoming) {
      setState(() {
        isLoadingMoreUpcoming = true;
      });
      final response = await get(Uri.parse("$upcomingNextUrl&user_id=$id"));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        print(jsonResponse);
        upcomingAppointments = UpcomingAppointments.fromJson(jsonResponse);
        setState(() {
          upcomingNextUrl = upcomingAppointments.data.nextPageUrl;
          upcomingList.addAll(upcomingAppointments.data.data);
          isLoadingMoreUpcoming = false;
        });
      }
    }
  }

  fetchPastAppointments() async {
    setState(() {
      pastList.clear();
      upcomingAppointments = null;
    });
    final response = await get(
        Uri.parse("$SERVER_ADDRESS/api/getuserpastappointment?user_id=$id"));
    print(response.request.url);
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      print(jsonResponse);
      setState(() {
        upcomingAppointments = UpcomingAppointments.fromJson(jsonResponse);
        pastNextUrl = upcomingAppointments.data.nextPageUrl;
        pastList.addAll(upcomingAppointments.data.data);
        print(pastList.toString());
      });
    }
  }

}

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/modals/DoctorsList.dart';
import 'package:singleclinic/screens/DoctorDetail.dart';
import 'package:singleclinic/screens/SearchScreen.dart';

import '../AllText.dart';
import '../main.dart';

class DoctorList extends StatefulWidget {
  @override
  _DoctorListState createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  DoctorsList doctorsList;
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  List<InnerData> myList = [];
  String nextUrl = "";
  bool isLoggedIn = false;
  GlobalKey listLength = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchDoctorsList();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        isLoggedIn = value.getBool("isLoggedIn") ?? false;
      });
    });
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
  Widget build(BuildContext context) {
    print(listLength.currentState);

    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          backgroundColor: WHITE,
          flexibleSpace: header(),
          leading: Container(),
        ),
        body: doctorsList == null
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              )
            : body(),
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
                Row(
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
                      DOCTOR_LIST,
                      style: TextStyle(
                          color: BLACK,
                          fontSize: 25,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
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
      key: listLength,
      child: Column(
        children: [
          SizedBox(
            height: 10,
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
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                )
              : Container(),
          SizedBox(
            height: 50,
          ),
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
                  height: 75,
                  width: 75,
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
                    color: LIME,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                      child: Text(
                        department,
                        style: TextStyle(color: WHITE, fontSize: 10),
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
        margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
      ),
    );
  }

  fetchDoctorsList() async {
    final response = await get(
      Uri.parse("$SERVER_ADDRESS/api/listofdoctorbydepartment?department_id=0"),
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      print(response.body);

      setState(() {
        doctorsList = DoctorsList.fromJson(jsonDecode(response.body));
        myList.addAll(doctorsList.data.data);
        nextUrl = doctorsList.data.nextPageUrl;
        _loadMoreFunc();
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
}

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:singleclinic/modals/DoctorsByDepartmentClass.dart';
import 'package:singleclinic/screens/DoctorDetail.dart';

import '../AllText.dart';
import '../main.dart';

class DoctorsCategoryScreen extends StatefulWidget {
  final int id;
  DoctorsCategoryScreen(this.id);

  @override
  _DoctorsCategoryScreenState createState() => _DoctorsCategoryScreenState();
}

class _DoctorsCategoryScreenState extends State<DoctorsCategoryScreen>
    with TickerProviderStateMixin {
  DoctorsByDepartmentClass doctorsByDepartmentClass;
  List<InnerData> list = [];
  ScrollController scrollController = ScrollController();
  String nextUrl = "";
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    fetchDoctorsByDepartment();

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: LIGHT_GREY_SCREEN_BG,
          flexibleSpace: header(),
          leading: Container(),
        ),
        body: body(),
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
                    DOCTORS,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  body() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          list.isEmpty
              ? Container(
                  height: MediaQuery.of(context).size.height - 100,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.55),
                  padding: EdgeInsets.all(15),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DoctorDetails(list[index].id),
                            ));
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.lightBlueAccent.withOpacity(0.15),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: CachedNetworkImage(
                                height: 75,
                                width: double.maxFinite,
                                fit: BoxFit.cover,
                                imageUrl: list[index].image,
                                progressIndicatorBuilder: (context, url,
                                        downloadProgress) =>
                                    Container(
                                        height: 75,
                                        width: 75,
                                        child:
                                            Center(child: Icon(Icons.image))),
                                errorWidget: (context, url, error) => Container(
                                  height: 75,
                                  width: 75,
                                  child: Center(
                                    child: Icon(Icons.broken_image_rounded),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          list[index].name,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          list[index].aboutUs,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: LIGHT_GREY_TEXT,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        "assets/doctordetails/facebook.png",
                                        height: 12,
                                        width: 12,
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Image.asset(
                                        "assets/doctordetails/twitter.png",
                                        height: 12,
                                        width: 12,
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Image.asset(
                                        "assets/doctordetails/google+.png",
                                        height: 12,
                                        width: 12,
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Image.asset(
                                        "assets/doctordetails/instagram.png",
                                        height: 12,
                                        width: 12,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
          nextUrl != "null"
              ? Container(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  fetchDoctorsByDepartment() async {
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/listofdoctorbydepartment?department_id=${widget.id}"));
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        doctorsByDepartmentClass =
            DoctorsByDepartmentClass.fromJson(jsonResponse);
        list.addAll(doctorsByDepartmentClass.data.data);
        nextUrl = doctorsByDepartmentClass.data.nextPageUrl;
      });
    }
  }

  _loadMoreFunc() async {
    if (nextUrl != "null") {
      setState(() {
        isLoadingMore = true;
      });

      final response =
          await get(Uri.parse("$nextUrl&department_id=${widget.id}"));
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        setState(() {
          doctorsByDepartmentClass =
              DoctorsByDepartmentClass.fromJson(jsonResponse);
          list.addAll(doctorsByDepartmentClass.data.data);
          nextUrl = doctorsByDepartmentClass.data.nextPageUrl;
          isLoadingMore = false;
        });
      }
    }
  }
}

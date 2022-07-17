import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:singleclinic/modals/DepartmentsClass.dart';
import 'package:singleclinic/screens/DepartmentDetailsScreen.dart';

import '../AllText.dart';
import '../main.dart';

class DepartmentScreen extends StatefulWidget {
  @override
  _DepartmentScreenState createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  DepartmentsClass departmentsClass;
  List<InnerData> list = [];
  String nextUrl = "";
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchDepartments();
    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        print("Loadmore");
        loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY,
        appBar: AppBar(
          leading: Container(),
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
                  DEPARTMENTS,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return departmentsClass == null
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: list.length,
                  padding: EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DepartmentDetailsScreen(list[index].id)));
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: WHITE,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    Uri.parse(list[index].image).toString(),
                                progressIndicatorBuilder: (context, url,
                                        downloadProgress) =>
                                    Container(
                                        child:
                                            Center(child: Icon(Icons.image))),
                                errorWidget: (context, url, error) => Container(
                                  child: Center(
                                    child: Icon(Icons.broken_image_rounded),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              list[index].name,
                              style: TextStyle(
                                  color: NAVY_BLUE,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              list[index].description,
                              style: TextStyle(
                                  color: LIGHT_GREY_TEXT,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 25,
                                    decoration: BoxDecoration(
                                        color: LIME,
                                        borderRadius:
                                            BorderRadius.circular(13)),
                                    child: Center(
                                      child: Text(
                                        VIEW_DETAIL,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: WHITE,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                nextUrl == "null"
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
              ],
            ),
          );
  }

  fetchDepartments() async {
    setState(() {
      isLoadingMore = true;
    });
    final response =
        await get(Uri.parse("$SERVER_ADDRESS/api/listofdepartment"));

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        departmentsClass = DepartmentsClass.fromJson(jsonResponse);
        list.addAll(departmentsClass.data.data);
        isLoadingMore = false;
        nextUrl = departmentsClass.data.nextPageUrl;
      });
    }
  }

  loadMore() async {
    if (nextUrl != "null" && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final response = await get(Uri.parse("$nextUrl"));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        setState(() {
          departmentsClass = DepartmentsClass.fromJson(jsonResponse);
          list.addAll(departmentsClass.data.data);
          isLoadingMore = false;
          nextUrl = departmentsClass.data.nextPageUrl;
        });
      }
    }
  }
}

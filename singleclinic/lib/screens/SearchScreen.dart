import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:singleclinic/modals/SearchDoctorClass.dart';
import 'package:singleclinic/screens/DoctorDetail.dart';

import '../AllText.dart';
import '../main.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchDoctorClass searchDoctorClass;
  bool isSearching = false;
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  String nextPageUrl = "";
  String keyword = "";
  List<InnerData> list = [];
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        print("Loadmore");
        _loadMoreFunc();
      }
    });
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          flexibleSpace: header(),
          backgroundColor: WHITE,
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 60),
            child: Container(
              height: 50,
              margin: EdgeInsets.all(10),
              child: TextField(
                focusNode: focusNode,
                decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintText: SEARCH_HERE_DOCTOR_NAME,
                    suffixIcon: IconButton(
                      icon: Image.asset(
                        "assets/homescreen/search_header.png",
                        height: 25,
                        width: 25,
                      ),
                      onPressed: () {
                        searchDoctors(keyword);
                      },
                    )),
                onChanged: (val) {
                  setState(() {
                    keyword = val;
                  });
                  searchDoctors(val);
                },
                onSubmitted: (val) {
                  searchDoctors(val);
                },
              ),
            ),
          ),
        ),
        body: searchDoctorClass == null
            ? Container()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return doctorDetailTile(
                            imageUrl: list[index].image,
                            name: list[index].name,
                            id: list[index].id,
                            aboutUs: list[index].aboutUs,
                            department: list[index].departmentName);
                      },
                    ),
                    nextPageUrl != "null"
                        ? Container(
                            margin: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                        : SizedBox(
                            height: 50,
                          )
                  ],
                ),
              ),
      ),
    );
  }

  header() {
    return SafeArea(
      child: Container(
        height: 60,
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
                    SEARCH,
                    style: TextStyle(
                        color: BLACK,
                        fontSize: 25,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
      ),
    );
  }

  searchDoctors(String keyword) async {
    setState(() {
      isSearching = true;
    });

    final response =
        await get(Uri.parse("$SERVER_ADDRESS/api/searchterm?term=$keyword"));

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        searchDoctorClass = null;
        list.clear();
        searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
        list.addAll(searchDoctorClass.data.data);
        isSearching = false;
        print(searchDoctorClass.data.data);
        nextPageUrl = searchDoctorClass.data.nextPageUrl;
      });
    }
  }

  void _loadMoreFunc() async {
    if (nextPageUrl != "null") {
      setState(() {
        isLoadingMore = true;
      });

      final response = await get(Uri.parse("$nextPageUrl&term=$keyword"));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        setState(() {
          searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
          isSearching = false;
          list.addAll(searchDoctorClass.data.data);
          isLoadingMore = false;
        });
      }
    }
  }
}

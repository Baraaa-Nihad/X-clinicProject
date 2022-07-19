import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/main.dart';
import 'package:singleclinic/modals/GalleryCategory.dart';
import 'package:singleclinic/modals/GalleryImagesByCategory.dart';
import 'package:singleclinic/modals/GalleryImagesByCategory.dart' as images;

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with TickerProviderStateMixin {
  TabController tabController;
  GalleryCategory galleryCategory;
  bool isLoadingImages = true;
  String nextPageUrl = "";
  List<images.InnerData> list = [];
  GalleryImagesByCategory galleryImagesByCategory;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();
  int category = 0;

  @override
  void initState() {
    super.initState();
    fetchGalleryCategory();
    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        print("Loadmore");
        loadMore(0);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return galleryCategory == null
        ? SafeArea(
            child: Scaffold(
              backgroundColor: LIGHT_GREY_SCREEN_BG,
              body: Stack(
                children: [
                  Column(
                    children: [
                      header(),
                    ],
                  ),
                  Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          )
        : SafeArea(
            child: Scaffold(
              backgroundColor: LIGHT_GREY_SCREEN_BG,
              appBar: AppBar(
                leading: Container(),
                flexibleSpace: header(),
                backgroundColor: WHITE,
                bottom: TabBar(
                  controller: tabController,
                  tabs: List.generate(galleryCategory.data.data.length + 1,
                      (index) {
                    if (index == 0) {
                      return Text("All");
                    } else {
                      return Text(galleryCategory.data.data[index - 1].name);
                    }
                  }),
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
                  isScrollable: true,
                  onTap: (val) {
                    fetchGalleryImagesByCategory(val);
                  },
                ),
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
                    GALLERY,
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

  body() {
    return galleryImagesByCategory == null
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : TabBarView(
            controller: tabController,
            children: List.generate(tabController.length, (index) {
              return tabController.index == index
                  ? SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          StaggeredGridView.countBuilder(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: list.length,
                            padding: EdgeInsets.all(15),
                            itemBuilder: (BuildContext context, int index) =>
                                new Container(
                              color: LIGHT_GREY,
                              height: index % 2 - 1 == 0 ? 120 : 250,
                              child: CachedNetworkImage(
                                height: index % 2 - 1 == 0 ? 120 : 250,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                                imageUrl: index % 2 == 0
                                    ? list[index].image
                                    : list[index].image,
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
                            staggeredTileBuilder: (int index) =>
                                StaggeredTile.fit(2),
                            mainAxisSpacing: 12.0,
                            crossAxisSpacing: 12.0,
                          ),
                          nextPageUrl != "null"
                              ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );
            }),
          );
  }

  fetchGalleryCategory() async {
    final response =
        await get(Uri.parse("$SERVER_ADDRESS/api/listofgallerycategory"));
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        galleryCategory = GalleryCategory.fromJson(jsonResponse);
        tabController = TabController(
            initialIndex: 0,
            length: galleryCategory.data.data.length + 1,
            vsync: this);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            fetchGalleryImagesByCategory(tabController.index);
          }
        });
      });
      fetchGalleryImagesByCategory(0);
    }
  }

  fetchGalleryImagesByCategory(int category) async {
    setState(() {
      galleryImagesByCategory = null;
      list.clear();
    });
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/listofimagebycategoryid?album_id=$category"));
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        galleryImagesByCategory =
            GalleryImagesByCategory.fromJson(jsonResponse);
        nextPageUrl = galleryImagesByCategory.data.nextPageUrl;
        list.addAll(galleryImagesByCategory.data.data);
      });
    }
  }

  loadMore(int category) async {
    if (nextPageUrl != "null" && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final response = await get(Uri.parse("$nextPageUrl&album_id=$category"));
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        galleryImagesByCategory =
            GalleryImagesByCategory.fromJson(jsonResponse);
        setState(() {
          nextPageUrl = galleryImagesByCategory.data.nextPageUrl;
          list.addAll(galleryImagesByCategory.data.data);
          isLoadingMore = false;
        });
      }
    }
  }
}

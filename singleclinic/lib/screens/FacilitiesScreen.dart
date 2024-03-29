import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart';
import 'package:singleclinic/modals/FacilitiesClass.dart';
import 'package:singleclinic/screens/GalleryScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AllText.dart';
import '../main.dart';

class FacilitiesScreen extends StatefulWidget {
  @override
  _FacilitiesScreenState createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  FacilitiesClass facilitiesClass;
  List<InnerData> list = [];

  @override
  void initState() {
    super.initState();
    fetchFacilitiesList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: LIGHT_GREY_SCREEN_BG,
            appBar: AppBar(
              leading: Container(),
              backgroundColor: WHITE,
              flexibleSpace: header(),
            ),
            body: facilitiesClass == null
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : body(),
          ),
        ));
  }

  header() {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  children: [
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.arrow_back_ios,
                    //     size: 18,
                    //     color: BLACK,
                    //   ),
                    //   constraints: BoxConstraints(maxWidth: 30, minWidth: 10),
                    //   padding: EdgeInsets.zero,
                    //   onPressed: () {
                    //     Navigator.pop(context);
                    //   },
                    // ),
                    // SizedBox(
                    //   width: 10,
                    // ),
                    Text(
                      FACILITIES,
                      style:GoogleFonts.cairo(
                        textStyle:   TextStyle(fontSize: 17, fontWeight: FontWeight.w600),


                    ),
                    )
                    // SizedBox(
                    //   width: 10,
                    // ),

                    // IconButton(
                    //     icon: Icon(
                    //       Icons.photo_library_outlined,
                    //       size: 25,
                    //       color: HexColor('#87A0E5'),
                    //     ),
                    //     onPressed: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => GalleryScreen()));
                    //     })
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  body() {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 4,
          itemCount: list.length,
          padding: EdgeInsets.all(10),
          itemBuilder: (BuildContext context, int index) => new  Container(
            color: LIGHT_GREY,
            height: index % 2 - 1 == 0 ? 180 : 200,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: CachedNetworkImage(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                    imageUrl:
                        index % 2 == 0 ? list[index].icon : list[index].icon,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Container(
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.black.withOpacity(0.2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                list[index].name,
                                style:GoogleFonts.cairo(
                                  textStyle:  TextStyle(
                                      color: WHITE,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 3,
                          color: WHITE,
                          thickness: 0.5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                list[index].description,
                                style:GoogleFonts.cairo(
                                  textStyle:    TextStyle(
                                      color: BLACK,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400),

                                ),

                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
        ));
  }

  fetchFacilitiesList() async {
    final response =
        await get(Uri.parse("$SERVER_ADDRESS/api/listoffacilities"));
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        facilitiesClass = FacilitiesClass.fromJson(jsonResponse);
        list.addAll(facilitiesClass.data.data);
      });
    }
  }
}

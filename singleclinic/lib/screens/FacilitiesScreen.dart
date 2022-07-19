import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart';
import 'package:singleclinic/modals/FacilitiesClass.dart';

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
    return SafeArea(
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
                  FACILITIES,
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
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: list.length,
      padding: EdgeInsets.all(15),
      itemBuilder: (BuildContext context, int index) => new Container(
        color: LIGHT_GREY,
        height: index % 2 - 1 == 0 ? 120 : 220,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: CachedNetworkImage(
                height: index % 2 - 1 == 0 ? 120 : 180,
                width: 100,
                fit: BoxFit.contain,
                imageUrl: index % 2 == 0 ? list[index].icon : list[index].icon,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            list[index].name,
                            style: TextStyle(
                                color: WHITE,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
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
                            list[index].description,
                            style: TextStyle(
                                color: WHITE,
                                fontSize: 9,
                                fontWeight: FontWeight.w200),
                            maxLines: 2,
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
    );
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

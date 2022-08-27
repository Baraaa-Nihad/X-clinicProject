import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/main.dart';
import 'package:singleclinic/modals/DepartmentDetails.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'DoctorsCategoryScreen.dart';

class DepartmentDetailsScreen extends StatefulWidget {
  final int id;
  DepartmentDetailsScreen(this.id);

  @override
  _DepartmentDetailsScreenState createState() =>
      _DepartmentDetailsScreenState();
}

class _DepartmentDetailsScreenState extends State<DepartmentDetailsScreen> {
  DepartmentDetails departmentDetails;

  @override
  void initState() {
    super.initState();
    fetchDepartmentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          body: departmentDetails == null
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, val) {
                    return <Widget>[
                      SliverAppBar(
                        backgroundColor: LIGHT_GREY_SCREEN_BG,
                        expandedHeight: 250,
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                            color: BLACK,
                          ),
                          constraints:
                              BoxConstraints(maxWidth: 30, minWidth: 10),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        flexibleSpace: Center(
                          child: CachedNetworkImage(
                            fit: BoxFit.fill,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            imageUrl: departmentDetails.data.image,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Container(
                                    height: 300,
                                    width: MediaQuery.of(context).size.width,
                                    child: Center(child: Icon(Icons.image))),
                            errorWidget: (context, url, error) => Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Icon(Icons.broken_image_rounded),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 15, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        departmentDetails.data.name,
                                        style:GoogleFonts.cairo(
                                          textStyle: TextStyle(
                                              color: BLACK,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700),

                                        ),),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          _makeCall(departmentDetails
                                              .data.emergencyNo);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: NAVY_BLUE, width: 1)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              "assets/departmentDetails/phone.png",
                                              color: LIME,
                                              height: 25,
                                              width: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 5, 15, 15),
                                  child: Text(
                                    departmentDetails.data.description,
                                    style:GoogleFonts.cairo(
                                      textStyle: TextStyle(
                                          fontSize: 14.5, color: LIGHT_GREY_TEXT),



                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(20),
                                  color: LIGHT_GREY_SCREEN_BG,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Image.asset(
                                          //   "assets/departmentDetails/treatment.png",
                                          //   height: 35,
                                          //   width: 35,
                                          //
                                          //   fit: BoxFit.fill,
                                          // ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            TREATMENTS,
                                            style:GoogleFonts.cairo(
                                              textStyle: TextStyle(
                                                  color: BLACK,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700),

                                            ),),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ListView.builder(
                                        itemCount: departmentDetails
                                            .data.service.length,
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Expanded(
                                              child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(children: [
                                                    Container(
                                                      height: 25,
                                                      width: 3,
                                                      decoration: BoxDecoration(
                                                        color: LIME,
                                                        borderRadius: const BorderRadius.all(
                                                            const Radius.circular(4.0)),
                                                      ),
                                                    ),
                                                    SizedBox(width: 5,),
                                                    Text(
                                                      departmentDetails.data
                                                          .service[index].name,
                                                      style:GoogleFonts.cairo(
                                                        textStyle:  TextStyle(
                                                            fontSize: 14.5, color: LIGHT_GREY_TEXT),

                                                      ),),

                                                  ],),






                                                  Text(
                                                    "${departmentDetails.data.service[index].price} $CURRENCY",
                                                    style:GoogleFonts.cairo(
                                                  textStyle: TextStyle(
                                                      color: NAVY_BLUE,
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.w700),


                                          ),),
                                                  Text(
                                                    "${departmentDetails.data.service[index].priceFor}",
                                                    style:GoogleFonts.cairo(
                                                      textStyle: TextStyle(
                                                          color: NAVY_BLUE,
                                                          fontSize: 14,
                                                          fontWeight:
                                                          FontWeight.w700),


                                                    ),),
                                                ],
                                              ),

                                              SizedBox(
                                                height: 10,
                                              ),
                                              Divider(
                                                color: LIGHT_GREY_TEXT,
                                                height: 20,
                                              ),
                                            ],
                                          ));
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DoctorsCategoryScreen(
                                              departmentDetails.data.id)));
                            },
                            child: Container(
                              height: 60,
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Image.asset(
                                          "assets/departmentDetails/emergency_btn.png",
                                          height: 60,
                                          color: LIME,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      "كل الأطباء",
                                      style:GoogleFonts.cairo(
                                        textStyle: TextStyle(
                                            color: WHITE,
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w600),


                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  fetchDepartmentDetails() async {
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/departmentdetailbyid?department_id=${widget.id}"));
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        departmentDetails = DepartmentDetails.fromJson(jsonResponse);
      });
    }
  }

  _makeCall(email) {
    launch(Uri(
      scheme: 'tel',
      path: email,
    ).toString());
  }
}

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/modals/ReviewClass.dart';
import 'package:singleclinic/screens/PlaceHolderScreen.dart';

import '../main.dart';

class ReviewScreen extends StatefulWidget {
  final String doctorId;
  ReviewScreen(this.doctorId);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int rating = 4;
  int selectedRating = 0;
  String review = "";
  int userId;
  bool showReviewDialog = false;
  ReviewClass reviewClass;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      userId = value.getInt("id");
    });

    fetchAllReviews();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: LIGHT_GREY_SCREEN_BG,
            appBar: AppBar(
              leading: Container(),
              backgroundColor: WHITE,
              flexibleSpace: header(),
            ),
            body: !isLoaded
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : reviewsList(),
            floatingActionButton: FloatingActionButton(
              backgroundColor: LIME,
              child: Icon(
                Icons.add,
                color: WHITE,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  showReviewDialog = true;
                });
              },
            ),
          ),
          showReviewDialog ? AddReviewDialog() : Container(),
        ],
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
                  REVIEW,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  reviewsList() {
    return reviewClass == null
        ? PlaceHolderScreen(
            iconPath: "assets/placeholders/review_holder.png",
            description: DOCTOR_REVIEWS_WILL_BE_DISPLAYED_HERE,
            message: NO_REVIEWS,
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: reviewClass == null ? 0 : reviewClass.data.length,
                  itemBuilder: (context, index) {
                    return reviewCard(index);
                  },
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          );
  }

  reviewCard(int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              imageUrl: reviewClass.data[index].profilePic,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Container(
                      height: 50,
                      width: 50,
                      child: Center(child: Icon(Icons.image))),
              errorWidget: (context, url, error) => Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Icon(
                    Icons.account_circle,
                    color: LIGHT_GREY_TEXT,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reviewClass.data[index].name,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        double.parse(reviewClass.data[index].ratting) > 0.0
                            ? "assets/doctordetails/star_active.png"
                            : "assets/doctordetails/star_unactive.png",
                        height: 15,
                        width: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        double.parse(reviewClass.data[index].ratting) > 1.0
                            ? "assets/doctordetails/star_active.png"
                            : "assets/doctordetails/star_unactive.png",
                        height: 15,
                        width: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        double.parse(reviewClass.data[index].ratting) > 2.0
                            ? "assets/doctordetails/star_active.png"
                            : "assets/doctordetails/star_unactive.png",
                        height: 15,
                        width: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        double.parse(reviewClass.data[index].ratting) > 3.0
                            ? "assets/doctordetails/star_active.png"
                            : "assets/doctordetails/star_unactive.png",
                        height: 15,
                        width: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        double.parse(reviewClass.data[index].ratting) > 4.0
                            ? "assets/doctordetails/star_active.png"
                            : "assets/doctordetails/star_unactive.png",
                        height: 15,
                        width: 15,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reviewClass.data[index].review,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  AddReviewDialog() {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Stack(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                showReviewDialog = false;
              });
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black54,
            ),
          ),
          Center(
              child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: WHITE,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Add_A_REVIEW,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    YOUR_RATING,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedRating = 1;
                          });
                        },
                        child: Image.asset(
                          selectedRating > 0
                              ? "assets/doctordetails/star_active.png"
                              : "assets/doctordetails/star_unactive.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedRating = 2;
                          });
                        },
                        child: Image.asset(
                          selectedRating > 1
                              ? "assets/doctordetails/star_active.png"
                              : "assets/doctordetails/star_unactive.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedRating = 3;
                          });
                        },
                        child: Image.asset(
                          selectedRating > 2
                              ? "assets/doctordetails/star_active.png"
                              : "assets/doctordetails/star_unactive.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedRating = 4;
                          });
                        },
                        child: Image.asset(
                          selectedRating > 3
                              ? "assets/doctordetails/star_active.png"
                              : "assets/doctordetails/star_unactive.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedRating = 5;
                          });
                        },
                        child: Image.asset(
                          selectedRating > 4
                              ? "assets/doctordetails/star_active.png"
                              : "assets/doctordetails/star_unactive.png",
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    YOUR_REVIEW,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  TextField(
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "ما رأيك في الطبيب ؟",
                      contentPadding: EdgeInsets.zero,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 0.5)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade500, width: 0.5)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade500, width: 0.5)),
                    ),
                    onChanged: (val) {
                      setState(() {
                        review = val;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  bottomButtons(),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  bottomButtons() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                addReview();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(25, 5, 25, 0),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: LIME,
                ),
                child: Center(
                  child: Text(
                    SUBMIT,
                    style: TextStyle(
                        color: WHITE,
                        fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  addReview() async {
    processingDialog(PLEASE_WAIT_WHILE_ADDING_REVIEW);
    final response =
        await post(Uri.parse("$SERVER_ADDRESS/api/addreview"), body: {
      "user_id": userId.toString(),
      "doctor_id": widget.doctorId,
      "review": review,
      "ratting": selectedRating.toString()
    });
    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      Navigator.pop(context);
      setState(() {
        showReviewDialog = false;
        reviewClass = null;
      });
      fetchAllReviews();
      print("review added");
    } else {
      Navigator.pop(context);
      errorDialog(jsonResponse['msg']);
    }
  }

  fetchAllReviews() async {
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/reviewlistbydoctor?id=${widget.doctorId}"));

    print(response.request);

    final jsonResponse = jsonDecode(response.body);

    print(jsonResponse.toString());

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        isLoaded = true;
        reviewClass = ReviewClass.fromJson(jsonResponse);
      });
    } else {
      setState(() {
        isLoaded = true;
      });
    }
  }

  errorDialog(message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Icon(
                  Icons.error,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  message,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        });
  }

  processingDialog(message) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(LOADING),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 14),
                  ),
                )
              ],
            ),
          );
        });
  }
}

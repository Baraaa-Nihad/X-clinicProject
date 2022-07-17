import 'dart:convert';

import "package:flutter/material.dart";
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/modals/SubscriptionListClass.dart';
import 'package:singleclinic/screens/PlaceHolderScreen.dart';

import '../AllText.dart';
import '../main.dart';

class SubcriptionList extends StatefulWidget {
  @override
  _SubcriptionListState createState() => _SubcriptionListState();
}

class _SubcriptionListState extends State<SubcriptionList> {
  SubscriptionListClass subscriptionListClass;
  int userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      userId = value.getInt("id");
      if (userId != null) {
        fetchSubscriptions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          backgroundColor: WHITE,
          flexibleSpace: header(),
          leading: Container(),
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
                  MY_SUBCRIPTIONS,
                  style: TextStyle(
                      color: BLACK, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : subscriptionListClass == null || subscriptionListClass.data.isEmpty
            ? PlaceHolderScreen(
                iconPath: "assets/placeholders/subscription_holder.png",
                description: YOUR_SUBSCRIPTIONS_WILL_BE_DISPLAYED_HERE,
                message: NO_SUBSCRIPTIONS_FOUND,
              )
            : ListView.builder(
                itemCount: subscriptionListClass.data.length,
                itemBuilder: (context, index) {
                  return subscriptionCard(index);
                },
              );
  }

  subscriptionCard(int index) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subscriptionListClass.data[index].name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Container(
                height: 22,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    subscriptionListClass.data[index].status,
                    style: TextStyle(color: WHITE, fontSize: 10),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 13,
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
                subscriptionListClass.data[index].date,
                style: TextStyle(color: NAVY_BLUE, fontSize: 10),
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
                subscriptionListClass.data[index].time,
                style: TextStyle(color: NAVY_BLUE, fontSize: 10),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Text(
                "$CURRENCY${subscriptionListClass.data[index].amount}/month",
                style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  fetchSubscriptions() async {
    final response = await get(
        Uri.parse("$SERVER_ADDRESS/api/mysubscription?user_id=$userId"));
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        subscriptionListClass = SubscriptionListClass.fromJson(jsonResponse);
      });
    } else {
      print("ERROR : $jsonResponse");
    }

    setState(() {
      isLoading = false;
    });
  }
}

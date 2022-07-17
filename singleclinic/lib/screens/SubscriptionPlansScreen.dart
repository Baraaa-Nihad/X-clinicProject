import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/modals/HealthPackage.dart';
import 'package:singleclinic/screens/LoginScreen.dart';

import '../AllText.dart';
import '../main.dart';
import 'SubcriptionList.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  @override
  _SubscriptionPlansScreenState createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  int selectedTile;
  HealthPackage healthPackage;
  bool isLoggedIn = false;
  String name,
      userId,
      packageId,
      transactionId,
      date,
      time,
      paymentType,
      amount = "";

  @override
  void initState() {
    super.initState();
    fetchPlans();
    SharedPreferences.getInstance().then((value) {
      isLoggedIn = value.getBool("isLoggedIn") ?? false;
      userId = value.getInt("id").toString();
      print(userId);
      name = value.getString("name").toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY,
        appBar: AppBar(
          backgroundColor: WHITE,
          leading: Container(),
          flexibleSpace: header(),
        ),
        body: healthPackage == null
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
                  SUBSCRIPTION,
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
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    "assets/subscriptionScreen/suscribe.png",
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  PRICING,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: healthPackage.data.length,
                    itemBuilder: (context, index) {
                      return priceCard(index, healthPackage.data);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        button(),
      ],
    );
  }

  priceCard(index, List<Data> list) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          selectedTile = index;
          amount = list[index].price;
          packageId = list[index].id.toString();
        });
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: selectedTile == index
              ? Border.all(
                  color: LIME,
                  width: 2,
                )
              : Border.all(
                  color: WHITE,
                  width: 0,
                ),
          color: WHITE,
        ),
        margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    healthPackage.data[index].name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    healthPackage.data[index].description,
                    style: TextStyle(
                        color: NAVY_BLUE,
                        fontSize: 11,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$CURRENCY${healthPackage.data[index].price}",
                  style: TextStyle(
                      fontSize: 22, color: BLACK, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  "monthly",
                  style: TextStyle(
                      color: NAVY_BLUE,
                      fontSize: 12,
                      fontWeight: FontWeight.w300),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  fetchPlans() async {
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/healthpackage"));
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        healthPackage = HealthPackage.fromJson(jsonResponse);
      });
    }
  }

  button() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              if (selectedTile == null) {
                errorDialog(PLEASE_SELECT_A_SUBSCRIPTION_PLAN);
                return;
              }
              if (isLoggedIn) {
                setState(() {
                  date = (DateTime.now().day < 10
                          ? "0" + DateTime.now().day.toString()
                          : DateTime.now().day.toString()) +
                      "-" +
                      (DateTime.now().month < 10
                          ? "0" + DateTime.now().month.toString()
                          : DateTime.now().month.toString()) +
                      "-" +
                      DateTime.now().year.toString();
                  time = (DateTime.now().hour < 12
                          ? (DateTime.now().hour < 10
                              ? "0" + DateTime.now().hour.toString()
                              : DateTime.now().hour.toString())
                          : (DateTime.now().hour - 12 < 10
                              ? "0" + (DateTime.now().hour - 12).toString()
                              : (DateTime.now().hour - 12).toString())) +
                      ":" +
                      (DateTime.now().minute < 10
                          ? "0" + DateTime.now().minute.toString()
                          : DateTime.now().minute.toString()) +
                      " " +
                      (DateTime.now().hour < 12 ? "Am" : "Pm");
                  paymentType = "2";
                });
                addSubscription(amount);
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ));
              }
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: LIME,
              ),
              child: Center(
                child: Text(
                  isLoggedIn ? ADD_SUBSCRIPTION : LOGIN_TO_ADD_SUBSCRIPTION,
                  style: TextStyle(color: WHITE,fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  AddSubscription() async {
    final response = await post(Uri.parse("$SERVER_ADDRESS/api/healthpackage"));
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      setState(() {
        healthPackage = HealthPackage.fromJson(jsonResponse);
      });
    }
  }

  addSubscription(String price) async {
    var request = BraintreeDropInRequest(
      tokenizationKey: TOKENIZATION_KEY,
      collectDeviceData: true,
      googlePaymentRequest: BraintreeGooglePaymentRequest(
        totalPrice: price,
        currencyCode: CURRENCY_CODE,
        billingAddressRequired: false,
      ),
      amount: price,
      paypalRequest: BraintreePayPalRequest(
          amount: "10",
          currencyCode: "USD",
          displayName: "name",
          billingAgreementDescription: "xyz"),
      cardEnabled: true,
    );

    await BraintreeDropIn.start(request).then((value) {
      setState(() {
        transactionId = value.paymentMethodNonce.nonce;
      });
      processingDialog(PLEASE_WAIT_WHILE_PROCESSING_PAYMENT);
      callApiForAddingSubscription();
      print("\n\n" + value.paymentMethodNonce.nonce + "\n\n");
    }).catchError((e) {
      print("ERROR : $e");

      if (!e.toString().contains("NoSuchMethodError")) {
        errorDialog(e.toString());
      }
    });
  }

  messageDialog(String s1, String s2) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              s1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubcriptionList()));
                },
                style: TextButton.styleFrom(backgroundColor: LIME),
                child: Text(
                  YES,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: WHITE,
                  ),
                ),
              ),
            ],
          );
        });
  }

  callApiForAddingSubscription() async {
    final response = await post(
        Uri.parse(
          '$SERVER_ADDRESS/api/addsubscription',
        ),
        body: {
          "name": name,
          "user_id": userId,
          "package_id": packageId,
          "transaction_id": transactionId,
          "date": date,
          "time": time,
          "payment_type": paymentType,
          "amount": amount,
        });

    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      messageDialog(SUCCESSFUL, SUBSCRIPTION_ADDED_SUCCESSFULLY);
    } else {
      errorDialog(ERROR_WHILE_ADDING_SUBSCRIPTION);
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
                  textAlign: TextAlign.center,
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

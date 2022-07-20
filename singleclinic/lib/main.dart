import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/screens/AppointmentScreen.dart';
import 'package:singleclinic/screens/ChatList.dart';
import 'package:singleclinic/screens/DepartmentScreen.dart';
import 'package:singleclinic/screens/FacilitiesScreen.dart';
import 'package:singleclinic/screens/HomeScreen.dart';
import 'package:singleclinic/screens/SettingsScreen.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:singleclinic/screens/SplashScreen.dart';
import 'notificationTesting/notificationHelper.dart';

FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//String SERVER_ADDRESS = "https://demo.freaktemplate.com/singleclinic";
 String SERVER_ADDRESS = "https://appx-a.com/X-clinic-Admin";
MyNotificationHelper notificationHelper = MyNotificationHelper();
 final String serverToken = "AAAAQYw5uf4:APA91bGhXd3YUn7SJrWIUJaXBskuWnbjWs1oGm0tcLFr3HJ79oqNGo-taJ8C1Av8jLfcTarCquzT5UJfhs5ubw8bnE3RihKeB8PRI7LbFW4WfE4ldq6V6csERjqTSNMr1dx0Nh1b_JbR";
//final String serverToken = "AAAAO2Co7iU:APA91bHzp5j7Do_A_LAFUpwLzqNESEYUUC_At6nLZoB6yH1wmWFsfsvKjOplY9cYH-pJzpVfYTZl68oFkip9F-VlXqr4oB-NA9QuJ1ZMBLPLfXh_mn4taaQR7cXEtw1j2Ryqka2kAlqy";

const String TOKENIZATION_KEY = 'sandbox_v2fzhc6d_qpj7hhj994nbzy5q';
const String CURRENCY_CODE = 'USD';
const String DISPLAY_NAME = 'Example Company';

Color LIME = Color(0xFF094D55);
// Color LIME = Color.fromRGBO(231, 208, 69, 1);
Color WHITE = Colors.white;
Color BLACK = Colors.black;
Color NAVY_BLUE = Color(0xFF094D55);//Color.fromRGBO(53, 99, 128, 1);
Color LIGHT_GREY = Color.fromRGBO(230, 230, 230, 1);
Color LIGHT_GREY_SCREEN_BG = Color.fromRGBO(240, 240, 240, 1);
Color LIGHT_GREY_TEXT = Colors.grey.shade700;
String CURRENCY = "\$";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  notificationHelper.initialize();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MaterialApp(
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      textTheme: TextTheme(
        headline1: TextStyle(
          fontFamily: "Avir",
        ),
        headline2: TextStyle(
          fontFamily: "Avir",
        ),
        headline3: TextStyle(
          fontFamily: "Avir",
        ),
        headline4: TextStyle(
          fontFamily: "Avir",
        ),
        headline5: TextStyle(
          fontFamily: "Avir",
        ),
        headline6: TextStyle(
          fontFamily: "Avir",
        ),
        subtitle1: TextStyle(
          fontFamily: "Avir",
        ),
        subtitle2: TextStyle(
          fontFamily: "Avir",
        ),
        caption: TextStyle(
          fontFamily: "Avir",
        ),
        bodyText1: TextStyle(
          fontFamily: "Avir",
        ),
        bodyText2: TextStyle(
          fontFamily: "Avir",
        ),
        button: TextStyle(
          fontFamily: "Avir",
        ),
      ),
      primaryColor: NAVY_BLUE, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: LIME, primary: NAVY_BLUE, primaryVariant: NAVY_BLUE, secondaryVariant: LIME)
    ),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', ''),
      const Locale('he', ''),
      const Locale('ar', ''),
      const Locale.fromSubtags(languageCode: 'zh'),
    ],
  ));
}

class TabBarScreen extends StatefulWidget {
  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen>
    with TickerProviderStateMixin {
  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return  Directionality(
        textDirection: TextDirection.rtl,
        child : SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            HomeScreen(),
            currentTab > 0 ? ChatList() : Container(),
            currentTab > 1 ? AppointmentScreen() : Container(),
            currentTab > 2 ? DepartmentScreen() : Container(),
            currentTab > 3 ? FacilitiesScreen()  : Container(),
            currentTab > 4 ? SettingsScreen()  : Container(),

          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentTab,
          backgroundColor: WHITE,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                currentTab == 0
                    ? "assets/tabBar/home_active.png"
                    : "assets/tabBar/home.png",
                color: currentTab == 0 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                height: 23,
                width: 23,
              ),
              label: "الصفحة الرئيسية",
            ),
            BottomNavigationBarItem(
                icon: Image.asset(
                  currentTab == 1
                      ? "assets/tabBar/chat_active.png"
                      : "assets/tabBar/chat.png",
                  color: currentTab == 1 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                  height: 23,
                  width: 23,
                ),
                label: "المحادثات"),
            BottomNavigationBarItem(
                icon: Image.asset(
                  currentTab == 2
                      ? "assets/tabBar/appointment_active.png"
                      : "assets/tabBar/appointment.png",
                  color: currentTab == 2 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                  height: 23,
                  width: 23,
                ),
                label: "المواعيد"),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentTab == 3
                    ? "assets/tabBar/de.png"
                    : "assets/tabBar/de.png",
                color: currentTab == 3 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                height: 23,
                width: 23,
              ),
              label: "الأقسام",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentTab == 4
                    ? "assets/tabBar/tee.png"
                    : "assets/tabBar/tee.png",
                color: currentTab == 4 ? NAVY_BLUE : LIGHT_GREY_TEXT,
                height: 23,
                width: 23,
              ),
              label: "المنشورات",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                currentTab == 5
                    ? "assets/tabBar/setting_active.png"
                    : "assets/tabBar/setting.png",
                color: currentTab == 5? NAVY_BLUE : LIGHT_GREY_TEXT,
                height: 23,
                width: 23,
              ),
              label: "الاعدادات",
            ),
          ],
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          showSelectedLabels: true,
          unselectedFontSize: 10,
          selectedLabelStyle: TextStyle(
            color: LIGHT_GREY_TEXT,
          ),
          onTap: (val) {
            setState(() {
              currentTab = val;
            });
          },
        ),
      ),
        )
    );
  }
}

class SignInDemo extends StatefulWidget {
  @override
  _SignInDemoState createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _googleSignIn.signIn().then((value) {
              value.authentication.then((googleKey) {
                print(googleKey.idToken);
                print(googleKey.accessToken);
                print(value.email);
                print(value.displayName);
                print(value.photoUrl);
              }).catchError((e) {
                print(e.toString());
              });
            }).catchError((e) {
              print(e.toString());
            });
          },
          child: Container(),
        ),
      ),
    );
  }
}

class AppleLogin extends StatefulWidget {
  @override
  _AppleLoginState createState() => _AppleLoginState();
}

class _AppleLoginState extends State<AppleLogin> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example app: Sign in with Apple'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Center(),
        ),
      ),
    );
  }
}

Future myBackgroundMessageHandler(RemoteMessage event) async {
  await Firebase.initializeApp();
  HomeScreen().createState();
  print("\n\nbackground: " + event.toString());

  notificationHelper.showMessagingNotification(data: event.data);
}

doesSendNotification(String userUid, bool doesSend) async {
  await SharedPreferences.getInstance().then((value) {
    value.setBool(userUid, doesSend);
    print("\n\n ------------------> " +
        value.getBool(userUid).toString() +
        "\n\n");
  });
}

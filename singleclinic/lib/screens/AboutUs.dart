import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart';
import '../AllText.dart';
import '../main.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  Widget html;

  @override
  void initState() {
    loadHtml();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: LIGHT_GREY_SCREEN_BG,
          body: SafeArea(
            child: Stack(
              children: [
                html == null ? Center(
                  child: CircularProgressIndicator(),
                ) :SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
                    child: html,
                  ),
                ),
                Container(
                  color: WHITE,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 17,
                          color: BLACK,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        ABOUT_US,
                        style: TextStyle(
                            color: BLACK,
                            fontWeight: FontWeight.bold,
                            fontSize: 23),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  loadHtml() async{
    final data = await rootBundle.loadString('assets/tnc.html');

    setState((){
      html = Html(
        data: data,
      );
    });
  }

}

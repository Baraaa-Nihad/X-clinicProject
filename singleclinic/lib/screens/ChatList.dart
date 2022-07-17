import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AllText.dart';
import '../main.dart';
import 'ChatScreen.dart';
import 'PlaceHolderScreen.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String selectedValue = "All Chats";
  int selectedInt;
  List<ChatListDetails> chatListDetails = [];
  List<ChatListDetails> chatListSearch = [];
  List<ChatListDetails> chatListDetailsPA = [];
  var ds;
  String uid;
  String keyword = "";
  bool isSearchClicked = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        uid = value.getString("uid");
      });
      if (uid != null && (value.getBool("isLoggedIn") ?? false)) {
        loadChatList();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    ds.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: LIGHT_GREY_SCREEN_BG,
          appBar: AppBar(
            flexibleSpace: header(),
            backgroundColor: WHITE,
          ),
          body: Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
                height: isSearchClicked ? 50 : 0,
                margin: EdgeInsets.all(10),
                child: isSearchClicked
                    ? TextField(
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: SEARCH_HERE_NAME,
                        ),
                        onChanged: (val) {
                          setState(() {
                            keyword = val;
                          });
                        },
                        onSubmitted: (val) {},
                      )
                    : Container(),
              ),
              Expanded(
                child: chatListDetails.isEmpty
                    ? PlaceHolderScreen(
                        message: NO_CHATS,
                        description: YOUR_CHATS_WILL_BE_DISPLAYED_HERE,
                        iconPath: "assets/placeholders/message_holder.png",
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: ClampingScrollPhysics(),
                                itemCount: chatListDetails.length,
                                itemBuilder: (context, index) {
                                  return StreamBuilder(
                                    stream: FirebaseDatabase.instance
                                        .reference()
                                        .child(chatListDetails[index]
                                            .userUid
                                            .toString())
                                        .onValue,
                                    builder: (context,
                                        AsyncSnapshot<Event> snapshot) {
                                      if (snapshot.hasData) {
                                        print("new stream" +
                                            snapshot.data.snapshot.value['name']
                                                .toString());
                                        return messageCard(
                                            isNewMessage: chatListDetails[index]
                                                        .messageCount >
                                                    0
                                                ? true
                                                : false,
                                            name: snapshot
                                                .data.snapshot.value['name']
                                                .toString(),
                                            message:
                                                chatListDetails[index].message,
                                            count: chatListDetails[index]
                                                .messageCount,
                                            image: SERVER_ADDRESS +
                                                "/public/upload/" +
                                                snapshot.data.snapshot
                                                    .value['profile']
                                                    .toString().replaceAll(SERVER_ADDRESS +
                                                    "/public/upload/", ""),
                                            time: chatListDetails[index].time,
                                            type: chatListDetails[index].type,
                                            uid: chatListDetails[index].userUid,
                                            isSearching: isSearchClicked);
                                      } else {
                                        return Container();
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
              ),
            ],
          )),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSearchClicked ? SEARCH : CHAT,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: isSearchClicked
                        ? Icon(
                            Icons.cancel_outlined,
                            color: LIGHT_GREY_TEXT,
                            size: 30,
                          )
                        : Image.asset(
                            "assets/chatScreen/search.png",
                            height: 25,
                            width: 25,
                          ),
                    onPressed: () {
                      setState(() {
                        isSearchClicked = !isSearchClicked;
                        if (isSearchClicked) {
                          focusNode.requestFocus();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  messageCard(
      {bool isNewMessage,
      String name,
      int count,
      String message,
      String image,
      String time,
      int type,
      String uid,
      bool isSearching}) {
    return isSearching
        ? name.toLowerCase().contains(keyword.toLowerCase())
            ? Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: isNewMessage ? LIME : LIGHT_GREY,
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(name, uid)));
                  },
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CachedNetworkImage(
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              imageUrl: image,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Container(
                                      height: 75,
                                      width: 75,
                                      child: Center(
                                          child: Icon(
                                        Icons.account_circle,
                                        size: 50,
                                        color: isNewMessage ? WHITE : LIGHT_GREY_TEXT,
                                      ))),
                              errorWidget: (context, url, error) => Container(
                                height: 75,
                                width: 75,
                                child: Center(
                                  child: Icon(
                                    Icons.account_circle,
                                    size: 50,
                                    color: isNewMessage ? WHITE : LIGHT_GREY_TEXT,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          StreamBuilder<Event>(
                              stream: FirebaseDatabase.instance
                                  .reference()
                                  .child(uid)
                                  .child('presence')
                                  .onValue,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.none) {
                                  return Container();
                                } else {
                                  return snapshot.data != null
                                      ? snapshot.data.snapshot.value
                                          ? Container(
                                              height: 50,
                                              width: 50,
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: Image.asset(
                                                  "assets/chatScreen/status.png",
                                                  height: 15,
                                                  width: 15,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            )
                                          : Container()
                                      : Container();
                                }
                              })
                        ],
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isNewMessage
                                            ? FontWeight.w800
                                            : FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  messageTiming(
                                      DateTime.parse(time).toLocal() ?? "-"),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isNewMessage
                                          ? NAVY_BLUE
                                          : LIGHT_GREY_TEXT),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            typeToWidget(
                                int.parse(type.toString()), message, count),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Container()
        : Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: isNewMessage ? LIME : LIGHT_GREY,
                borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(name, uid)));
              },
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          imageUrl: image,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Container(
                                  height: 75,
                                  width: 75,
                                  child: Center(
                                      child: Icon(
                                    Icons.account_circle,
                                    size: 50,
                                    color: isNewMessage ? WHITE : LIGHT_GREY_TEXT,
                                  ))),
                          errorWidget: (context, url, error) => Container(
                            height: 75,
                            width: 75,
                            child: Center(
                              child: Icon(
                                Icons.account_circle,
                                size: 50,
                                color: isNewMessage ? WHITE : LIGHT_GREY_TEXT,
                              ),
                            ),
                          ),
                        ),
                      ),
                      StreamBuilder<Event>(
                          stream: FirebaseDatabase.instance
                              .reference()
                              .child(uid)
                              .child('presence')
                              .onValue,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.none) {
                              return Container();
                            } else {
                              return snapshot.data != null
                                  ? (snapshot.data.snapshot.value ?? true)
                                      ? Container(
                                          height: 50,
                                          width: 50,
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Image.asset(
                                              "assets/chatScreen/status.png",
                                              height: 15,
                                              width: 15,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      : Container()
                                  : Container();
                            }
                          })
                    ],
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: isNewMessage ? WHITE : BLACK,
                                    fontWeight: isNewMessage
                                        ? FontWeight.w800
                                        : FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              messageTiming(
                                  DateTime.parse(time).toLocal() ?? "-"),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isNewMessage
                                      ? WHITE.withOpacity(0.8)
                                      : LIGHT_GREY_TEXT),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        typeToWidget(
                            int.parse(type.toString()), message, count),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }

  loadChatList() async {
    ds = FirebaseDatabase.instance
        .reference()
        .child(uid.toString())
        .onValue
        .listen((event) {
      print("chat list : " + event.snapshot.value['chatlist'].toString());
      setState(() {
        chatListDetailsPA.clear();
        print("testing : " + "data retrievd from firebase");
      });
      try {
        Map<dynamic, dynamic>.from(event.snapshot.value['chatlist'])
            .forEach((key, values) {
          setState(() {
            print(key.toString());
            if (values['last_msg'] != null) {
              print("testing : " + "last message is not equal to null");
              chatListDetailsPA.add(ChatListDetails(
                channelId: values['channelId'],
                message: values['last_msg'],
                messageCount: values['messageCount'],
                time: values['time'],
                type: int.parse(values['type'].toString()),
                userUid: key.toString(),
              ));
            }
          });
        });
      } catch (e) {}

      if (chatListDetailsPA.length > 1) {
        chatListDetailsPA.sort((a, b) => b.time.compareTo(a.time));
      }
      setState(() {
        print("testing : " + "data added to chat list");
        chatListDetails.clear();
        chatListDetails.addAll(chatListDetailsPA);
      });

      for (int i = 0; i < chatListDetails.length; i++) {
        print("testing : " + chatListDetails[i].toString());
      }
    });
  }

  typeToWidget(int type, String msg, int count) {
    if (type == 1) {
      return Row(
        children: [
          Icon(
            Icons.photo,
            size: 15,
            color: count > 0 ? WHITE.withOpacity(0.8) : Colors.grey.shade700,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Photo",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w100,
                color: count > 0 ? WHITE.withOpacity(0.8) : LIGHT_GREY_TEXT),
          ),
        ],
      );
    } else if (type == 2) {
      return Row(
        children: [
          Icon(
            Icons.videocam,
            size: 15,
            color: count > 0 ? WHITE.withOpacity(0.8) : Colors.grey.shade700,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Video",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w100,
                color: count > 0 ? WHITE.withOpacity(0.8) : LIGHT_GREY_TEXT),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      return Text(
        msg,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w100,
            color: count > 0 ? WHITE.withOpacity(0.8) : LIGHT_GREY_TEXT),
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  String messageTiming(DateTime dateTime) {
    if (DateTime.now().difference(dateTime).inDays == 0) {
      return "${dateTime.hour} : ${dateTime.minute < 10 ? "0" + dateTime.minute.toString() : dateTime.minute}";
    } else if (DateTime.now().difference(dateTime).inDays == 1) {
      return "yesterday";
    } else {
      return DateTime.now().difference(dateTime).inDays.toString() +
          " days ago";
    }
  }
}

class ChatListDetails {
  String message;
  String time;
  int type;
  String channelId;
  int messageCount;
  String userUid;

  ChatListDetails(
      {this.message,
      this.time,
      this.type,
      this.channelId,
      this.messageCount,
      this.userUid});
}

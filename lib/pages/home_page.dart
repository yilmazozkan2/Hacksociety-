import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled1/pages/profile_page.dart';
import 'package:translator/translator.dart';

enum MenuItem { item1, item2, item3, item4, item5, item6, item7, item8, item9 }

class homePage extends StatefulWidget {
  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  final db = FirebaseFirestore.instance;
  var output;
  var output2;

  String name = '';
  String etiket = '';
  var tag;
  GoogleTranslator translator = GoogleTranslator();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          fontFamily: 'Noto'),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          fontFamily: 'Noto'),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: 60,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['home'.tr, 'profile'.tr]
                        .map((e) => Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: OutlinedButton(
                              onPressed: () {
                                if (e == 'profile'.tr) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage()),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: Text(
                                e,
                                style: TextStyle(
                                  fontFamily: 'Noto',
                                  color: Colors.blue,
                                ),
                              ),
                            )))
                        .toList()),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                child: Row(
                  children: [
                    Text(
                      'Hackersociety ',
                      style: TextStyle(
                          fontFamily: 'Noto',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '<|',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Noto',
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                          onChanged: (val) => initiateSearch(val),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey,
                            prefixIcon: Container(
                              padding: EdgeInsets.all(15),
                              child: Icon(Icons.search),
                              width: 18,
                            ),
                            hintText: "search".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          controller: _controller,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Text(output2 == null ? "" : output2.toString(),
                    style: TextStyle(
                        fontFamily: 'Noto',
                        fontSize: 17,
                        fontWeight: FontWeight.w400)),
              ),
              Divider(color: Colors.blue, height: 2, thickness: 2),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: name != "" && name != null
                      ? FirebaseFirestore.instance
                          .collection('Paylasimlar')
                          .where("searchIndex", arrayContains: name)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection("Paylasimlar")
                          .orderBy('paylasimTarihi', descending: true)
                          .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return new Text(
                        'Loading...',
                        style: TextStyle(
                          fontFamily: 'Noto',
                        ),
                      );
                    return new ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot myPost = snapshot.data!.docs[
                            index]; // documentsnapshotu dışarıya çıkarma yoksa resimler gözükürken tek resim gözükür
                        tag = myPost['etiket'];
                        return Center(
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    StreamBuilder<
                                        DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Paylasimlar')
                                          .doc()
                                          .snapshots(),
                                      builder: (_, snapshot) {
                                        if (snapshot.hasError)
                                          return Text(
                                              'Error = ${snapshot.error}');
                                        else if (snapshot.hasData) {
                                          output = snapshot.data!.data();
                                          return Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  myPost['KullaniciResmi'] !=
                                                          null
                                                      ? CircleAvatar(
                                                          radius: 27,
                                                          backgroundImage:
                                                              NetworkImage(myPost[
                                                                  'KullaniciResmi']))
                                                      : Center()
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                        return Center(
                                            child: CircularProgressIndicator());
                                      },
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(myPost['KullaniciEposta'],
                                            style: TextStyle(
                                                fontFamily: 'Noto',
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            DateFormat('dd/MM/yyyy - HH:mm')
                                                .format(
                                              myPost['paylasimTarihi'].toDate(),
                                            ),
                                            style: TextStyle(
                                                fontFamily: 'Noto',
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                    SizedBox(width: 130),
                                    PopupMenuButton(
                                        icon: Icon(
                                          Icons.g_translate,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onSelected: (value) {
                                          if (value == MenuItem.item1) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'tr')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                          if (value == MenuItem.item2) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'en')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                          if (value == MenuItem.item3) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'ar')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                          if (value == MenuItem.item4) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'es')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                          if (value == MenuItem.item5) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'fr')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                          if (value == MenuItem.item6) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'de')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                          if (value == MenuItem.item7) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'ru')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                          if (value == MenuItem.item8) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'hi')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                          if (value == MenuItem.item9) {
                                            translator
                                                .translate(
                                                    myPost['paylasimMetni'],
                                                    from: 'auto',
                                                    to: 'zh-cn')
                                                .then((value) {
                                              setState(() {
                                                output2 = value;
                                              });
                                            });
                                          }
                                        },
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                  value: MenuItem.item1,
                                                  child: Row(children: [
                                                    Text('🇹🇷 '),
                                                    Text("TURKISH",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                    const SizedBox(width: 15),
                                                  ])),
                                              PopupMenuItem(
                                                  value: MenuItem.item2,
                                                  child: Row(children: [
                                                    Text('🇺🇸 '),
                                                    Text("ENGLISH",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                    const SizedBox(width: 15),
                                                  ])),
                                              PopupMenuItem(
                                                  value: MenuItem.item3,
                                                  child: Row(children: [
                                                    Text('🇸🇦 '),
                                                    Text("ARABIC",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                    const SizedBox(width: 15),
                                                  ])),
                                              PopupMenuItem(
                                                  value: MenuItem.item4,
                                                  child: Row(children: [
                                                    Text('🇪🇸 '),
                                                    Text("SPANISH",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                    const SizedBox(width: 15),
                                                  ])),
                                              PopupMenuItem(
                                                  value: MenuItem.item5,
                                                  child: Row(children: [
                                                    Text('🇫🇷 '),
                                                    Text("FRENCH",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                    const SizedBox(width: 15),
                                                  ])),
                                              PopupMenuItem(
                                                  value: MenuItem.item6,
                                                  child: Row(children: [
                                                    Text('🇩🇪 '),
                                                    Text("GERMAN",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                    const SizedBox(width: 15),
                                                  ])),
                                              PopupMenuItem(
                                                  value: MenuItem.item7,
                                                  child: Row(children: [
                                                    Text('🇷🇺 '),
                                                    Text("RUSSIAN",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                    const SizedBox(width: 15),
                                                  ])),
                                              PopupMenuItem(
                                                  value: MenuItem.item8,
                                                  child: Row(children: [
                                                    Text('🇮🇳 '),
                                                    Text("INDIAN",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2),
                                                    const SizedBox(width: 15),
                                                  ])),
                                              PopupMenuItem(
                                                  value: MenuItem.item9,
                                                  child: Row(children: [
                                                    Text('🇨🇳 '),
                                                    Text(
                                                      "CHINESE",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2,
                                                    ),
                                                    const SizedBox(width: 15),
                                                  ])),
                                            ]),
                                  ],
                                ),
                                ListTile(
                                  title: Text(
                                    myPost['paylasimMetni'],
                                    style: TextStyle(
                                        fontFamily: 'Noto',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text('#$tag',
                                          style: TextStyle(
                                              fontFamily: 'Noto',
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue)),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      etiket = val.toLowerCase().trim();
    });
  }
}

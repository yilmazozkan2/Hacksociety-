import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:untitled1/pages/home_page.dart';

class Iskele extends StatefulWidget {
  @override
  State<Iskele> createState() => _IskeleState();
}

String avatarUrl = '';

class _IskeleState extends State<Iskele> {
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();

  Future<String> getUserProfileImageDownloadUrl(String uid) async {
    var storageRef = FirebaseStorage.instance.ref().child("user/profile/$uid");
    return await storageRef.getDownloadURL();
  }

  final List locale = [
    {'name': 'TURKISH', 'locale': Locale('tr')},
    {'name': 'ENGLISH', 'locale': Locale('en')},
    {'name': 'ARABIC', 'locale': Locale('ar')},
    {'name': 'SPANISH', 'locale': Locale('es')},
    {'name': 'FRENCH', 'locale': Locale('fr')},
    {'name': 'GERMAN', 'locale': Locale('de')},
    {'name': 'RUSSIAN', 'locale': Locale('ru')},
    {'name': 'INDIAN', 'locale': Locale('hi')},
    {'name': 'CHINESE', 'locale': Locale('zh-cn')},
  ];
  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  builddialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text('Choose App Language'),
            content: Container(
              width: double.maxFinite,
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            print((locale[index]['name']));
                            updateLanguage(locale[index]['locale']);
                          },
                          child: Text(
                            locale[index]['name'],
                          )),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: Colors.blue,
                    );
                  },
                  itemCount: locale.length),
            ),
          );
        });
  }

  Future<void> kayitOl() async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: textController1.text, password: textController2.text)
        .then((kullanici) {
      FirebaseFirestore.instance
          .collection("Kullanicilar")
          .doc(textController1.text)
          .set({
        'KullaniciEposta': textController1.text,
        'KullaniciSifre': textController2.text,
        'imageUrl':
            'https://i.pinimg.com/474x/7e/94/96/7e9496625377d3fc8821de9b0057c087.jpg'
      });
    });
  }

  girisYap() {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: textController1.text, password: textController2.text)
        .then((kullanici) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => homePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'selectlanguage'.tr,
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Noto',
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            builddialog(context);
                          },
                          icon: Icon(Icons.language),
                          color: Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hack Learning Platform',
                    style: TextStyle(
                        fontFamily: 'Noto',
                        fontSize: 34,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 34.0),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Container(
                            padding: EdgeInsets.all(15),
                            child: Icon(Icons.email),
                            width: 18,
                          ),
                          hintText: "name@example.com",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        controller: textController1,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Container(
                              padding: EdgeInsets.all(15),
                              child: Icon(Icons.password),
                              width: 18,
                            ),
                            hintText: "******",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 8))),
                        controller: textController2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        kayitOl();
                      },
                      child: Text('signup'.tr,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue))),
                  SizedBox(width: 30),
                  ElevatedButton(
                      onPressed: () {
                        girisYap();
                      },
                      child: Text('signin'.tr,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

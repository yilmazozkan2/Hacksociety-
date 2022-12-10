import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translator/translator.dart';
import 'package:untitled1/pages/home_page.dart';
import 'package:untitled1/pages/login_page.dart';
import 'package:path/path.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(child: KullaniciyaAit());
  }
}

class KullaniciyaAit extends StatefulWidget {
  @override
  State<KullaniciyaAit> createState() => _KullaniciyaAitState();
}

class _KullaniciyaAitState extends State<KullaniciyaAit> {
  final TextEditingController _controller = TextEditingController();
  final _controller2 = TextEditingController(text: "entertag".tr);

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? file; //galeriden seçilen, yüklenen ve silinen dosya
  String imageUrl = '';
  final db = FirebaseFirestore.instance;
  var output;

  String etiket = '';
  var image;
  var tag;
  GoogleTranslator translator = GoogleTranslator();

//Galeriden resim seçme
  Future pickImageGallery() async {
    image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    }
  }

  void _showPicker(context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('gallery'.tr),
                    onTap: () {
                      pickImageGallery();
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          ));
        });
  }

/*Firebase firestore veri tabanına resim Yükleme
  Oturum açmış kullanıcının email adresine göre bilgilerini güncelliyor karışmıyor  */
  uploadProfileImage(String uid) async {
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('profileImage/${basename(file!.path)}}');
    UploadTask uploadTask = reference.putFile(File(file!.path));
    TaskSnapshot snapshot = await uploadTask;
    await uploadTask.whenComplete(() async {
      imageUrl = await snapshot.ref.getDownloadURL();
      if (imageUrl.isNotEmpty) {
        var db = FirebaseFirestore.instance;
        //fotoğraf varsa imageurl üzerine yaz yoksa internetteki spiderman resmini göster
        DocumentReference ref =
            db.collection('Kullanicilar').doc(auth.currentUser!.email);
        ref.set(
          {
            //'KullaniciId': uid,
            'imageUrl': imageUrl
          },
          SetOptions(merge: true),
        );
      } else {
        DocumentReference ref =
            db.collection('Kullanicilar').doc(auth.currentUser!.email);
        ref.set(
          {
            //'KullaniciId': uid,
            'imageUrl':
                'https://upload.wikimedia.org/wikipedia/en/b/bf/Tobey_Maguire_as_Spider-Man.jpg'
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  void addDatabase(String shareText) {
    List<String> splitList = shareText.split(" ");
    List<String> indexList = [];

    for (int i = 0; i < splitList.length; i++) {
      for (int y = 1; y < splitList[i].length + 1; y++) {
        indexList.add(splitList[i].substring(0, y).toLowerCase());
      }
    }
    print(indexList);
    FirebaseFirestore.instance.collection('Paylasimlar').add({
      'paylasimMetni': _controller.text,
      'paylasimTarihi': Timestamp.now(),
      'KullaniciId': auth.currentUser!.uid,
      'KullaniciEposta': auth.currentUser!.email,
      'KullaniciResmi': output['imageUrl'],
      'searchIndex': indexList,
      'etiket': etiket,
    });
  }

  Padding _inputFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "enteratext".tr,
                filled: true,
                fillColor: Colors.grey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              controller: _controller,
            ),
          ),
          IconButton(
              onPressed: () {
                addDatabase(_controller.text);

                _controller.clear();
              },
              icon: const Icon(Icons.send)),
        ],
      ),
    );
  }

//Fotoğraf çağırma
  Widget calImage(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Kullanicilar')
              .doc(auth.currentUser!.email)
              .snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasError)
              return Text('Error = ${snapshot.error}');
            else if (snapshot.hasData) {
              output = snapshot.data!.data();
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    output!['imageUrl'] == ""
                        ? CircleAvatar(
                            radius: 55,
                            backgroundImage: NetworkImage(output['imageUrl']))
                        : Center(
                            child: CircleAvatar(
                                radius: 55,
                                backgroundImage:
                                    NetworkImage(output['imageUrl'])),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        output['KullaniciEposta'],
                        style: TextStyle(
                            fontFamily: 'Noto',
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light, fontFamily: 'Noto'),
      darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: 'Noto'),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 60,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['home'.tr, 'profile'.tr, 'signout'.tr]
                        .map((e) => Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: OutlinedButton(
                              onPressed: () {
                                if (e == 'home'.tr) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => homePage()),
                                  );
                                }
                                if (e == 'signout'.tr) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Iskele(),
                                    ),
                                    (route) => false,
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
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    calImage(context),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      OutlinedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: () {
                            _showPicker(context);
                          },
                          child: Text(
                            'selectfromgallery'.tr,
                            style: TextStyle(
                              fontFamily: 'Noto',
                              color: Colors.blue,
                            ),
                          )),
                      SizedBox(width: 5),
                      OutlinedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: () {
                            uploadProfileImage(auth.currentUser!.uid);
                          },
                          child: Text(
                            'saveselectedimage'.tr,
                            style: TextStyle(
                              fontFamily: 'Noto',
                              color: Colors.blue,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'mypost'.tr,
                      style: TextStyle(
                          fontFamily: 'Noto',
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Paylasimlar')
                      .where('KullaniciId', isEqualTo: auth.currentUser!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData)
                      return new Text(
                        'loading'.tr,
                        style: TextStyle(
                          fontFamily: 'Noto',
                        ),
                      );
                    return new ListView(
                      shrinkWrap: false,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        tag = document['etiket'];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              new SelectableText(
                                document['paylasimMetni'],
                                style: TextStyle(
                                  fontFamily: 'Noto',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              //new Text(document['paylasimMetni']),
                              Text(
                                DateFormat('dd/MM/yyyy     HH:mm').format(
                                  document['paylasimTarihi'].toDate(),
                                ),
                                style: TextStyle(
                                  fontFamily: 'Noto',
                                ),
                              ),
                              Text('#$tag',
                                  style: TextStyle(
                                      fontFamily: 'Noto',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              Container(
                                child: TextFormField(
                                  controller: _controller2,
                                  decoration: InputDecoration.collapsed(
                                    hintText: "entertag".tr,
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Noto',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                  onChanged: (_val) {
                                    etiket = _val;
                                  },
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('Paylasimlar')
                                              .doc(document.id)
                                              .update({
                                            'etiket': etiket,
                                          });
                                          _controller2.clear();
                                        },
                                        child: Text('savetag'.tr,
                                            style: TextStyle(
                                                fontFamily: 'Noto',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue))),
                                    TextButton(
                                      onPressed: () => FirebaseFirestore
                                          .instance
                                          .collection('Paylasimlar')
                                          .doc(document.id)
                                          .delete(),
                                      child: Text(
                                        'deletepost'.tr,
                                        style: TextStyle(
                                            fontFamily: 'Noto',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue),
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              _inputFields(),
            ],
          ),
        ),
      ),
    );
  }
}

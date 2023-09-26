import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:ups_trackdesk/services/local_storage/client_db.dart';
import 'package:ups_trackdesk/services/local_storage/crud_local_services.dart';
import 'package:ups_trackdesk/utils/global_methodes.dart';
import 'package:ups_trackdesk/views/form_step1.dart';
import 'package:ups_trackdesk/views/text_widget.dart';

import '../services/local_storage/crud_exceptions.dart';
import '../utils/utils.dart';
import 'navbar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  static const routeName = "/HomePage";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final LabelService labelService;
  late final ClientDbService clientService;

  @override
  void initState() {
    labelService = LabelService();
    clientService = ClientDbService();

    _fetchData();

    super.initState();
  }

  Future<void> _fetchData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Client")
          .get()
          .then((QuerySnapshot client) => client.docs.forEach((element) {
                clientService.createBordereau(
                    id: element.get("numbreOfAcount"),
                    name: element.get("Name"),
                    adress: element.get("Adresse"),
                    ville: element.get("Ville"),
                    zip: element.get("Zip"));
              }))
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      GlobalMethods.ErrorDialog(
          subtitle: "Vous étes hors ligne ! ", context: context);
    }
  }

  Future<DataBaseUser> _getfireStoreData() async {
    DataBaseUser? user;
    try {
      user = await labelService.getUser(userId: userId);
    } on CouldNoteFindUser {
      final firestoreData = await FirebaseFirestore.instance
          .collection('UserOfApp')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get();
      final name = firestoreData.data()!['UserName'];
      try {
        user = await labelService.getOrCreateUser(
            userId: userId, profilPic: profilPic, userName: name);
      } catch (e) {
        if (mounted) {
          GlobalMethods.ErrorDialog(subtitle: e.toString(), context: context);
        }
      }
      user = await labelService.getOrCreateUser(
          userId: userId, profilPic: profilPic, userName: name);
    }
    return user;
  }

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  String profilPic = "";
  @override
  Widget build(BuildContext context) {
    final size = Utils(context).screenSize;
    return FutureBuilder(
      future: _getfireStoreData(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData && snapshot.data != null) {
              return Scaffold(
                resizeToAvoidBottomInset: true,
                drawer: const NavBar(),
                appBar: AppBar(
                  leading: Builder(
                    builder: ((BuildContext context) {
                      return IconButton(
                          icon: const Icon(Icons.list),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          });
                    }),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: size.height * 0.18,
                        ),
                        Row(
                          children: [
                            TextWidget(
                              text: snapshot.data!.userName,
                              color: Theme.of(context).colorScheme.secondary,
                              textsize: 28,
                              isTitle: true,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Icon(
                              IconlyLight.star,
                              size: 40,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)),
                          child: Image.asset(
                            "assets/img/ups_driver.jpg",
                            fit: BoxFit.fill,
                            height: size.height * 0.2,
                            width: double.infinity,
                          ),
                        ),
                        SizedBox(height: size.height * 0.2),
                        Material(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                FirstStep.routeName,
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextWidget(
                                    text: "Ajouter",
                                    color: Colors.white,
                                    textsize: 24),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    IconlyBold.plus,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }

          default:
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
        }
      },
    );
  }
}

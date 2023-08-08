import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:ups_trackdesk/services/local_storage/crud_local_services.dart';
import 'package:ups_trackdesk/utils/firebase_consts.dart';
import 'package:ups_trackdesk/views/form_step1.dart';
import 'package:ups_trackdesk/views/text_widget.dart';

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
  @override
  void initState() {
    labelService = LabelService();
    _openDatabase();
    super.initState();
  }

  Future<void> _openDatabase() async {
    try {
      await labelService.open();
      print("Database opened successfully.");
    } catch (e) {
      print("Error opening database: $e");
    }
  }

  final String userId = authInstance.currentUser!.uid;
  final String userName = authInstance.currentUser!.email!;
  final String profilPic =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/User_icon_2.svg/220px-User_icon_2.svg.png";
  @override
  Widget build(BuildContext context) {
    final size = Utils(context).screenSize;
    return FutureBuilder(
      future: labelService.getOrCreateUser(
          userId: userId, profilPic: profilPic, userName: userName),
      builder: (context, snapshot) {
        print("Snapshot: ${snapshot.connectionState}");

        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Scaffold(
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
              body: Padding(
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
                          text: 'Bonjour Mouhamed',
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
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
            );
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

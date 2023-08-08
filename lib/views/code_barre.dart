import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:ups_trackdesk/provider/data_provider.dart';
import 'package:ups_trackdesk/views/last_step.dart';
import 'package:ups_trackdesk/views/text_widget.dart';

import '../utils/utils.dart';
import 'navbar.dart';

class Barcode extends StatefulWidget {
  @override
  _BarcodeState createState() => _BarcodeState();
  static const routeName = "/CodeBare";
}

class _BarcodeState extends State<Barcode> {
  String _scanBarcode = 'Scanne';
  bool isNumeric(String? str) {
    if (str == null || str.isEmpty) {
      return false;
    }

    return double.tryParse(str) != null;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (isNumeric(barcodeScanRes)) {
        _scanBarcode = barcodeScanRes;
      } else {
        _scanBarcode = 'Echec, réessayez';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    if (provider.getFormData['edit'] != null) {
      setState(() {
        _scanBarcode = provider.getFormData['edit']!.bareCode;
      });
    }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextWidget(
                      text: "Etape 4 - Code Barre ",
                      color: Theme.of(context).hintColor,
                      textsize: 12),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                height: 0.5,
              ),
              const SizedBox(
                height: 32,
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Image.asset(
                  "assets/img/code-barre.jpg",
                  fit: BoxFit.fill,
                  height: Utils(context).screenSize.height * 0.2,
                  width: double.infinity,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              InkWell(
                onTap: () => scanBarcodeNormal(),
                child: Material(
                  color: const Color.fromARGB(255, 77, 16, 16),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          IconlyBold.camera,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextWidget(
                            text: _scanBarcode,
                            color: Colors.white,
                            textsize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 64,
              ),
              SizedBox(
                width: Utils(context).screenSize.width * 0.9,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Material(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    IconlyBold.arrow_left_2,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: TextWidget(
                                      text: "Retourner",
                                      color: Colors.white,
                                      textsize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Flexible(
                      flex: 2,
                      child: Material(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            if (isNumeric(_scanBarcode)) {
                              provider.setBareCode = _scanBarcode;
                              Navigator.of(context)
                                  .pushNamed(LastStep.routeName);
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(4),
                                child: TextWidget(
                                    text: "Continuer",
                                    color: Colors.white,
                                    textsize: 20),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  IconlyBold.arrow_right_2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ups_trackdesk/provider/data_provider.dart';
import 'package:ups_trackdesk/services/local_storage/crud_exceptions.dart';
import 'package:ups_trackdesk/views/text_widget.dart';
import 'package:ups_trackdesk/views/widget/loading_manager.dart';
import 'package:uuid/uuid.dart';

import '../services/local_storage/crud_local_services.dart';
import '../utils/const.dart';
import '../utils/global_methodes.dart';
import '../utils/utils.dart';
import 'home_page.dart';
import 'navbar.dart';

class LastStep extends StatefulWidget {
  const LastStep({super.key});
  static const routeName = "/LastStep";

  @override
  State<LastStep> createState() => _LastStepState();
}

class _LastStepState extends State<LastStep> {
  Uint8List? _bordoreau;
  Uint8List? _ackReceipt;

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      final fileReaded = await file.readAsBytes();

      return await testComporessList(fileReaded);
    } else {
      throw NoImageSelected();
    }
  }

  bool _isLoading = false;
  Future<Uint8List> testComporessList(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 1280,
      minWidth: 720,
      quality: 80,
    );

    return result;
  }

  void _updateForm(bool isWithAck) async {
    final provider = Provider.of<DataProvider>(context, listen: false);
    final bool _checkBrd = _bordoreau != null;
    final bool _checkAll = _checkBrd && _ackReceipt != null;

    final bool isValid = isWithAck ? _checkAll : _checkBrd;
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      final String uid = const Uuid().v4();

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final user = service.getUser(userId: userId);
      provider.collectLastStepData(base64.encode(_bordoreau!),
          _ackReceipt == null ? '' : base64.encode(_ackReceipt!));
      provider.addItem(uid);
      final label = await service.getBordereau(
          bareCode: provider.getFormData[uid]!.bareCode);
      try {
        if (isWithAck) {
          final bref = FirebaseStorage.instance
              .ref()
              .child('images/bordoreau')
              .child('$uid.jpg');
          await bref.putData(_bordoreau!).timeout(const Duration(seconds: 10));
          final String bordoreauUrl =
              await bref.getDownloadURL().timeout(const Duration(seconds: 10));
          final ackref = FirebaseStorage.instance
              .ref()
              .child('images/ack')
              .child('$uid.jpg');
          await ackref
              .putData(_ackReceipt!)
              .timeout(const Duration(seconds: 10));
          final String ackUrl = await ackref
              .getDownloadURL()
              .timeout(const Duration(seconds: 10));
          provider.addItem(uid);
          await FirebaseFirestore.instance
              .collection("handForm")
              .doc(
                provider.getFormData[uid]!.bareCode,
              )
              .set({
            'bareCode': provider.getFormData[uid]!.bareCode,
            'userId': userId,
            'NameExp': provider.getFormData[uid]!.nameExp,
            'adressExp': provider.getFormData[uid]!.adressExp,
            'villeexp': provider.getFormData[uid]!.villeexp,
            'zipExp': provider.getFormData[uid]!.zipExp,
            'nameDest': provider.getFormData[uid]!.nameDest,
            'adressDest': provider.getFormData[uid]!.adressDest,
            'villeDest': provider.getFormData[uid]!.villeDest,
            'zipDest': provider.getFormData[uid]!.zipDest,
            'typeDeLivraison': provider.getFormData[uid]!.typeDeLivraison,
            'typeDePayment': provider.getFormData[uid]!.typeDePayment,
            'packageWeight': provider.getFormData[uid]!.packageWeight,
            'numbreOfItems': provider.getFormData[uid]!.numbreOfItems,
            'bordoreauUrl': bordoreauUrl,
            'ackOfReceipt': ackUrl,
            'addedDate': label.addedDate,
            'Created': DateTime.now()
          });
        } else {
          final bref = FirebaseStorage.instance
              .ref()
              .child('images/bordoreau')
              .child('$uid.jpg');
          await bref.putData(_bordoreau!).timeout(const Duration(seconds: 10));
          final String bordoreauUrl = await bref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection("handForm")
              .doc(
                provider.getFormData[uid]!.bareCode,
              )
              .set({
            'bareCode': provider.getFormData[uid]!.bareCode,
            'userId': userId,
            'NameExp': provider.getFormData[uid]!.nameExp,
            'adressExp': provider.getFormData[uid]!.adressExp,
            'villeexp': provider.getFormData[uid]!.villeexp,
            'zipExp': provider.getFormData[uid]!.zipExp,
            'nameDest': provider.getFormData[uid]!.nameDest,
            'adressDest': provider.getFormData[uid]!.adressDest,
            'villeDest': provider.getFormData[uid]!.villeDest,
            'zipDest': provider.getFormData[uid]!.zipDest,
            'typeDeLivraison': provider.getFormData[uid]!.typeDeLivraison,
            'typeDePayment': provider.getFormData[uid]!.typeDePayment,
            'packageWeight': provider.getFormData[uid]!.packageWeight,
            'numbreOfItems': provider.getFormData[uid]!.numbreOfItems,
            'bordoreauUrl': bordoreauUrl,
            'ackOfReceipt': '',
            'addedDate': label.addedDate,
            'Created': DateTime.now()
          });
        }
        service.updateBordereau(
          bordereau: label,
          userId: userId,
          nameExp: provider.getFormData[uid]!.nameExp,
          adressExp: provider.getFormData[uid]!.adressExp,
          villeexp: provider.getFormData[uid]!.villeexp,
          zipExp: provider.getFormData[uid]!.zipExp,
          nameDest: provider.getFormData[uid]!.nameDest,
          adressDest: provider.getFormData[uid]!.adressDest,
          villeDest: provider.getFormData[uid]!.villeDest,
          zipDest: provider.getFormData[uid]!.zipDest,
          numbreOfitems: provider.getFormData[uid]!.numbreOfItems,
          packageWeight: provider.getFormData[uid]!.packageWeight,
          typeDeLivraison: provider.getFormData[uid]!.typeDeLivraison,
          typeDePayment: provider.getFormData[uid]!.typeDePayment,
          bordoreauUrl: provider.getFormData[uid]!.bordoreauUrl,
          ackReceipt: provider.getFormData[uid]!.ackReceipt,
          addedDate: label.addedDate,
          isSync: true,
        );

        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(MyHomePage.routeName, (route) => false);
        }
      } on TimeoutException {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          GlobalMethods.WarningDialog(
              title: "Probleme de connexion",
              subtitle: "voulez vous enregistrer et essayer plus tard? ",
              context: context,
              fct: () async {
                service.updateBordereau(
                  bordereau: label,
                  userId: userId,
                  nameExp: provider.getFormData[uid]!.nameExp,
                  adressExp: provider.getFormData[uid]!.adressExp,
                  villeexp: provider.getFormData[uid]!.villeexp,
                  zipExp: provider.getFormData[uid]!.zipExp,
                  nameDest: provider.getFormData[uid]!.nameDest,
                  adressDest: provider.getFormData[uid]!.adressDest,
                  villeDest: provider.getFormData[uid]!.villeDest,
                  zipDest: provider.getFormData[uid]!.zipDest,
                  numbreOfitems: provider.getFormData[uid]!.numbreOfItems,
                  packageWeight: provider.getFormData[uid]!.packageWeight,
                  typeDeLivraison: provider.getFormData[uid]!.typeDeLivraison,
                  typeDePayment: provider.getFormData[uid]!.typeDePayment,
                  bordoreauUrl: provider.getFormData[uid]!.bordoreauUrl,
                  ackReceipt: provider.getFormData[uid]!.ackReceipt,
                  addedDate: label.addedDate,
                  isSync: false,
                );
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      MyHomePage.routeName, (route) => false);
                }
              });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          GlobalMethods.ErrorDialog(subtitle: 'Erreur !', context: context);
        }
      }
    }
  }

  void _submitForm(bool isWithAck) async {
    final provider = Provider.of<DataProvider>(context, listen: false);
    final bool _checkBrd = _bordoreau != null;
    final bool _checkAll = _checkBrd && _ackReceipt != null;

    final bool isValid = isWithAck ? _checkAll : _checkBrd;

    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      final String uid = const Uuid().v4();
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final user = service.getUser(userId: userId);
      provider.collectLastStepData(base64.encode(_bordoreau!),
          _ackReceipt == null ? '' : base64.encode(_ackReceipt!));
      provider.addItem(uid);
      try {
        await service.getBordereau(
            bareCode: provider.getFormData[uid]!.bareCode);
        if (mounted) {
          GlobalMethods.WarningDialog(
              subtitle: "Voulez vous l'écraser?",
              context: context,
              fct: () async {
                setState(() {
                  _isLoading = true;
                });
                await service.deleteBordereau(
                    barecode: provider.getFormData[uid]!.bareCode);
                try {
                  if (isWithAck) {
                    final bref = FirebaseStorage.instance
                        .ref()
                        .child('images/bordoreau')
                        .child('$uid.jpg');
                    await bref
                        .putData(_bordoreau!)
                        .timeout(const Duration(seconds: 10));
                    final String bordoreauUrl = await bref
                        .getDownloadURL()
                        .timeout(const Duration(seconds: 10));
                    final ackref = FirebaseStorage.instance
                        .ref()
                        .child('images/ack')
                        .child('$uid.jpg');
                    await ackref
                        .putData(_ackReceipt!)
                        .timeout(const Duration(seconds: 10));
                    final String ackUrl = await ackref
                        .getDownloadURL()
                        .timeout(const Duration(seconds: 10));
                    provider.addItem(uid);
                    await FirebaseFirestore.instance
                        .collection("handForm")
                        .doc(provider.getFormData[uid]!.bareCode)
                        .set({
                      'bareCode': provider.getFormData[uid]!.bareCode,
                      'userId': userId,
                      'NameExp': provider.getFormData[uid]!.nameExp,
                      'adressExp': provider.getFormData[uid]!.adressExp,
                      'villeexp': provider.getFormData[uid]!.villeexp,
                      'zipExp': provider.getFormData[uid]!.zipExp,
                      'nameDest': provider.getFormData[uid]!.nameDest,
                      'adressDest': provider.getFormData[uid]!.adressDest,
                      'villeDest': provider.getFormData[uid]!.villeDest,
                      'zipDest': provider.getFormData[uid]!.zipDest,
                      'typeDeLivraison':
                          provider.getFormData[uid]!.typeDeLivraison,
                      'typeDePayment': provider.getFormData[uid]!.typeDePayment,
                      'packageWeight': provider.getFormData[uid]!.packageWeight,
                      'numbreOfItems': provider.getFormData[uid]!.numbreOfItems,
                      'bordoreauUrl': bordoreauUrl,
                      'ackOfReceipt': ackUrl,
                      'addedDate':
                          "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()} à  ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}h",
                      'Created': DateTime.now()
                    });
                  } else {
                    final bref = FirebaseStorage.instance
                        .ref()
                        .child('images/bordoreau')
                        .child('$uid.jpg');
                    await bref
                        .putData(_bordoreau!)
                        .timeout(const Duration(seconds: 10));
                    final String bordoreauUrl = await bref.getDownloadURL();

                    await FirebaseFirestore.instance
                        .collection("handForm")
                        .doc(provider.getFormData[uid]!.bareCode)
                        .set({
                      'bareCode': provider.getFormData[uid]!.bareCode,
                      'userId': userId,
                      'NameExp': provider.getFormData[uid]!.nameExp,
                      'adressExp': provider.getFormData[uid]!.adressExp,
                      'villeexp': provider.getFormData[uid]!.villeexp,
                      'zipExp': provider.getFormData[uid]!.zipExp,
                      'nameDest': provider.getFormData[uid]!.nameDest,
                      'adressDest': provider.getFormData[uid]!.adressDest,
                      'villeDest': provider.getFormData[uid]!.villeDest,
                      'zipDest': provider.getFormData[uid]!.zipDest,
                      'typeDeLivraison':
                          provider.getFormData[uid]!.typeDeLivraison,
                      'typeDePayment': provider.getFormData[uid]!.typeDePayment,
                      'packageWeight': provider.getFormData[uid]!.packageWeight,
                      'numbreOfItems': provider.getFormData[uid]!.numbreOfItems,
                      'bordoreauUrl': bordoreauUrl,
                      'ackOfReceipt': '',
                      'addedDate':
                          "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()} à  ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}h",
                      'Created': DateTime.now()
                    });
                  }

                  service.createBordereau(
                      owner: await user,
                      userId: userId,
                      nameExp: provider.getFormData[uid]!.nameExp,
                      adressExp: provider.getFormData[uid]!.adressExp,
                      villeexp: provider.getFormData[uid]!.villeexp,
                      zipExp: provider.getFormData[uid]!.zipExp,
                      nameDest: provider.getFormData[uid]!.nameDest,
                      adressDest: provider.getFormData[uid]!.adressDest,
                      villeDest: provider.getFormData[uid]!.villeDest,
                      zipDest: provider.getFormData[uid]!.zipDest,
                      numbreOfitems: provider.getFormData[uid]!.numbreOfItems,
                      packageWeight: provider.getFormData[uid]!.packageWeight,
                      typeDeLivraison:
                          provider.getFormData[uid]!.typeDeLivraison,
                      typeDePayment: provider.getFormData[uid]!.typeDePayment,
                      bordoreauUrl: provider.getFormData[uid]!.bordoreauUrl,
                      ackReceipt: provider.getFormData[uid]!.ackReceipt,
                      addedDate:
                          "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()} à  ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}h",
                      isSync: true,
                      bareCode: provider.getFormData[uid]!.bareCode);
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        MyHomePage.routeName, (route) => false);
                  }
                } on TimeoutException {
                  setState(() {
                    _isLoading = false;
                  });

                  GlobalMethods.WarningDialog(
                      title: "Probleme de connexion",
                      subtitle:
                          "voulez vous enregistrer et essayer plus tard? ",
                      context: context,
                      fct: () async {
                        service.createBordereau(
                            owner: await user,
                            userId: userId,
                            nameExp: provider.getFormData[uid]!.nameExp,
                            adressExp: provider.getFormData[uid]!.adressExp,
                            villeexp: provider.getFormData[uid]!.villeexp,
                            zipExp: provider.getFormData[uid]!.zipExp,
                            nameDest: provider.getFormData[uid]!.nameDest,
                            adressDest: provider.getFormData[uid]!.adressDest,
                            villeDest: provider.getFormData[uid]!.villeDest,
                            zipDest: provider.getFormData[uid]!.zipDest,
                            numbreOfitems:
                                provider.getFormData[uid]!.numbreOfItems,
                            packageWeight:
                                provider.getFormData[uid]!.packageWeight,
                            typeDeLivraison:
                                provider.getFormData[uid]!.typeDeLivraison,
                            typeDePayment:
                                provider.getFormData[uid]!.typeDePayment,
                            bordoreauUrl:
                                provider.getFormData[uid]!.bordoreauUrl,
                            ackReceipt: provider.getFormData[uid]!.ackReceipt,
                            addedDate:
                                "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()} à  ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}h",
                            isSync: false,
                            bareCode: provider.getFormData[uid]!.bareCode);
                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              MyHomePage.routeName, (route) => false);
                        }
                      });
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  GlobalMethods.ErrorDialog(
                      subtitle: 'Erreur !', context: context);
                }
              },
              title: 'Sa existe déja');
        }
        setState(() {
          _isLoading = false;
        });
      } on CouldNoteFindBordereau {
        try {
          if (isWithAck) {
            final bref = FirebaseStorage.instance
                .ref()
                .child('images/bordoreau')
                .child('$uid.jpg');
            await bref
                .putData(_bordoreau!)
                .timeout(const Duration(seconds: 10));
            final String bordoreauUrl = await bref
                .getDownloadURL()
                .timeout(const Duration(seconds: 10));
            final ackref = FirebaseStorage.instance
                .ref()
                .child('images/ack')
                .child('$uid.jpg');
            await ackref
                .putData(_ackReceipt!)
                .timeout(const Duration(seconds: 10));
            final String ackUrl = await ackref
                .getDownloadURL()
                .timeout(const Duration(seconds: 10));
            provider.addItem(uid);
            await FirebaseFirestore.instance
                .collection("handForm")
                .doc(provider.getFormData[uid]!.bareCode)
                .set({
              'bareCode': provider.getFormData[uid]!.bareCode,
              'userId': userId,
              'NameExp': provider.getFormData[uid]!.nameExp,
              'adressExp': provider.getFormData[uid]!.adressExp,
              'villeexp': provider.getFormData[uid]!.villeexp,
              'zipExp': provider.getFormData[uid]!.zipExp,
              'nameDest': provider.getFormData[uid]!.nameDest,
              'adressDest': provider.getFormData[uid]!.adressDest,
              'villeDest': provider.getFormData[uid]!.villeDest,
              'zipDest': provider.getFormData[uid]!.zipDest,
              'typeDeLivraison': provider.getFormData[uid]!.typeDeLivraison,
              'typeDePayment': provider.getFormData[uid]!.typeDePayment,
              'packageWeight': provider.getFormData[uid]!.packageWeight,
              'numbreOfItems': provider.getFormData[uid]!.numbreOfItems,
              'bordoreauUrl': bordoreauUrl,
              'ackOfReceipt': ackUrl,
              'addedDate':
                  "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()} à  ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}h",
              'Created': DateTime.now()
            });
          } else {
            final bref = FirebaseStorage.instance
                .ref()
                .child('images/bordoreau')
                .child('$uid.jpg');
            await bref
                .putData(_bordoreau!)
                .timeout(const Duration(seconds: 10));
            final String bordoreauUrl = await bref.getDownloadURL();

            await FirebaseFirestore.instance
                .collection("handForm")
                .doc(provider.getFormData[uid]!.bareCode)
                .set({
              'bareCode': provider.getFormData[uid]!.bareCode,
              'userId': userId,
              'NameExp': provider.getFormData[uid]!.nameExp,
              'adressExp': provider.getFormData[uid]!.adressExp,
              'villeexp': provider.getFormData[uid]!.villeexp,
              'zipExp': provider.getFormData[uid]!.zipExp,
              'nameDest': provider.getFormData[uid]!.nameDest,
              'adressDest': provider.getFormData[uid]!.adressDest,
              'villeDest': provider.getFormData[uid]!.villeDest,
              'zipDest': provider.getFormData[uid]!.zipDest,
              'typeDeLivraison': provider.getFormData[uid]!.typeDeLivraison,
              'typeDePayment': provider.getFormData[uid]!.typeDePayment,
              'packageWeight': provider.getFormData[uid]!.packageWeight,
              'numbreOfItems': provider.getFormData[uid]!.numbreOfItems,
              'bordoreauUrl': bordoreauUrl,
              'ackOfReceipt': '',
              'addedDate':
                  "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()} à  ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}h",
              'Created': DateTime.now()
            });
          }

          service.createBordereau(
              owner: await user,
              userId: userId,
              nameExp: provider.getFormData[uid]!.nameExp,
              adressExp: provider.getFormData[uid]!.adressExp,
              villeexp: provider.getFormData[uid]!.villeexp,
              zipExp: provider.getFormData[uid]!.zipExp,
              nameDest: provider.getFormData[uid]!.nameDest,
              adressDest: provider.getFormData[uid]!.adressDest,
              villeDest: provider.getFormData[uid]!.villeDest,
              zipDest: provider.getFormData[uid]!.zipDest,
              numbreOfitems: provider.getFormData[uid]!.numbreOfItems,
              packageWeight: provider.getFormData[uid]!.packageWeight,
              typeDeLivraison: provider.getFormData[uid]!.typeDeLivraison,
              typeDePayment: provider.getFormData[uid]!.typeDePayment,
              bordoreauUrl: provider.getFormData[uid]!.bordoreauUrl,
              ackReceipt: provider.getFormData[uid]!.ackReceipt,
              addedDate:
                  "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()} à  ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}h",
              isSync: true,
              bareCode: provider.getFormData[uid]!.bareCode);
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                MyHomePage.routeName, (route) => false);
          }
        } on TimeoutException {
          setState(() {
            _isLoading = false;
          });

          GlobalMethods.WarningDialog(
              title: "Probleme de connexion",
              subtitle: "voulez vous enregistrer et essayer plus tard? ",
              context: context,
              fct: () async {
                service.createBordereau(
                    owner: await user,
                    userId: userId,
                    nameExp: provider.getFormData[uid]!.nameExp,
                    adressExp: provider.getFormData[uid]!.adressExp,
                    villeexp: provider.getFormData[uid]!.villeexp,
                    zipExp: provider.getFormData[uid]!.zipExp,
                    nameDest: provider.getFormData[uid]!.nameDest,
                    adressDest: provider.getFormData[uid]!.adressDest,
                    villeDest: provider.getFormData[uid]!.villeDest,
                    zipDest: provider.getFormData[uid]!.zipDest,
                    numbreOfitems: provider.getFormData[uid]!.numbreOfItems,
                    packageWeight: provider.getFormData[uid]!.packageWeight,
                    typeDeLivraison: provider.getFormData[uid]!.typeDeLivraison,
                    typeDePayment: provider.getFormData[uid]!.typeDePayment,
                    bordoreauUrl: provider.getFormData[uid]!.bordoreauUrl,
                    ackReceipt: provider.getFormData[uid]!.ackReceipt,
                    addedDate:
                        "${DateTime.now().day.toString()}/${DateTime.now().month.toString()}/${DateTime.now().year.toString()} à  ${DateTime.now().hour.toString()}:${DateTime.now().minute.toString()}h",
                    isSync: false,
                    bareCode: provider.getFormData[uid]!.bareCode);
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      MyHomePage.routeName, (route) => false);
                }
              });
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          GlobalMethods.ErrorDialog(subtitle: 'Erreur !', context: context);
        }
      }
    }
  }

  late final LabelService service;
  @override
  void initState() {
    service = LabelService();
    super.initState();
  }

  bool _notChanged = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    final size = Utils(context).screenSize;
    bool isOnEdit = false;
    final bool _isWithAck = provider.isAck;
    if (provider.getFormData['edit'] != null) {
      setState(() {
        if (_notChanged) {
          _bordoreau =
              base64.decode(provider.getFormData['edit']!.bordoreauUrl);
          if (_isWithAck) {
            _ackReceipt =
                base64.decode(provider.getFormData['edit']!.ackReceipt);
          }
        }
        isOnEdit = true;
      });
    }
    print(isOnEdit);
    return LoadingManger(
      isLoading: _isLoading,
      child: Scaffold(
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
                        text: "Etape  5 - Documents ",
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
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Divider(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  height: 0.5,
                ),
                const SizedBox(
                  height: 32,
                ),
                TextWidget(
                  text: "Bordeureux",
                  color: Theme.of(context).colorScheme.secondary,
                  textsize: 18,
                  isTitle: true,
                ),
                const SizedBox(
                  height: 16,
                ),
                InkWell(
                  onTap: () async {
                    Uint8List file = await pickImage(ImageSource.camera);
                    setState(() {
                      _notChanged = false;
                      _bordoreau = file;
                    });
                  },
                  child: _bordoreau == null
                      ? Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              "assets/img/blank.jpg",
                              fit: BoxFit.fill,
                              height: size.height * 0.2,
                              width: double.infinity,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              height: size.height * 0.2,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(
                                    _bordoreau!,
                                  ),
                                  fit: BoxFit.fill,
                                  alignment: FractionalOffset.topCenter,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                Visibility(
                  visible: provider.isAck,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: "Accusé de réception",
                        color: Theme.of(context).colorScheme.secondary,
                        textsize: 18,
                        isTitle: true,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () async {
                          Uint8List file = await pickImage(ImageSource.camera);
                          setState(() {
                            _notChanged = false;
                            _ackReceipt = file;
                          });
                        },
                        child: _ackReceipt == null
                            ? Container(
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    )),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.asset(
                                    "assets/img/blank.jpg",
                                    fit: BoxFit.fill,
                                    height: size.height * 0.2,
                                    width: double.infinity,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    height: size.height * 0.2,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: MemoryImage(
                                          _ackReceipt!,
                                        ),
                                        fit: BoxFit.fill,
                                        alignment: FractionalOffset.topCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
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
                            onTap: () async {
                              isOnEdit
                                  ? _updateForm(_isWithAck)
                                  : _submitForm(_isWithAck);
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
      ),
    );
  }
}

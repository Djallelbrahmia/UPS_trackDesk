import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:ups_trackdesk/provider/data_provider.dart';
import 'package:ups_trackdesk/utils/global_methodes.dart';
import 'package:ups_trackdesk/utils/utils.dart';
import 'package:ups_trackdesk/views/form_step1.dart';
import 'package:ups_trackdesk/views/home_page.dart';
import 'package:ups_trackdesk/views/text_widget.dart';
import 'package:uuid/uuid.dart';

import '../../provider/form_model.dart';
import '../../services/local_storage/crud_local_services.dart';
import '../../utils/firebase_consts.dart';

class HistoryWidget extends StatefulWidget {
  const HistoryWidget({super.key, required this.date});
  final String date;

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  late final LabelService service;
  @override
  void initState() {
    service = LabelService();
    super.initState();
  }

  void _submitForm(
    bool isWithAck,
    Uint8List _bordoreau,
    Uint8List? _ackReceipt,
  ) async {
    final provider = Provider.of<FormModel>(context, listen: false);
    final currentlabel =
        await service.getBordereau(bareCode: provider.bareCode);

    final bool isValid = !currentlabel.isSync;
    if (isValid) {
      try {
        final String uid = const Uuid().v4();
        final userId = authInstance.currentUser!.uid;
        if (isWithAck) {
          final bref = FirebaseStorage.instance
              .ref()
              .child('images/bordoreau')
              .child('$uid.jpg');
          await bref.putData(_bordoreau).timeout(const Duration(seconds: 10));
          final String bordoreauUrl = await bref.getDownloadURL();
          final ackref = FirebaseStorage.instance
              .ref()
              .child('images/ack')
              .child('$uid.jpg');
          await ackref
              .putData(_ackReceipt!)
              .timeout(const Duration(seconds: 10));
          final String ackUrl = await ackref.getDownloadURL();
          await FirebaseFirestore.instance
              .collection("handForm")
              .doc(provider.bareCode)
              .set({
            'userId': userId,
            'NameExp': provider.nameExp,
            'adressExp': provider.adressExp,
            'villeexp': provider.villeexp,
            'zipExp': provider.zipExp,
            'nameDest': provider.nameDest,
            'adressDest': provider.adressDest,
            'villeDest': provider.villeDest,
            'zipDest': provider.zipDest,
            'typeDeLivraison': provider.typeDeLivraison,
            'typeDePayment': provider.typeDePayment,
            'packageWeight': provider.packageWeight,
            'numbreOfItems': provider.numbreOfItems,
            'bordoreauUrl': bordoreauUrl,
            'ackOfReceipt': ackUrl,
            'addedDate': widget.date,
            'Created': DateTime.now(),
            'bareCode': provider.bareCode,
          });
        } else {
          final bref = FirebaseStorage.instance
              .ref()
              .child('images/bordoreau')
              .child('$uid.jpg');
          await bref.putData(_bordoreau).timeout(const Duration(seconds: 10));
          final String bordoreauUrl = await bref.getDownloadURL();
          await FirebaseFirestore.instance
              .collection("handForm")
              .doc(provider.bareCode)
              .set({
            'userId': userId,
            'NameExp': provider.nameExp,
            'adressExp': provider.adressExp,
            'villeexp': provider.villeexp,
            'zipExp': provider.zipExp,
            'nameDest': provider.nameDest,
            'adressDest': provider.adressDest,
            'villeDest': provider.villeDest,
            'zipDest': provider.zipDest,
            'typeDeLivraison': provider.typeDeLivraison,
            'typeDePayment': provider.typeDePayment,
            'packageWeight': provider.packageWeight,
            'numbreOfItems': provider.numbreOfItems,
            'bordoreauUrl': bordoreauUrl,
            'ackOfReceipt': '',
            'addedDate': widget.date,
            'Created': DateTime.now(),
            'bareCode': provider.bareCode,
          });
        }
        service.updateBordereau(
            bordereau: currentlabel,
            userId: userId,
            nameExp: provider.nameExp,
            adressExp: provider.adressExp,
            villeexp: provider.villeexp,
            zipExp: provider.zipExp,
            nameDest: provider.nameDest,
            adressDest: provider.adressDest,
            villeDest: provider.villeDest,
            zipDest: provider.zipDest,
            numbreOfitems: provider.numbreOfItems,
            packageWeight: provider.packageWeight,
            typeDeLivraison: provider.typeDeLivraison,
            typeDePayment: provider.typeDePayment,
            bordoreauUrl: provider.bordoreauUrl,
            ackReceipt: provider.ackReceipt,
            addedDate: widget.date,
            isSync: true);
        provider.set(true);
        Fluttertoast.showToast(
            msg: "Synchronisé !",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } catch (e) {
        if (mounted) {
          GlobalMethods.ErrorDialog(
              subtitle: "Résseyer plus tard", context: context);
        }
      }
    } else {
      if (mounted) {
        GlobalMethods.ErrorDialog(
            subtitle: "Le bordereau est déja synchronisé", context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FormModel>(context);
    final size = Utils(context).screenSize;
    final Uint8List _bordoreau = base64.decode(provider.bordoreauUrl);
    final Uint8List? _ackReceipt =
        provider.ackReceipt == '' ? null : base64.decode(provider.ackReceipt);

    return Material(
      elevation: 4,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: size.height * 0.18,
          width: size.width * 0.8,
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FancyShimmerImage(
                    imageUrl:
                        "https://cdn.dribbble.com/users/2646214/screenshots/5719099/ups_package_car-06_4x.png?resize=400x300&vertical=center",
                    height: double.infinity,
                    width: size.width * 0.3,
                    boxFit: BoxFit.fill,
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.4,
                          child: Text(
                            provider.nameExp,
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            _submitForm(_ackReceipt == null ? false : true,
                                _bordoreau, _ackReceipt);
                          },
                          child: Material(
                            borderRadius: BorderRadius.circular(8),
                            color: provider.isSynced
                                ? Colors.green.withOpacity(0.4)
                                : Colors.green,
                            child: const SizedBox(
                              width: 80,
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      IconlyBold.upload,
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
                    SizedBox(
                      width: size.width * 0.4,
                      child: Text(
                        widget.date,
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    SizedBox(
                      width: size.width * 0.4,
                      child: Text(
                        provider.nameDest,
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return Consumer<DataProvider>(
                                      builder: (context, daTaprovider, child) {
                                    daTaprovider.addForEdit(provider);
                                    return const FirstStep(isHome: false);
                                  });
                                },
                              ),
                            );
                          },
                          child: Material(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.primary,
                            child: const SizedBox(
                              width: 80,
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      IconlyBold.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(4),
                                    child: TextWidget(
                                        text: "Edit",
                                        color: Colors.white,
                                        textsize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 70,
                        ),
                        InkWell(
                          onTap: () async {
                            GlobalMethods.WarningDialog(
                                title: "Vous étes sur?",
                                subtitle: "votre action est irréversible",
                                fct: () {
                                  service.deleteBordereau(
                                      barecode: provider.bareCode);
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      MyHomePage.routeName, (route) => false);
                                },
                                context: context);
                          },
                          child: Material(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red,
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      IconlyBold.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
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

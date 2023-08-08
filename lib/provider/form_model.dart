import 'package:flutter/material.dart';

class FormModel with ChangeNotifier {
  final String id,
      nameExp,
      adressExp,
      villeexp,
      zipExp,
      nameDest,
      adressDest,
      villeDest,
      zipDest,
      typeDeLivraison,
      typeDePayment,
      packageWeight,
      numbreOfItems,
      bareCode,
      bordoreauUrl,
      ackReceipt;
  bool isSynced;
  void set(bool isitSynced) {
    isSynced = isitSynced;
    notifyListeners();
  }

  FormModel(
      {required this.packageWeight,
      required this.numbreOfItems,
      required this.id,
      required this.nameExp,
      required this.adressExp,
      required this.villeexp,
      required this.zipExp,
      required this.nameDest,
      required this.adressDest,
      required this.villeDest,
      required this.zipDest,
      required this.typeDeLivraison,
      required this.typeDePayment,
      required this.bareCode,
      required this.bordoreauUrl,
      required this.ackReceipt,
      required this.isSynced});
}

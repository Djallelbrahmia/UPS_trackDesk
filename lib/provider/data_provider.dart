import 'package:flutter/material.dart';
import 'package:ups_trackdesk/provider/form_model.dart';

class DataProvider with ChangeNotifier {
  Map<String, FormModel> _formData = {};
  Map<String, String> _firstStepData = {};
  Map<String, String> _secondStepData = {};
  Map<String, String> _thirdStepData = {};
  String _bareCode = '';
  bool _isSynced = false;
  Map<String, String> _lastStepData = {};
  Map<String, FormModel> get getFormData {
    return _formData;
  }

  get getterIhaveSet {
    return [_secondStepData, _firstStepData, _thirdStepData];
  }

  bool get isAck {
    return _thirdStepData['typeDeLivraison'] == 'Accusé de réception';
  }

  void addForEdit(FormModel model) {
    _formData.putIfAbsent("edit", () => model);
  }

  void emptyEdit() {
    _formData.removeWhere((key, value) => key == 'edit');
  }

  void addItem(String id) {
    print(_secondStepData);
    _formData.putIfAbsent(
        id,
        () => FormModel(
            packageWeight: _thirdStepData['packageWeight']!,
            numbreOfItems: _thirdStepData['numbreOfItems']!,
            id: id,
            nameExp: _firstStepData['nameExp']!,
            adressExp: _firstStepData['adressExp']!,
            villeexp: _firstStepData['villeexp']!,
            zipExp: _firstStepData['zipExp']!,
            nameDest: _secondStepData['nameDest']!,
            adressDest: _secondStepData['adressDest']!,
            villeDest: _secondStepData['villeDest']!,
            zipDest: _secondStepData['zipDest']!,
            typeDeLivraison: _thirdStepData['typeDeLivraison']!,
            typeDePayment: _thirdStepData['typeDePayment']!,
            bareCode: _bareCode,
            bordoreauUrl: _lastStepData['bordoreauUrl']!,
            ackReceipt: _lastStepData['ackOfReceipt']!,
            isSynced: _isSynced));
  }

  void collectFirstStepData({
    required String nameExp,
    required String adressExp,
    required String villeexp,
    required String zipExp,
  }) {
    print(zipExp);
    _firstStepData = {
      'nameExp': nameExp,
      'adressExp': adressExp,
      'villeexp': villeexp,
      'zipExp': zipExp,
    };
    notifyListeners();
  }

  void collectSecondStepData({
    required String nameDest,
    required String adressDest,
    required String villeDest,
    required String zipDest,
  }) {
    _secondStepData = {
      'nameDest': nameDest,
      'adressDest': adressDest,
      'villeDest': villeDest,
      'zipDest': zipDest,
    };

    notifyListeners();
  }

  void collectThirdStepData(
      {required String typeDeLivraison,
      required String typeDePayment,
      required String packageWeight,
      required String numbreOfItems}) {
    _thirdStepData = {
      'typeDeLivraison': typeDeLivraison,
      'typeDePayment': typeDePayment,
      'packageWeight': packageWeight,
      'numbreOfItems': numbreOfItems,
    };

    notifyListeners();
  }

  set setBareCode(String bareCode) {
    _bareCode = bareCode;
    notifyListeners();
  }

  void collectLastStepData(
    String bordoreauUrl,
    String ackOfReceipt,
  ) {
    _lastStepData = {
      'bordoreauUrl': bordoreauUrl,
      'ackOfReceipt': ackOfReceipt,
    };
    notifyListeners();
  }
}

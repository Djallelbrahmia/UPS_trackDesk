import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:ups_trackdesk/views/code_barre.dart';
import 'package:ups_trackdesk/views/navbar.dart';
import 'package:ups_trackdesk/views/text_widget.dart';

import '../provider/data_provider.dart';
import '../utils/utils.dart';

class ThirdStep extends StatefulWidget {
  const ThirdStep({super.key});
  static const routeName = "/ThirdStep";
  @override
  State<ThirdStep> createState() => _ThirdStepState();
}

class _ThirdStepState extends State<ThirdStep> {
  late final TextEditingController _nombreDeColisController;
  late final TextEditingController _poidsDesColisController;
  final _formKey = GlobalKey<FormState>();
  final _poidsDesColisFocusNode = FocusNode();

  @override
  void initState() {
    _nombreDeColisController = TextEditingController();
    _poidsDesColisController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _nombreDeColisController.dispose();
    _poidsDesColisController.dispose();
    _poidsDesColisFocusNode.dispose();

    super.dispose();
  }

  bool isNumeric(String? str) {
    if (str == null || str.isEmpty) {
      return false;
    }

    return double.tryParse(str) != null;
  }

  void _submitForm(BuildContext context) {
    final isValid = _formKey.currentState!.validate();
    final provider = Provider.of<DataProvider>(context, listen: false);

    FocusScope.of(context).unfocus();

    if (isValid) {
      provider.collectThirdStepData(
        numbreOfItems: _nombreDeColisController.text,
        packageWeight: _poidsDesColisController.text,
        typeDeLivraison: _typeDeLivraisonHolder,
        typeDePayment: _typeDePaymentHolder,
      );
      Navigator.of(context).pushNamed(Barcode.routeName);
    }
  }

  String _typeDeLivraisonHolder = 'Doc';
  String _typeDePaymentHolder = 'E/C';
  String _typeDeLivraisonDefault = 'Doc';
  String _typeDePaymentDefault = 'E/C';
  bool _notChanged = true;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    if (provider.getFormData['edit'] != null) {
      if (_notChanged) {
        setState(() {
          _typeDeLivraisonDefault =
              provider.getFormData['edit']!.typeDeLivraison;
          _typeDePaymentDefault = provider.getFormData['edit']!.typeDePayment;

          _nombreDeColisController.text =
              provider.getFormData['edit']!.numbreOfItems;
          _poidsDesColisController.text =
              provider.getFormData['edit']!.packageWeight;
        });
      }
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
                      text: "Etape  3 - Colis ",
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
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
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
              const SizedBox(
                height: 36,
              ),
              Row(
                children: [
                  TextWidget(
                    text: "Type de livraison",
                    color: Theme.of(context).colorScheme.secondary,
                    textsize: 16,
                    isTitle: true,
                  ),
                  const Spacer(),
                  _dropDown(
                      defaultValue: _typeDeLivraisonDefault,
                      values: ['Doc', 'Non Doc', 'Accusé de réception'],
                      hinttext: 'type de livraison',
                      onChanged: (value) {
                        setState(() {
                          _typeDeLivraisonDefault = value;
                          _typeDeLivraisonHolder = value;
                        });
                      }),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  TextWidget(
                    text: "Type de Payment",
                    color: Theme.of(context).colorScheme.secondary,
                    textsize: 16,
                    isTitle: true,
                  ),
                  const Spacer(),
                  _dropDown(
                      defaultValue: _typeDePaymentDefault,
                      values: ['E/C', 'F/C', 'P/P', 'N/R'],
                      hinttext: 'type de Payment',
                      onChanged: (value) {
                        setState(() {
                          _typeDePaymentDefault = value;

                          _typeDePaymentHolder = value;
                        });
                      }),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nombre de Colis",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _notChanged = false;
                          });
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context)
                              .requestFocus(_poidsDesColisFocusNode);
                        },
                        controller: _nombreDeColisController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return " Entrer le Nombre de colis s'il vous plait ";
                          }
                          if (!isNumeric(value)) {
                            return "Entrer un nombre valide !";
                          } else {
                            return null;
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ), //password
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Poids des colis",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            _notChanged = false;
                          });
                        },
                        onEditingComplete: () {
                          _submitForm(context);
                        },
                        controller: _poidsDesColisController,
                        focusNode: _poidsDesColisFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return " Entrer le poids s'il vous plait ";
                          }
                          if (!isNumeric(value)) {
                            return "Entrer un nombre valide !";
                          } else {
                            return null;
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.7)),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ), //password
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  )),
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
                            _submitForm(context);
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

  Widget _dropDown(
      {required List<String> values,
      required String hinttext,
      required Function(String) onChanged,
      required String defaultValue}) {
    List<DropdownMenuItem<String>> items = [];
    for (int i = 0; i < values.length; i++) {
      items.add(DropdownMenuItem(
        value: values[i],
        child: Text(values[i]),
      ));
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 16),
          value: defaultValue,
          onChanged: (value) {
            onChanged(value!); //
          },
          hint: Text(hinttext),
          items: items),
    );
  }
}

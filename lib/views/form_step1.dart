import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:ups_trackdesk/provider/data_provider.dart';
import 'package:ups_trackdesk/services/local_storage/client_db.dart';
import 'package:ups_trackdesk/views/navbar.dart';
import 'package:ups_trackdesk/views/text_widget.dart';

import '../utils/const.dart';
import '../utils/utils.dart';
import 'form_step2.dart';

class FirstStep extends StatefulWidget {
  const FirstStep({super.key, required this.isHome});
  static const routeName = "/FirstStep";
  final bool isHome;
  @override
  State<FirstStep> createState() => _FirstStepState();
}

class _FirstStepState extends State<FirstStep> {
  late final TextEditingController _namecontroller;
  late final TextEditingController _adresseController;
  late final TextEditingController _villecontroller;
  late final TextEditingController _zipcontroller;
  final _formKey = GlobalKey<FormState>();
  final _adressFocusNode = FocusNode();
  final _villeFocusNode = FocusNode();
  final _zipFocusNode = FocusNode();
  TypeOfClient? _type = TypeOfClient.particulier;
  late final ClientDbService _clientService;
  @override
  void initState() {
    _namecontroller = TextEditingController();
    _adresseController = TextEditingController();
    _villecontroller = TextEditingController();
    _zipcontroller = TextEditingController();
    _clientService = ClientDbService();

    super.initState();
  }

  @override
  void dispose() {
    _namecontroller.dispose();
    _adresseController.dispose();
    _villecontroller.dispose();
    _zipcontroller.dispose();
    _adressFocusNode.dispose();
    _villeFocusNode.dispose();
    _zipFocusNode.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    final isValid = _formKey.currentState!.validate();
    final provider = Provider.of<DataProvider>(context, listen: false);

    FocusScope.of(context).unfocus();

    if (isValid) {
      provider.collectFirstStepData(
          nameExp: _namecontroller.text,
          adressExp: _adresseController.text,
          villeexp: _villecontroller.text,
          zipExp: _zipcontroller.text);
      Navigator.of(context).pushNamed(SecondStep.routeName);
    }
  }

  bool _notChanged = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);
    if (widget.isHome) {
      provider.emptyEdit();
    }
    if (_notChanged) {
      if (provider.getFormData['edit'] != null) {
        setState(() {
          _namecontroller.text = provider.getFormData['edit']!.nameExp;
          _adresseController.text = provider.getFormData['edit']!.adressExp;
          _villecontroller.text = provider.getFormData['edit']!.villeexp;
          _zipcontroller.text = provider.getFormData['edit']!.zipExp;
        });
      }
    }
    bool _chosedFromClient = false;
    return WillPopScope(
      onWillPop: () async {
        provider.emptyEdit();
        return true;
      },
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
                        text: "Etape  1 - Expéditeur ",
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
                                .withOpacity(0.2)),
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
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  height: 0.5,
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  children: [
                    const Text('Particulier'),
                    Radio<TypeOfClient>(
                      value: TypeOfClient.particulier,
                      groupValue: _type,
                      onChanged: (TypeOfClient? value) {
                        setState(() {
                          _type = value;
                        });
                      },
                    ),
                    const Spacer(),
                    const Text('Client UPS'),
                    Radio<TypeOfClient>(
                      value: TypeOfClient.client,
                      groupValue: _type,
                      onChanged: (TypeOfClient? value) {
                        setState(() {
                          _type = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 36,
                ),
                Visibility(
                    visible: _type == TypeOfClient.client,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      child: TypeAheadField(
                        suggestionsCallback: _clientService.getSuggestion,
                        itemBuilder: (context, ClientDb? client) {
                          final suggested = client!;
                          return ListTile(
                            title: Text(suggested.name),
                          );
                        },
                        onSuggestionSelected: (ClientDb? client) {
                          setState(() {
                            _notChanged = false;
                            _namecontroller.text = client!.name;
                            _adresseController.text = client!.adress;
                            _villecontroller.text = client!.ville;
                            _zipcontroller.text = client!.zip;
                          });
                        },
                      ),
                    )),
                const SizedBox(
                  height: 16,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nom de l’expéditeur",
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
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context)
                                .requestFocus(_adressFocusNode);
                          },
                          controller: _namecontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return " Entrer le Nom  s'il vous plait ";
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
                          "Adresse de  l’expéditeur",
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
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context)
                                .requestFocus(_villeFocusNode);
                          },
                          controller: _adresseController,
                          focusNode: _adressFocusNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return " Entrer l'adresse s'il vous plait ";
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
                          "Ville",
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
                          focusNode: _villeFocusNode,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_zipFocusNode);
                          },
                          controller: _villecontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return " Entrer la ville s'il vous plait ";
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
                          "Code Postal",
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
                          focusNode: _zipFocusNode,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            _submitForm(context);
                          },
                          controller: _zipcontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return " Entrer le code postal s'il vous plait ";
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
      ),
    );
  }
}

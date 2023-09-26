import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:ups_trackdesk/provider/form_model.dart';
import 'package:ups_trackdesk/services/local_storage/crud_local_services.dart';
import 'package:ups_trackdesk/utils/utils.dart';
import 'package:ups_trackdesk/views/text_widget.dart';
import 'package:ups_trackdesk/views/widget/history_widget.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});
  static const routeName = "/History";

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late final LabelService service;
  @override
  void initState() {
    service = LabelService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(IconlyLight.arrow_left)),
        ),
        body: FutureBuilder(
            future: service.getAllBordereau(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData && snapshot.data!.toList().isNotEmpty) {
                    final data = snapshot.data!.toList();
                    return GridView.count(
                        crossAxisCount: 1,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        childAspectRatio: Utils(context).screenSize.width /
                            (Utils(context).screenSize.height * 0.2),
                        children: List.generate(snapshot.data!.length, (index) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 2),
                              child: SizedBox(
                                child: ChangeNotifierProvider.value(
                                    value: FormModel(
                                        adressDest: data[index].adressDest,
                                        adressExp: data[index].adressExp,
                                        bareCode: data[index].bareCode,
                                        id: data[index].id.toString(),
                                        nameDest: data[index].nameDest,
                                        nameExp: data[index].nameExp,
                                        numbreOfItems:
                                            data[index].numbreOfitems,
                                        packageWeight:
                                            data[index].packageWeight,
                                        typeDeLivraison:
                                            data[index].typeDeLivraison,
                                        typeDePayment:
                                            data[index].typeDePayment,
                                        villeDest: data[index].villeDest,
                                        villeexp: data[index].villeexp,
                                        zipDest: data[index].zipDest,
                                        zipExp: data[index].zipExp,
                                        bordoreauUrl: data[index].bordoreauUrl,
                                        ackReceipt: data[index].ackReceipt,
                                        isSynced: data[index].isSync),
                                    child: HistoryWidget(
                                      date: data[index].addedDate,
                                    )),
                              ));
                        }));
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextWidget(
                            text: "Vous n'avez pas ajouter un Bordereau..",
                            color: Theme.of(context).colorScheme.secondary,
                            textsize: 18,
                            isTitle: false,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
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
            }));
  }
}

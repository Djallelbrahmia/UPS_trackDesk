import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:ups_trackdesk/services/local_storage/crud_local_services.dart';
import 'package:ups_trackdesk/utils/firebase_consts.dart';
import 'package:ups_trackdesk/views/histroy.dart';
import 'package:ups_trackdesk/views/text_widget.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late final LabelService service;

  @override
  void initState() {
    service = LabelService();
    getUserName();
    super.initState();
  }

  Future<void> getUserName() async {
    final user = await service.getUser(userId: authInstance.currentUser!.uid);

    setState(() {
      userName = user.userName;
    });
  }

  String userName = "";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 16,
          ),
          Material(
            borderRadius: BorderRadius.circular(8),
            elevation: 1,
            shadowColor: Theme.of(context).shadowColor,
            child: ListTile(
                leading: TextWidget(
                    text: userName,
                    color: Theme.of(context).colorScheme.secondary,
                    textsize: 20),
                trailing: const Icon(IconlyBold.user_2)),
          ),
          const SizedBox(
            height: 4,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(HistoryView.routeName);
            },
            child: Material(
              borderRadius: BorderRadius.circular(8),
              elevation: 1,
              shadowColor: Theme.of(context).shadowColor,
              child: ListTile(
                leading: TextWidget(
                    text: "Voir l'historique",
                    color: Theme.of(context).colorScheme.secondary,
                    textsize: 18),
                trailing: const Icon(IconlyBold.calendar),
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
        ],
      ),
    );
  }
}

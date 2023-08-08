import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:ups_trackdesk/views/histroy.dart';
import 'package:ups_trackdesk/views/text_widget.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

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
                  text: 'Mouhamed',
                  color: Theme.of(context).colorScheme.secondary,
                  textsize: 20),
              trailing: const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fHww&w=1000&q=80'),
              ),
            ),
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
          Material(
            borderRadius: BorderRadius.circular(8),
            elevation: 1,
            shadowColor: Theme.of(context).shadowColor,
            child: ListTile(
              leading: TextWidget(
                  text: "Comment il Marche?",
                  color: Theme.of(context).colorScheme.secondary,
                  textsize: 18),
              trailing: const Icon(IconlyBold.info_circle),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../enums/menu_action.dart';
import '../services/auth/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Main UI'),
          actions: [
            PopupMenuButton(onSelected: (value) async {
              switch (value){
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if(shouldLogout){
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                  break;
              }
            }, itemBuilder: (context) {
              return const[
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            })
          ],
        ),
        body: const Text('Hello World')
    );
  }
}
Future<bool>showLogoutDialog(BuildContext context){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to Sign out'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        }, child: const Text('Cancel')),
        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: const Text('Logout'))
      ],
    );
  }
  ).then((value) => value ?? false);
}

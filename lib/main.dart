import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:omegalogin/views/login_view.dart';
import 'package:omegalogin/views/register_view.dart';
import 'package:omegalogin/views/verify_email_view.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ),
  );
}
 
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
              } else {
              return const LoginView();
            }
            default:
              return const CircularProgressIndicator();
      }
      },
    );
  }
}

enum MenuAction {logout}

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
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login/', (route) => false);
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

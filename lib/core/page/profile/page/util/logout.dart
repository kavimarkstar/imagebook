import 'package:flutter/material.dart';
import 'package:imagebook/core/auth/pages/wrapper.dart';
import 'package:imagebook/core/auth/services/auth_service.dart';

@override
Widget logoutbuild(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.logout_outlined, size: 30, color: Colors.red),
    title: Text("Logout", style: TextStyle(fontSize: 20)),
    trailing: Icon(Icons.arrow_forward_ios_outlined, size: 20),
    onTap: () {
      _signOut(context);
    },
  );
}

//sign out
void _signOut(BuildContext context) {
  AuthService().signOut();
  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (context) => const Wrapper()));
}

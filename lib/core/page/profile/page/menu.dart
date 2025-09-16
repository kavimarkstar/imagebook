import 'package:flutter/material.dart';
import 'package:imagebook/core/page/profile/page/util/logout.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SafeArea(child: Column(children: [
          logoutbuild(context)
        ])),
      ),
    );
  }
}

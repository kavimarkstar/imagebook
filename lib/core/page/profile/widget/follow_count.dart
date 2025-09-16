import 'package:flutter/material.dart';

@override
Widget countDatabuild(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(32),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        countbuild(context,  "Following","1,631",),
        countbuild(context,"Followers","74",),
        countbuild(context,"Likes","100",),
      ],
    ),
  );
}

Widget countbuild(BuildContext context, String title, String count) {
  return Column(
    children: [
      Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(title),
    ],
  );
}

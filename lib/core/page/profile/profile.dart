import 'dart:convert'; // for base64 decoding
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:imagebook/core/auth/services/auth_service.dart';
import 'package:imagebook/core/page/profile/page/menu.dart';
import 'package:imagebook/core/page/profile/widget/follow_count.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String userId = AuthService().getCurrentUser()?.uid ?? 'Unknown';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuPage()),
              );
            },
            icon: Icon(Icons.menu),
          ),
        ],
      ),
      body: userId == 'Unknown'
          ? Center(child: Text("No user logged in"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text("User data not found"));
                }

                var userData = snapshot.data!.data() as Map<String, dynamic>;

                // ✅ Decode base64 profile photo
                Uint8List? profileImage;
                if (userData["profilePhoto"] != null &&
                    userData["profilePhoto"].toString().isNotEmpty) {
                  try {
                    profileImage = base64Decode(userData["profilePhoto"]);
                  } catch (e) {
                    print("Error decoding image: $e");
                  }
                }

                return SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: profileImage != null
                                    ? MemoryImage(profileImage)
                                    : null,
                                child: profileImage == null
                                    ? Icon(Icons.person, size: 60)
                                    : null,
                              ),
                              SizedBox(height: 15),
                              Text(
                                "${userData["firstName"] ?? "Unknown"} ${userData["lastName"] ?? ""}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "@${userData["username"] ?? "username"}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              countDatabuild(context),
                              SizedBox(height: 10),
                              Text(userData["bio"] ?? "No bio available"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

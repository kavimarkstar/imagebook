import 'package:flutter/material.dart';
import 'package:imagebook/core/auth/pages/util/profiles_data_fill.dart';
import 'package:imagebook/core/auth/pages/wrapper.dart';
import 'package:imagebook/core/auth/services/auth_service.dart';
import 'package:imagebook/core/page/com/com.dart';
import 'package:imagebook/core/page/home/home_page.dart' show HomePage;
import 'package:imagebook/core/page/profile/profile.dart';
import 'package:imagebook/core/widget/post.dart';
import 'package:imagebook/responsive/responsive.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  // Using the unified responsive utilities

  Widget buildIcon(int index, bool isSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Defensive: If index is out of range, use a fallback icon
    if (index < 0 || index >= assetIcons.length) {
      return Icon(Icons.error, color: isDarkMode ? Colors.white : Colors.black);
    }
    String iconPath = isSelected
        ? assetIcons[index]['selected']!
        : assetIcons[index]['default']!;
    bool isNetwork = iconPath.startsWith('http');
    if (iconPath == defaultAvatarPath) {
      // Always show the default avatar as a circle
      return ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Image.asset(defaultAvatarPath, width: 25, height: 25),
      );
    }
    return isNetwork
        ? ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: Image.network(
              iconPath,
              width: 25,
              height: 25,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(defaultAvatarPath, width: 25, height: 25),
            ),
          )
        : Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: isDarkMode ? Colors.white : Colors.black,
          );
  }

  String get defaultAvatarPath => 'assets/icons/user_avatar.png';

  List<Map<String, String>> get assetIcons => [
    {
      'default': 'assets/icons/home_outline.png',
      'selected': 'assets/icons/home.png',
    },
    {
      'default': 'assets/icons/com_outline.png',
      'selected': 'assets/icons/com.png',
    },
    {
      'default': 'assets/icons/notification_outline.png',
      'selected': 'assets/icons/notification.png',
    },
    {
      'default': "assets/icons/profile_outline.png",
      'selected': "assets/icons/profile.png",
    },
  ]; 

  final List<Widget> pages = [
    const ProfilesDataFillPage(),
    ComPage(),
    const Center(child: Text('Notifications Page')),
    const ProfilePage()
  ];

  final List<String> titles = ['Home', 'Search', 'Notifications', 'Profile'];

  void onSelectPage(int index) {
    if (index >= 0 && index < pages.length) {
      setState(() => selectedIndex = index);
    }
  }

  Widget buildSidebar(BuildContext context) {
    final bool showText = isDesktop(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: isTablet(context) ? 100 : 250,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: titles.length,
              itemBuilder: (context, index) {
                final bool isSelected = selectedIndex == index;

                final backgroundColor = isSelected
                    // ignore: deprecated_member_use
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.transparent;

                final textColor = isSelected
                    ? isDarkMode
                          ? Colors.white
                          : isDarkMode
                          ? Colors.white
                          : Colors.black
                    : isDarkMode
                    ? Colors.white
                    : Colors.black;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 1,
                    horizontal: 10,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 17,
                        horizontal: 15,
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(150),
                      ),
                    ),
                    onPressed: () => onSelectPage(index),
                    child: Row(
                      mainAxisAlignment: showText
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        buildIcon(index, isSelected),
                        if (showText) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              titles[index],
                              style: TextStyle(
                                color: textColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //sign out
  void _signOut(BuildContext context) {
    AuthService().signOut();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => const Wrapper()));
  }

  @override
  Widget build(BuildContext context) {
    final bool smallScreen = isMobile(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: !smallScreen
          ? AppBar(
              title: Text(
                "ImageBook",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'LemonJelly',
                  fontSize: 35,
                  fontWeight: FontWeight.w300,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () => showCustomPopup(context),
                  icon: Icon(Icons.add_circle_outline_rounded),
                ),
                SizedBox(width: 10),
                PopupMenuButton<int>(
                  icon: Icon(Icons.settings),
                  menuPadding: EdgeInsets.all(0),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      enabled: false,
                      padding: EdgeInsets.all(0),
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // You can add more PopupMenuItem<Card> here
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _signOut(context);
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: smallScreen
            ? pages[selectedIndex]
            : Row(
                children: [
                  buildSidebar(context),
                  Expanded(child: pages[selectedIndex]),
                ],
              ),
      ),
      bottomNavigationBar: smallScreen
          ? BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex < pages.length ? selectedIndex : 0,
              onTap: (index) {
                if (index >= 0 && index < pages.length) {
                  onSelectPage(index);
                }
              },
              items: List.generate(pages.length, (index) {
                final isSelected = selectedIndex == index;
                return BottomNavigationBarItem(
                  icon: buildIcon(index, isSelected),
                  label: titles[index],
                );
              }),
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
            )
          : null,
    );
  }
}

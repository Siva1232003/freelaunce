import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'upload.dart'; // Import the Upload page
import 'auth_page.dart'; // Add this import
import 'account_page.dart';




class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  User? user; // Firebase user

  @override
  void initState() {
    super.initState();
    _initializeUser();
    // Set up a timer to automatically move to the next page every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 3) {
        _currentPage++;
      } else {
        _currentPage = 0; // Reset to the first page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    });
  }

  Future<void> _initializeUser() async {
    // Get the currently signed-in user
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      user = FirebaseAuth.instance.currentUser;
      setState(() {});
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    user = null;
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Rich Printers',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Notification'),
                    content: Text('This is a dummy message.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu, color: Color(0xFFCFF008)),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                children: [
                  buildCarouselSlide('Slide 1'),
                  buildCarouselSlide('Slide 2'),
                  buildCarouselSlide('Slide 3'),
                  buildCarouselSlide('Slide 4'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery at door step',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Delivered within 3 days',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFCFF008),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/color.png',
                    height: 200,
                    width: 200,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Upload(selectedColor: 'Color'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCFF008),
                  ),
                  child: Text('Click here for Color print'),
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFCFF008),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/bw.png',
                    height: 200,
                    width: 200,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Upload(selectedColor: 'Black and white'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCFF008),
                  ),
                  child: Text('Click here for B/W print'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
  decoration: BoxDecoration(
    color: Colors.grey[850],
  ),
  child: SingleChildScrollView( // Wrap this with SingleChildScrollView
    child: user != null
        ? Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user!.photoURL ?? ''),
              ),
              SizedBox(height: 10),
              Text(
                user!.displayName ?? 'User',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                user!.email ?? '',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Not signed in',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              TextButton(
                onPressed: _signInWithGoogle,
                child: Text('Sign in with Google'),
              ),
            ],
          ),
  ),
),

            
            
            _buildDrawerItem(Icons.account_circle, 'Account', onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AccountPage()),
  );
}),

            _buildDrawerItem(Icons.list, 'Orders'),
            _buildDrawerItem(Icons.history, 'History'),
            _buildDrawerItem(Icons.info, 'About Us'),
            _buildDrawerItem(Icons.settings, 'Settings'),
            _buildDrawerItem(Icons.logout, 'Logout', onTap: () async {
  await _signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SignInSignUpPage()),
  );
}),

          ],
        ),
      ),
    );
  }

  Widget buildCarouselSlide(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap ?? () {
        Navigator.pop(context);
      },
    );
  }
}

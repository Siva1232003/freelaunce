import 'package:flutter/material.dart';
import 'upload.dart'; // Import the Upload page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Automatically change the carousel every 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (_currentPage < 3) {
        _pageController.animateToPage(
          _currentPage + 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.linear,
        );
      }
      setState(() {
        _currentPage = (_currentPage + 1) % 4; // Loop through pages
      });
    });
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
              // Show a dummy message when notification is clicked
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
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer
          },
        ),
      ),
      body: SingleChildScrollView(
        // Make the content scrollable
        child: Column(
          children: [
            // Carousel Section
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
            // Text Section
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
            // Buttons Section with Images
            Column(
              children: [
                // Container with a border for the first image
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFCFF008), // Border color
                      width: 4, // Border width
                    ),
                    borderRadius: BorderRadius.circular(
                        8), // Optional: for rounded corners
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
                    // Navigate to the Upload page for Color print
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Upload(selectedColor: 'Color'), // Pass color
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCFF008), // Button color
                  ),
                  child: Text('Click here for Color print'),
                ),
                SizedBox(height: 30),
                // Container with a border for the second image
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFCFF008), // Border color
                      width: 4, // Border width
                    ),
                    borderRadius: BorderRadius.circular(
                        8), // Optional: for rounded corners
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
                    // Navigate to the Upload page for B/W print
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Upload(selectedColor: 'Black and white'), // Pass B/W
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCFF008), // Button color
                  ),
                  child: Text('Click here for B/W print'),
                ),
                SizedBox(height: 20), // Add this SizedBox below the B/W print button
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
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(Icons.settings, 'Settings'),
            _buildDrawerItem(Icons.account_circle, 'Account'),
            _buildDrawerItem(Icons.list, 'Orders'),
            _buildDrawerItem(Icons.history, 'History'),
            _buildDrawerItem(Icons.info, 'About Us'),
            _buildDrawerItem(Icons.logout, 'Logout'),
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

  // Helper method to create drawer items
  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        // Handle navigation for each item here
        Navigator.pop(context); // Close the drawer after selection
      },
    );
  }
}

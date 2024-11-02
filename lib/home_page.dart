import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Open the drawer
          },
        ),
      ),
      body: Column(
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
          Text(
            'Delivery at door step',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'Delivered within 3 days',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 20),
          // Buttons Section
          ElevatedButton(
            onPressed: () {
              // Add Color print action here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCFF008), // Button color
            ),
            child: Text('Click here for Color print'),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              // Add B/W print action here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCFF008), // Button color
            ),
            child: Text('Click here for B/W print'),
          ),
        ],
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

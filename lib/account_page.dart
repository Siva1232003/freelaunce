import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'location_service.dart';  // Import location_service.dart

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _doorNoController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();

  User? user;
  File? _imageFile; // For storing selected image
  final ImagePicker _picker = ImagePicker(); // For picking image from mobile
  bool _isEditable = false; // Flag to toggle edit mode for phone number and address

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    // Fetch and display saved user details if available
    if (user != null) {
      _phoneController.text = user!.phoneNumber ?? '';

      // Fetch additional data from Firestore
      _getUserDetails();
    }
  }

  // Function to fetch user details from Firestore
  Future<void> _getUserDetails() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(user?.uid).get();
      if (userDoc.exists) {
        setState(() {
          _doorNoController.text = userDoc['door_no'] ?? '';
          _streetController.text = userDoc['street'] ?? '';
          _areaController.text = userDoc['area'] ?? '';
          _cityController.text = userDoc['city'] ?? '';
          _stateController.text = userDoc['state'] ?? '';
          _pincodeController.text = userDoc['pincode'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  void dispose() {
    _doorNoController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Function to pick image from the gallery or camera
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // You can change this to camera if needed
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Set the image file after picking
      });
    }
  }

  // Function to validate and save data to Firebase
  Future<void> _saveData() async {
    // Validate if any fields are empty
    if (_doorNoController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      // Show a snackbar if any of the fields are empty
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Validate phone number (ensure it's a 10-digit number)
    String phoneNumber = _phoneController.text;
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid 10-digit phone number.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Collect data from fields
    final userData = {
      'door_no': _doorNoController.text,
      'street': _streetController.text,
      'area': _areaController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pincode': _pincodeController.text,
      'phone_number': phoneNumber,
      'photo_url': user?.photoURL,
    };

    // Reference to the Firebase Firestore
    final firestore = FirebaseFirestore.instance;

    try {
      // Save data to Firestore under the user's unique ID
      await firestore.collection('users').doc(user?.uid).set(userData, SetOptions(merge: true));

      // Log the saved information
      print("Information saved: $userData");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Your details have been saved successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (error) {
      // Show error message if saving fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save data: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Function to fetch and auto-fill state and district based on pincode
  void _autoFillLocation() async {
    String pincode = _pincodeController.text;
    if (pincode.isNotEmpty) {
      try {
        // Fetch location data based on pincode
        Map<String, String> locationData = await fetchLocationData(pincode);
        setState(() {
          _stateController.text = locationData['state'] ?? '';
          _cityController.text = locationData['city'] ?? '';
        });
      } catch (e) {
        print("Error fetching location data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black for the entire account page
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 11, 11),
        title: Text('Account',style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFCFF008)), // Custom back arrow color
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Edit Icon on the top-right corner for enabling editing mode
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xFFCFF008)),
            onPressed: () {
              setState(() {
                _isEditable = !_isEditable;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image picker section
              Align(
                alignment: Alignment.topCenter,
                child: CircleAvatar(
                  radius: 50, // Size of the profile image
                  backgroundColor: Colors.grey,
                  backgroundImage: _imageFile == null
                      ? NetworkImage(user?.photoURL ?? 'https://www.example.com/default-image.jpg') // Default image if no image selected
                      : FileImage(_imageFile!) as ImageProvider, // Display the selected image
                ),
              ),
              SizedBox(height: 20), // Space between profile image and form

              // Edit Image Button
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCFF008), // Edit button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text('Edit Image', style: TextStyle(color: Colors.black)),
                ),
              ),
              SizedBox(height: 20),

              // Editable or Non-editable user details
              user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Name and Last Name (Not editable)
                        Text('First Name', style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text(user?.displayName?.split(' ')[0] ?? 'N/A', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 10),

                        Text('Last Name', style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text(
                          (user?.displayName?.split(' ').length ?? 0) > 1
                              ? user?.displayName?.split(' ')[1] ?? 'N/A'
                              : 'N/A',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),

                        // Email (Not editable)
                        Text('Email', style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text(user?.email ?? 'N/A', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 20),

                        // Address form (editable)
                        Text('Door No.', style: TextStyle(color: Colors.white)),
                        TextField(
  controller: _doorNoController,
  enabled: _isEditable,
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    fillColor: Colors.grey[800],
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!, width: 1.0), // Default border color
    ),
  ),
),
                        SizedBox(height: 10),
                        Text('Street', style: TextStyle(color: Colors.white)),
                        TextField(
  controller: _streetController,
  enabled: _isEditable,
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    fillColor: Colors.grey[800],
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!, width: 1.0), // Default border color
    ),
  ),
),
                        SizedBox(height: 10),
                        Text('Area', style: TextStyle(color: Colors.white)),
                        TextField(
  controller: _areaController,
  enabled: _isEditable,
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    fillColor: Colors.grey[800],
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!, width: 1.0), // Default border color
    ),
  ),
),
                        SizedBox(height: 10),
                        Text('City', style: TextStyle(color: Colors.white)),
                        TextField(
  controller: _cityController,
  enabled: _isEditable,
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    fillColor: Colors.grey[800],
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!, width: 1.0), // Default border color
    ),
  ),
),
                        SizedBox(height: 10),
                        Text('State', style: TextStyle(color: Colors.white)),
                        TextField(
  controller: _stateController,
  enabled: _isEditable,
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    fillColor: Colors.grey[800],
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!, width: 1.0), // Default border color
    ),
  ),
),
                        SizedBox(height: 10),
                        Text('Pincode', style: TextStyle(color: Colors.white)),
                        TextField(
  controller: _pincodeController,
  enabled: _isEditable,
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    fillColor: Colors.grey[800],
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!, width: 1.0), // Default border color
    ),
  ),
  onChanged: (value) {
    // Auto-fill state and district based on pincode
    _autoFillLocation();
  },
),
                        SizedBox(height: 10),
                        Text('Phone Number', style: TextStyle(color: Colors.white)),
                        TextField(
  controller: _phoneController,
  enabled: _isEditable,
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    fillColor: Colors.grey[800],
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!, width: 1.0), // Default border color
    ),
  ),
),
                        SizedBox(height: 20),

                        // Save Button
                        Center(
                          child: ElevatedButton(
                            onPressed: _saveData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFCFF008), // Save button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                            child: Text('Save Data', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences if you use it

class AuthService {
  // Method to check if the user is logged in
  static Future<bool> isUserLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if a specific token or user identifier exists in preferences
    // Replace 'userToken' with the actual key you use for storing the login state
    return prefs.getString('userToken') != null;
  }
}

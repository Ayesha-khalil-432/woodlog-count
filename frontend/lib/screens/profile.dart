import 'package:flutter/material.dart';
import 'package:frontend/Storage/secureStorage.dart';
import 'package:frontend/screens/WelcomeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/Constants/constant.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    String? accessToken = await SecureStorage().readSecureData('accessToken');
    print('printtttt $accessToken');

    final url = Uri.parse('${API_BASE_URL}auth/?type=user_profile');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        setState(() {
          _userData = responseData['response'];
          _isLoading = false;
        });
        print('success to load user profile ${response.body}');
      } else {
        print('Failed to load user profile ${response.body}');
      }
    } else if (response.statusCode == 401) {
      // Unauthorized, need to refresh the access token
      await _refreshAccessToken();
      // Retry the original request after getting the new access token
      await _fetchUserProfile();
    } else {
      print('Failed to load user profile ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to retrieve user data, try logging in again'),
        ),
      );
    }
  }

  Future<void> _refreshAccessToken() async {
    String? refreshToken = await SecureStorage().readSecureData('refreshToken');
    final url = Uri.parse('${API_BASE_URL}auth/?type=get_access_token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          String newAccessToken = responseData['access_token'];
          // Save the new access token in secure storage
          await SecureStorage().writeSecureData('accessToken', newAccessToken);
          print('Access token refreshed successfully');
        } else {
          print('Failed to refresh access token: ${response.body}');
          // Handle the case where refreshing the token fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to refresh access token, try logging in again.'),
            ),
          );
        }
      } else {
        print('Failed to refresh access token: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to refresh access token, try logging in again.'),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing access token: $e');
    }
  }

  Future<void> _logout() async {
    String? accessToken = await SecureStorage().readSecureData('accessToken');
    final url = Uri.parse('${API_BASE_URL}auth/?type=logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('Successfully logged out');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully logged out'),
            ),
          );
        } else {
          print('Failed to log out: ${response.body}');
        }
      } else {
        print('Failed to log out: ${response.body}');
      }
    } catch (e) {
      print('Error logging out: $e');
    } finally {
      // Clear secure storage and navigate to the WelcomeScreen
      await SecureStorage().deleteSecureData('accessToken');
      await SecureStorage().deleteSecureData('refreshToken');
      await SecureStorage().deleteSecureData('currentRoleOfUser');
      await SecureStorage().deleteSecureData('currentRoleAdminId');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: const WelcomeScreen(),
                )),
      );
    }
  }

  Widget _buildProfileItem(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        _userData['name'][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _userData['name'] ?? '',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _userData['role'] ?? '',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileItem('Name', _userData['name'] ?? ''),
                  _buildProfileItem('Username', _userData['username'] ?? ''),
                  _buildProfileItem('Email', _userData['email'] ?? ''),
                  _buildProfileItem('Role', _userData['role'] ?? ''),
                  _buildProfileItem('Admin ID', _userData['admin_id'] ?? ''),
                  // _buildProfileItem(
                  //     'Updated At', _userData['updated_at'] ?? ''),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.red,
                        backgroundColor: Colors.redAccent[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

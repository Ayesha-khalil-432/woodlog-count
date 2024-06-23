import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/WelcomeScreen.dart';
import 'package:frontend/screens/addCheckPostByAdmin.dart';
import 'package:frontend/screens/adminDashboard.dart';
import 'package:frontend/screens/profile.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/Constants/constant.dart';
import 'package:frontend/Storage/secureStorage.dart';

class AdminLandingPage extends StatefulWidget {
  final String? adminId;

  const AdminLandingPage({this.adminId, Key? key}) : super(key: key);

  @override
  _AdminLandingPageState createState() => _AdminLandingPageState();
}

class _AdminLandingPageState extends State<AdminLandingPage> {
  int _selectedIndex = 0;
  List<dynamic> _checkPostOfficers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCheckPostOfficers();
  }

  Future<void> _fetchCheckPostOfficers() async {
    String? adminId = widget.adminId ??
        await SecureStorage().readSecureData('currentRoleAdminId');
    print('admin id: $adminId');

    if (adminId == null) {
      print('Admin ID is null');
      return; // Exit early if adminId is null
    }

    final url = Uri.parse(
        '${API_BASE_URL}auth/?type=get_check_post_officer_under_admin&admin_id=$adminId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _checkPostOfficers = responseData['check_post_officers'] ?? [];
          _isLoading = false;
        });
        print('Officers loaded successfully ${responseData}');
      } else {
        print('Failed to load check post officers: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching check post officers: $e');
      setState(() {
        _isLoading = false;
      });
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
            const SnackBar(
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      const AdminDashboardScreen(),
      _buildManageUsers(),
      const CheckPostAddingScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Check Post'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
    );
  }

  Widget _buildManageUsers() {
    return _checkPostOfficers.isEmpty
        ? const Center(child: Text('No officers found'))
        : ListView.builder(
            itemCount: _checkPostOfficers.length,
            itemBuilder: (context, index) {
              final officer = _checkPostOfficers[index];
              final name = officer['name'] ?? 'No Name';
              final email = officer['email'] ?? 'No Email';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    email,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          );
  }
}

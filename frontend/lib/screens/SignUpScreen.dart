import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/screens/LoginScreen.dart';
import 'package:frontend/screens/signupScreenAdmin.dart';
import 'package:frontend/widgets/CustomScaffoldWidget.dart';
import 'package:frontend/theme/Theme.dart';
import 'package:frontend/Constants/constant.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = true;

  List<Map<String, String>> _admins = [];
  String? _selectedAdminId;

  // Text editing controllers for capturing user input
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    final url = Uri.parse('${API_BASE_URL}auth/?type=get_admins');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        // Ensure responseData['response'] is a List<dynamic>
        final List<dynamic> adminsList = responseData['response'];

        setState(() {
          // Clear _admins list before adding new data
          _admins.clear();

          // Map each item in adminsList to Map<String, String>
          _admins = adminsList.map((admin) {
            return {
              'admin_id': admin['admin_id'].toString(),
              'name': admin['name'].toString(),
              // Add other fields as needed
            };
          }).toList();

          // Set default selected admin if _admins is not empty
          _selectedAdminId = _admins.isNotEmpty ? _admins[0]['admin_id'] : null;
        });
      } else {
        // Handle error
        print('Failed to fetch admins');
      }
    } else {
      // Handle error
      print('Failed to fetch admins');
    }
  }

  Future<void> _signUp() async {
    if (_formSignInKey.currentState!.validate() && _selectedAdminId != null) {
      final url = Uri.parse('${API_BASE_URL}auth/?type=signup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
          "role": "check_post_officer",
          "admin_id": _selectedAdminId
        }),
      );

      if (response.statusCode == 200) {
        print('Sign-up successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-up successful'),
          ),
        );
      } else {
        print('Sign-up failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-up failed'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldWidget(
      childd: Column(
        children: [
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                    Text(
                      'Welcome to CFO Sign Up',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w800,
                        color: lightColorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Form(
                      key: _formSignInKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Full Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter Full Name',
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Username';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Enter Username',
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Email';
                              } else if (!value.contains('@')) {
                                return 'Please enter a valid Email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter Email',
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            obscuringCharacter: '*',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              } else if (value.length < 8) {
                                return 'Password should be at least 8 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter Password',
                              hintStyle: const TextStyle(
                                color: Colors.black26,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          DropdownButtonFormField<String>(
                            value: _selectedAdminId,
                            items: _admins.map((admin) {
                              return DropdownMenuItem<String>(
                                value: admin['admin_id'],
                                child: Text(admin['name']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAdminId = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Select Admin',
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an admin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberPassword,
                                    onChanged: (bool? val) {
                                      setState(() {
                                        rememberPassword = val!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     // Handle forgot password
                              //   },
                              //   child: Text(
                              //     'Forgot Password',
                              //     style: TextStyle(
                              //       fontSize: 15.0,
                              //       fontWeight: FontWeight.w800,
                              //       color: lightColorScheme.primary,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 0.1),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (e) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Already have an account?..',
                          style: TextStyle(
                            color: darkColorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formSignInKey.currentState!.validate() &&
                              _selectedAdminId != null) {
                            _signUp();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Processing data'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 0.1),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (e) => const SignUpScreenAdmin(),
                            ),
                          );
                        },
                        child: Text(
                          'Continue as admin',
                          style: TextStyle(
                            color: darkColorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

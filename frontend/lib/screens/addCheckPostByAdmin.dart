import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:frontend/Constants/constant.dart';
import 'package:frontend/Storage/secureStorage.dart';

class CheckPostAddingScreen extends StatefulWidget {
  final String? adminId;

  const CheckPostAddingScreen({this.adminId, Key? key}) : super(key: key);

  @override
  _CheckPostAddingScreenState createState() => _CheckPostAddingScreenState();
}

class _CheckPostAddingScreenState extends State<CheckPostAddingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  List<dynamic> _checkPostOfficers = [];
  List<String> _selectedOfficers = [];
  bool _isLoading = true;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _fetchCheckPostOfficers();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _fetchCheckPostOfficers() async {
    String? adminId = widget.adminId ??
        await SecureStorage().readSecureData('currentRoleAdminId');
    String? accessToken = await SecureStorage().readSecureData('accessToken');

    if (adminId == null || accessToken == null) {
      print('Admin ID or access token is null');
      return;
    }

    final url = Uri.parse(
        '${API_BASE_URL}auth/?type=get_check_post_officer_under_admin&admin_id=$adminId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _checkPostOfficers = responseData['check_post_officers'] ?? [];
          _isLoading = false;
        });
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

  Future<void> _registerCheckPost() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_selectedOfficers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one check post officer'),
          ),
        );
        return;
      }

      setState(() {
        _isRegistering = true;
      });

      String? adminId = widget.adminId ??
          await SecureStorage().readSecureData('currentRoleAdminId');
      String? accessToken = await SecureStorage().readSecureData('accessToken');

      if (adminId == null || accessToken == null) {
        print('Admin ID or access token is null');
        setState(() {
          _isRegistering = false;
        });
        return;
      }

      final url = Uri.parse(
          '${API_BASE_URL}check_post/?type=register_check_post&check_post_admin_id=$adminId');
      final body = jsonEncode({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'latitude': _latitudeController.text,
        'longitude': _longitudeController.text,
        'list_of_check_post_officer': _selectedOfficers,
      });
      print('body: ' + body);

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Check post registered successfully'),
              ),
            );
            _clearFormFields();
          } else {
            print('Failed to register check post: ${response.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to register check post: ${response.body}'),
              ),
            );
          }
        } else {
          print('Failed to register check post: ${response.body}');
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${responseData['message']}'),
            ),
          );
        }
      } catch (e) {
        print('Error registering check post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error registering check post'),
          ),
        );
      } finally {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  void _clearFormFields() {
    _nameController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _selectedOfficers.clear();
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      print('position ${position.toString()}');
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.location_on),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.location_on),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Check Post Officers',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 150, // Fixed height for the scrollable area
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: _checkPostOfficers.map((officer) {
                              return CheckboxListTile(
                                title: Text(officer['name']),
                                value:
                                    _selectedOfficers.contains(officer['_id']),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedOfficers.add(officer['_id']);
                                    } else {
                                      _selectedOfficers.remove(officer['_id']);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _isRegistering
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _registerCheckPost();
                                }
                              },
                              child: Text('Register Check Post'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/Storage/secureStorage.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  late CameraDescription camera;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras != null && cameras!.isNotEmpty) {
        camera = cameras![0];
        _cameraController = CameraController(
          camera,
          ResolutionPreset.low,
          enableAudio: false,
        );
        _cameraController!.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _image = pickedFile as XFile?;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final status = await Permission.camera.request();
                  if (status == PermissionStatus.granted) {
                    _takePicture();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera permission denied'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    final XFile file = await _cameraController!.takePicture();
    setState(() {
      _image = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Image'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image != null
                  ? Image.file(File(_image!.path))
                  : const Text("No image selected"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showPicker(context);
                },
                child: const Text('Upload'),
              ),
              // ElevatedButton(
              //   onPressed: () async {
              //     SecureStorage().readSecureData('accessToken');
              //     String? accessToken =
              //         await SecureStorage().readSecureData('accessToken');
              //     String? userData = await SecureStorage()
              //         .readSecureData('currentRoleAdminId');
              //     // Print the actual access token value
              //     print('printtttt $accessToken');
              //     print('userrrrr $userData');
              //   },
              //   child: Text('accessToken'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagebook/core/auth/pages/auth/login.dart';
import 'package:imagebook/core/auth/services/auth_service.dart';
import 'package:imagebook/responsive/responsive.dart';

class ProfilesDataFillPage extends StatefulWidget {
  const ProfilesDataFillPage({Key? key}) : super(key: key);

  @override
  State<ProfilesDataFillPage> createState() => _ProfilesDataFillPageState();
}

class _ProfilesDataFillPageState extends State<ProfilesDataFillPage> {
  final String userId = AuthService().getCurrentUser()?.uid ?? 'Unknown';

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  DateTime? _selectedBirthday;
  String? _profileImageBase64;
  bool? _isUsernameAvailable;
  Timer? _debounce;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkUsername);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.removeListener(_checkUsername);
    _usernameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _checkUsername() {
    final username = _usernameController.text.trim();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (username.isEmpty) {
        setState(() => _isUsernameAvailable = null);
        return;
      }

      final existing = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: username)
          .limit(1)
          .get();

      setState(() {
        _isUsernameAvailable = existing.docs.isEmpty;
      });
    });
  }

  // ✅ Enhanced image picking with multiple source options
  Future<void> _pickAndCropImage() async {
    // Show options to pick from gallery or camera
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    setState(() => _isUploading = true);

    try {
      // Pick image using image_picker
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Crop image with enhanced options - FIXED PARAMETERS
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeControlsWidgetColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Image',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPickerButtonHidden: false,
          ),
        ],
        maxWidth: 1080,
        maxHeight: 1080,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
      );

      if (croppedFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Convert to base64
      final bytes = await croppedFile.readAsBytes();
      setState(() {
        _profileImageBase64 = base64Encode(bytes);
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process image: $e')),
      );
    }
  }

  Future<void> _pickBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _submitProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty || _selectedBirthday == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (_isUsernameAvailable == false) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Username is already taken")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userData = {
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "username": username,
        "birthday": _selectedBirthday?.toIso8601String(),
        "profilePhoto": _profileImageBase64 ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection("users").doc(userId).set(userData);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $error")));
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isMobile(context)
            ? Center(child: _profileForm(context))
            : Center(
                child: Card(
                  child: SizedBox(
                    width: 400,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: _profileForm(context),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _profileForm(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndCropImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImageBase64 != null
                        ? MemoryImage(base64Decode(_profileImageBase64!))
                        : null,
                    child: _profileImageBase64 == null
                        ? Icon(Icons.person, size: 48, color: Colors.grey[700])
                        : null,
                  ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _pickBirthday(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedBirthday != null
                      ? "${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}"
                      : 'Select your birthday',
                  style: TextStyle(
                    color: _selectedBirthday != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: const OutlineInputBorder(),
                suffixIcon: _usernameController.text.isEmpty
                    ? null
                    : (_isUsernameAvailable == null
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : (_isUsernameAvailable == true
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.close, color: Colors.red))),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(120),
                  ),
                ),
                onPressed: _isUploading ? null : _submitProfile,
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
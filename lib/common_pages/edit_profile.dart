// ignore_for_file: prefer_const_constructors

import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/components/input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  File? _profileImage;
  bool isRemoved=  false;
  Map<String, dynamic> user = {
    "userId": "107",
    "username": "Ross",
    "email": "ross@gmail.com",
    "role": "1",
    "profile_pic": "images/profile.jpg",
    "student_id": "xxxxxxx"
  };
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController =
      TextEditingController(text: 'Kaung Htet Lin');
  final TextEditingController _emailController =
      TextEditingController(text: '6531501212@lamduan.mfu.ac.th');
  final TextEditingController _studentIdController =
      TextEditingController(text: '6531501212');
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  void initState() {
    super.initState();
    isRemoved= false;
    isLoading = false;
    retrieveUserData();
  }

  Future<void> retrieveUserData() async {
    final retrievedUser = await retrieveData();
    setState(() {
      user = retrievedUser;
      _nameController.text = user['username'];
      _emailController.text = user['email'];
      _studentIdController.text = user["student_id"];
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        isRemoved= false;
      });
    }
  }
  void _removeImage(){
    setState(() {
      _profileImage= null;
     isRemoved= true;
    });
  }

  void _updateProfile() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://${Config.getServerPath()}/editProfile'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['newName'] = _nameController.text;
    request.fields['newEmail'] = _emailController.text;
    request.fields['newId'] = _studentIdController.text;
    request.fields['isRemoved'] = isRemoved.toString();
    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _profileImage!.path,
        ),
      );
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      String? token = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString('jwt_token', token);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          getSuccessSnackBar("Profile Updated"),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        getErrorSnackbar("Filled to update profile"),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight, 
                    children: [
                      CircleAvatar(
                        radius: 50, 
                        backgroundColor:
                            Colors.grey[200],
                        child: CircleAvatar(
                          radius:
                              48,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (user["profile_pic"] == null ||
                                      user["profile_pic"].isEmpty || isRemoved
                                  ? const AssetImage('images/profile.jpg')
                                      as ImageProvider
                                  : (user["profile_pic"].startsWith('http')
                                      ? NetworkImage(user["profile_pic"])
                                      : const AssetImage(
                                          'images/profile.jpg'))),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap:
                              _pickImage,
                          child: Container(
                            padding:
                                EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _removeImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: Size(70, 30),
                      padding:
                          EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    ),
                    icon: Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Remove Photo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                profileFieldInput(
                  icon: Icons.person,
                  labelText: 'Name',
                  controller: _nameController,
                ),
                profileFieldInput(
                  icon: Icons.email,
                  labelText: 'Email',
                  controller: _emailController,
                ),
                profileFieldInput(
                  icon: Icons.badge,
                  labelText: 'Student ID',
                  controller: _studentIdController,
                ),
                profileFieldInput(
                  icon: Icons.visibility,
                  labelText: 'Change your Password?',
                  controller: _passwordController,
                  isPassword: true,
                  enabled: false,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ]),
    );
  }
}

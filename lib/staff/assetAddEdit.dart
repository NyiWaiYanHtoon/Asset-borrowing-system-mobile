// ignore_for_file: prefer_const_constructors
import 'package:asset_borrowing_system_mobile/common_pages/config.dart';
import 'package:asset_borrowing_system_mobile/components/global.dart';
import 'package:asset_borrowing_system_mobile/components/input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import "package:http/http.dart" as http;

class AddEditItem extends StatefulWidget {
  bool isEdit;
  Map<dynamic, dynamic>? asset;
  AddEditItem({super.key, required this.isEdit, this.asset});

  @override
  State<AddEditItem> createState() => _AddEditItemState();
}

class _AddEditItemState extends State<AddEditItem> {
  bool isRemoved = false;
  String _type = "Laptop";
  String status = "available";
  String displayImg = "images/no-image.webp";
  File? _image;
  final ImagePicker _picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  void initState() {
    if (widget.isEdit) {
      _type = widget.asset!["type"];
      status = widget.asset!['status'];
      isRemoved= false;
      if (widget.asset!['image_url'] != null)
        displayImg = widget.asset!['image_url'];
      if (widget.asset!['description'] != null)
        descriptionController.text = widget.asset!['description'];
      nameController.text = widget.asset!["name"];
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        isRemoved= false;
        _image = File(pickedFile.path);
      });
    }
  }

  void Edit(Map<dynamic, dynamic>? asset) async {
    Map type_map = {'Laptop': 1, 'iPad': 2, 'Electronic': 3, 'Book': 4};
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://${Config.getServerPath()}/editAsset'));
    request.fields['id'] = asset!["id"].toString();
    request.fields['newName'] = nameController.text;
    request.fields['newType'] = type_map[_type].toString();
    request.fields['newStatus'] = status;
    request.fields['newDes'] = descriptionController.text;
    request.fields['isRemoved'] = isRemoved.toString();
    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _image!.path,
        ),
      );
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        getSuccessSnackBar("Asset Updated"),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        getErrorSnackbar("Filled to update asset"),
      );
    }
  }

  void Add() async {
    Map type_map = {'Laptop': 1, 'iPad': 2, 'Electronic': 3, 'Book': 4};
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://${Config.getServerPath()}/addAsset'));
    request.fields['newName'] = nameController.text;
    request.fields['newType'] = type_map[_type].toString();
    request.fields['newStatus'] = status;
    request.fields['newDes'] = descriptionController.text;
    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _image!.path,
        ),
      );
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        getSuccessSnackBar("Asset Added"),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        getErrorSnackbar("Filled to add"),
      );
    }
  }
  
  void _removeImage(){
    setState(() {
      isRemoved= true;
      _image= null;
      displayImg= "images/no-image.webp";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 290,
              width: MediaQuery.of(context).size.width,
              child: _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    )
                  : displayImg.startsWith('http') // Check if it's a network URL
                      ? Image.network(
                          displayImg,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          displayImg,
                          fit: BoxFit.contain,
                        ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: _removeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(70, 30),
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Label(label: "Asset Name"),
                  textInput(
                    label: "Enter asset name",
                    controller: nameController,
                  ),
                  Label(label: "Asset Type"),
                  DropdownInput(
                    items: const ['Laptop', 'iPad', 'Electronic', 'Book'],
                    value: _type,
                    onChanged: (String? newValue) {
                      setState(() {
                        _type = newValue!;
                      });
                    },
                  ),
                  Label(label: "Initial Status"),
                  DropdownInput(
                    items: const [
                      'available',
                      'borrowed',
                      'disabled',
                      'waiting'
                    ],
                    value: status,
                    onChanged: (String? newValue) {
                      setState(() {
                        status = newValue!;
                      });
                    },
                  ),
                  Label(label: "Add Picture"),
                  const SizedBox(height: 8.0),
                  DropdownInput(
                    items: const ["Gallery", "Camera"],
                    value: "Gallery",
                    onChanged: (String? newValue) {
                      if (newValue == 'Gallery') {
                        _pickImage(ImageSource.gallery);
                      } else if (newValue == 'Camera') {
                        _pickImage(ImageSource.camera);
                      }
                    },
                  ),
                  Label(label: "Description"),
                  LongTextInput(
                    label: "---description---",
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          if (widget.isEdit) {
                            Edit(widget.asset);
                          } else {
                            Add();
                          }
                          setState(() {});
                        },
                        child: widget.isEdit
                            ? const Text('Save Changes')
                            : const Text('Add item'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test/component/CustomTextFormField.dart';
import 'package:test/component/MyAppBar.dart';
import 'package:test/db/mongodb.dart';

class InsertOwner extends StatefulWidget {
  const InsertOwner({super.key});

  @override
  _InsertOwnerState createState() => _InsertOwnerState();
}

class _InsertOwnerState extends State<InsertOwner> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  List<Map<String, dynamic>> owners = [];
  bool isLoadingOwners = true;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File? croppedFile = await cropImage(File(pickedFile.path));
      if (croppedFile != null) {
        setState(() {
          _image = croppedFile;
        });
      }
    }
  }

  Future<File?> cropImage(File imageFile) async {
    try {
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      return cropped != null ? File(cropped.path) : null;
    } catch (e) {
      debugPrint("Lỗi crop ảnh: $e");
      return null;
    }
  }

  Future<void> uploadImage() async {
    if (_image == null || nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ảnh và nhập tên")),
      );
      return;
    }

    List<int> imageBytes = _image!.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    await MongodbDatabase.createOwner(
        _image!, base64Image, nameController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Owner created successfully")),
    );

    nameController.clear();
    setState(() {
      _image = null;
    });

    _loadOwners();
  }

  Future<void> _loadOwners() async {
    try {
      List<Map<String, dynamic>> data = await MongodbDatabase.getOwner();
      if (mounted) {
        setState(() {
          owners = data;
          isLoadingOwners = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải danh sách Owner: $e');
      if (mounted) {
        setState(() {
          isLoadingOwners = false;
        });
      }
    }
  }

  Future<void> _deleteOwner(String id) async {
    bool confirmDelete = await _showDeleteConfirmation();
    if (confirmDelete) {
      await MongodbDatabase.deleteOwner(id);
      _loadOwners();
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa Owner này?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                CustomTextFormField(
                    controller: nameController, labelText: "Enter name"),
                const SizedBox(height: 20),
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildButtons(),
                const SizedBox(height: 20),
                _buildOwnersList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Divider(thickness: 2),
            ),
            const SizedBox(width: 10), // Khoảng cách giữa Divider và Text
            const Text("Insert Owner",
                style: TextStyle(fontSize: 30, color: Colors.black)),
            const SizedBox(width: 10), // Khoảng cách giữa Text và Divider
            Expanded(
              child: Divider(thickness: 2),
            ),
          ],
        ));
  }

  Widget _buildImagePicker() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3))
        ],
      ),
      child: _image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(_image!, fit: BoxFit.cover))
          : const Center(
              child: Text("Preview", style: TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: pickImage,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          child: const Text("📷 Choose the picture",
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: uploadImage,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          child: const Text("💾 Save",
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildOwnersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📜 List of Owners",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        isLoadingOwners
            ? const Center(child: CircularProgressIndicator())
            : owners.isEmpty
                ? const Text("No owners found",
                    style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: owners.length,
                    itemBuilder: (context, index) {
                      final owner = owners[index];
                      String? ownerImageBase64 = owner['image_base64'];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: ownerImageBase64 != null &&
                                    ownerImageBase64.isNotEmpty
                                ? MemoryImage(base64Decode(ownerImageBase64))
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                          ),
                          title: Text(owner['name'] ?? 'Unknown'),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteOwner(owner['_id'])),
                        ),
                      );
                    },
                  ),
      ],
    );
  }
}

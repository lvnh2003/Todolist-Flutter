import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test/db/mongodb.dart';

class OwnerSelectionDropdown extends StatefulWidget {
  final Function(String, String?) onSelected;
  final Map<String, dynamic>? initialOwner;

  const OwnerSelectionDropdown({
    super.key,
    required this.onSelected,
    this.initialOwner,
  });

  @override
  _OwnerSelectionDropdownState createState() => _OwnerSelectionDropdownState();
}

class _OwnerSelectionDropdownState extends State<OwnerSelectionDropdown> {
  String? selectedOwnerName;
  String? selectedOwnerImage;
  List<Map<String, dynamic>> owners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Nếu có owner ban đầu, set dữ liệu
    if (widget.initialOwner != null) {
      selectedOwnerName = widget.initialOwner!['name'];
      selectedOwnerImage = widget.initialOwner!['image_base64'];
    }
    _loadOwners();
  }

  Future<void> _loadOwners() async {
    try {
      List<Map<String, dynamic>> data = await MongodbDatabase.getOwner();
      if (mounted) {
        setState(() {
          owners = data;
          isLoading = false;

          // Nếu có owner ban đầu, cập nhật ảnh đúng từ danh sách owners
          if (selectedOwnerName != null) {
            final existingOwner = owners.firstWhere(
              (owner) => owner['name'] == selectedOwnerName,
              orElse: () => {},
            );
            if (existingOwner.isNotEmpty) {
              selectedOwnerImage = existingOwner['image_base64'];
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi tải danh sách Owner: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (owners.isEmpty) {
      return const Text('No owners found');
    }

    return DropdownButtonFormField<String>(
      value: selectedOwnerName,
      items: owners.map((owner) {
        String? ownerImageBase64 = owner['image_base64'];
        return DropdownMenuItem<String>(
          value: owner['name'], // Sử dụng name làm giá trị chính
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: ownerImageBase64 != null && ownerImageBase64.isNotEmpty
                    ? MemoryImage(base64Decode(ownerImageBase64))
                    : const AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              const SizedBox(width: 10),
              Text(owner['name'] ?? 'Unknown'),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        final selectedOwner = owners.firstWhere((owner) => owner['name'] == value);

        setState(() {
          selectedOwnerName = value;
          selectedOwnerImage = selectedOwner['image_base64'];
        });

        widget.onSelected(selectedOwnerName!, selectedOwnerImage);
      },
      decoration: const InputDecoration(
        labelText: 'Select Owner',
        border: OutlineInputBorder(),
      ),
    );
  }
}

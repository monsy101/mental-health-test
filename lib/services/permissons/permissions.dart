import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> requestStoragePermission(context) async {
  var status = await Permission.photos.request(); // ✅ For Android 13+
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Storage permission required"),
          backgroundColor: Colors.red),
    );
  }
}
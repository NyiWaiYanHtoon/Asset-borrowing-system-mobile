import 'package:asset_borrowing_system_mobile/common_pages/login.dart';
import 'package:flutter/material.dart';
void main() {  
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: LoginPage(),
    ),
  );
}
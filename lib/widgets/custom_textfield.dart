// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:tictactoe_mp/utils/colors.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int limit;
  final bool isReadOnly;
  const CustomTextfield({
    Key? key,
    required this.controller,
    required this.hintText,
    this.isReadOnly = false,
    required this.limit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.deepPurple,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white, fontFamily: 'SF'),
        readOnly: isReadOnly,
        controller: controller,
        maxLength: limit,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          counterText: '',
          fillColor: bgColor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50),
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

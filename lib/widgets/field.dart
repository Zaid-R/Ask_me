import 'package:flutter/material.dart';

import '../pages/auth_page.dart';


// ignore: must_be_immutable
class Field extends StatefulWidget {
  final String title;
  final double width;
  final String? Function(String?) validator;
  final Function(String?)? onSaved;
  final String? hint;
  final TextInputType? inputType;
  final TextEditingController? controller;
  final bool isPassword;
  bool _isObscureText;

  Field({
    super.key, 
    required this.title,
    required this.width,
    required this.validator,
    this.onSaved,
    this.hint,
    this.inputType,
    this.controller,
    this.isPassword = false,
  }) : _isObscureText = isPassword;
  
  @override
  State<StatefulWidget> createState()=>_FieldState();
}

class _FieldState extends State<Field>{
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(1), //Color.fromRGBO(234, 149, 241, 1),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: TextFormField(
        cursorColor:Colors.grey[700],
        controller: widget.controller,
        validator: widget.validator,
        onSaved: widget.onSaved,
        obscureText: widget._isObscureText,
        keyboardType: widget.inputType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(
              color: AuthPage.color
            )
          ),
          contentPadding: const EdgeInsets.all(15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          labelText: widget.title,
          labelStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 20),
          suffixIcon:widget.isPassword? IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
               widget._isObscureText
               ? Icons.visibility
               : Icons.visibility_off,
               color: Colors.black87,
               ),
            onPressed: () =>setState(() => widget._isObscureText=!widget._isObscureText),
            ):null
        ),
      ),
    );
  }
}

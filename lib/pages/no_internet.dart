import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InternetLossPage extends StatelessWidget {
  const InternetLossPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'لا يوجد اتصال بالإنترنت',
          style: GoogleFonts.changa(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

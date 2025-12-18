import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../layout/main_layout.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Center(child: Icon(Icons.check, size: 90, color: Colors.green)),
            ),
            const SizedBox(height: 24),
            Text(
              'Order Placed',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been placed successfully',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainLayout(),
                    ),
                    (route) => false,
                  );
                },
                child: Text('Back to Home', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
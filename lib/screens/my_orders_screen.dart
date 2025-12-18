import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../layout/main_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final orders = Provider.of<OrderProvider>(context)
        .orders
        .where((o) => o.userId == uid)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "My Orders",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainLayout()),
              );
            },
          )
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                "No orders yet",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final o = orders[index];

                final steps = ["Processed", "Shipped", "En Route", "Arrived"];
                final currentStep = steps.indexOf(o.status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #${o.id.substring(o.id.length - 6)}",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "${o.date.day}/${o.date.month}/${o.date.year}",
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${o.fullName}", style: GoogleFonts.poppins(fontSize: 14)),
                            Text("Phone: ${o.phone}", style: GoogleFonts.poppins(fontSize: 14)),
                            Text("Address: ${o.address}", style: GoogleFonts.poppins(fontSize: 14)),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey.shade300),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ...o.cart.take(2).map((p) => Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        p['thumbnail'],
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        p['title'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Text("x${p['quantity']}", style: GoogleFonts.poppins(color: Colors.grey[700])),
                                  ],
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (o.cart.length > 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("+ ${o.cart.length - 2} more items",
                              style: GoogleFonts.poppins(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      const SizedBox(height: 6),
                      Divider(color: Colors.grey.shade300),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                            Text("\$${o.totalPrice.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: List.generate(steps.length * 2 - 1, (i) {
                            if (i.isEven) {
                              int stepIndex = i ~/ 2;
                              return _step(stepIndex <= currentStep);
                            } else {
                              int lineIndex = (i - 1) ~/ 2;
                              return _line(lineIndex < currentStep);
                            }
                          }),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.assignment_turned_in_outlined, size: 28),
                                const SizedBox(height: 4),
                                Text("Processed", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.local_shipping_outlined, size: 28),
                                const SizedBox(height: 4),
                                Text("Shipped", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.fire_truck_outlined, size: 28),
                                const SizedBox(height: 4),
                                Text("En Route", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.home_outlined, size: 28),
                                const SizedBox(height: 4),
                                Text("Arrived", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _step(bool active) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: active ? Colors.purple : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: active ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
    );
  }

  Widget _line(bool active) {
    return Expanded(
      child: Container(
        height: 4,
        color: active ? Colors.purple : Colors.grey.shade300,
      ),
    );
  }
}
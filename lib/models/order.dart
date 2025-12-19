import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String fullName;
  final String address;
  final String phone;
  final double totalPrice;
  final List<Map<String, dynamic>> cart;
  final DateTime date;
  String status;

  Order({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.address,
    required this.phone,
    required this.totalPrice,
    required this.cart,
    required this.date,
    this.status = 'Processed',
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'],
      fullName: data['fullName'],
      address: data['address'],
      phone: data['phone'],
      totalPrice: (data['totalPrice'] as num).toDouble(),
      cart: List<Map<String, dynamic>>.from(data['cart']),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Order copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? address,
    String? phone,
    double? totalPrice,
    List<Map<String, dynamic>>? cart,
    DateTime? date,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      totalPrice: totalPrice ?? this.totalPrice,
      cart: cart ?? this.cart,
      date: date ?? this.date,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'my_orders_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as myOrder;
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartProducts;
  const CheckoutScreen({super.key, required this.cartProducts});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late List<Map<String, dynamic>> cart;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstController = TextEditingController();
  final TextEditingController lastController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController aptController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  String country = 'Egypt';
  bool warranty12 = false;
  bool warranty27 = false;
  int paymentMethod = 0;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> creditFormKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    cart = widget.cartProducts;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        emailController.text = data['email'] ?? '';
        firstController.text = data['firstName'] ?? '';
        lastController.text = data['lastName'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        aptController.text = data['apt'] ?? '';
        cityController.text = data['city'] ?? '';
        stateController.text = data['state'] ?? '';
        zipController.text = data['zip'] ?? '';
        country = data['country'] ?? 'Egypt';
      }
    }
  }

  Future<void> _saveShippingData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'firstName': firstController.text,
        'lastName': lastController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'apt': aptController.text,
        'city': cityController.text,
        'state': stateController.text,
        'zip': zipController.text,
        'country': country,
      }, SetOptions(merge: true));
    }
  }

  double getTotal() {
    double total = 0;
    for (var item in cart) total += item['price'] * item['quantity'];
    if (warranty12) total += 175;
    if (warranty27) total += 230;
    return total;
  }

  Widget formField(TextEditingController c, String hint,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(),
    );
  }

  void onCreditCardModelChange(CreditCardModel model) {
    setState(() {
      cardNumber = model.cardNumber;
      expiryDate = model.expiryDate;
      cardHolderName = model.cardHolderName;
      cvvCode = model.cvvCode;
      isCvvFocused = model.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cart.isEmpty
          ? const Center(
              child: Text('Your cart is empty', style: TextStyle(fontSize: 18)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  formField(emailController, 'Email Address*', type: TextInputType.emailAddress),
                  const SizedBox(height: 18),
                  Text('Shipping', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: formField(firstController, 'First Name')),
                            const SizedBox(width: 10),
                            Expanded(child: formField(lastController, 'Last Name')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        formField(phoneController, 'Phone', type: TextInputType.phone),
                        const SizedBox(height: 10),
                        formField(addressController, 'Address'),
                        const SizedBox(height: 10),
                        formField(aptController, 'Apt, Suite'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: formField(cityController, 'City')),
                            const SizedBox(width: 10),
                            Expanded(child: formField(stateController, 'State')),
                            const SizedBox(width: 10),
                            Expanded(child: formField(zipController, 'ZIP Code', type: TextInputType.number)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            value: country,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: ['Egypt', 'United States', 'United Kingdom', 'Canada']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins())))
                                .toList(),
                            onChanged: (v) => setState(() => country = v ?? country),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Payment Method', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  RadioListTile<int>(
                    value: 0,
                    groupValue: paymentMethod,
                    onChanged: (v) => setState(() => paymentMethod = v ?? 0),
                    title: Text('Cash on Delivery', style: GoogleFonts.poppins()),
                  ),
                  RadioListTile<int>(
                    value: 1,
                    groupValue: paymentMethod,
                    onChanged: (v) => setState(() => paymentMethod = v ?? 1),
                    title: Text('Credit Card', style: GoogleFonts.poppins()),
                  ),
                  const SizedBox(height: 18),
                  if (paymentMethod == 1) ...[
                    CreditCardWidget(
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: isCvvFocused,
                      isHolderNameVisible: true,
                      onCreditCardWidgetChange: (value) {},
                    ),
                    const SizedBox(height: 16),
                    CreditCardForm(
                      formKey: creditFormKey,
                      onCreditCardModelChange: onCreditCardModelChange,
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cvvCode: cvvCode,
                      cardHolderName: cardHolderName,
                      isHolderNameVisible: true,
                      obscureCvv: false,
                      obscureNumber: false,
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text('Order Summary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                    child: Column(
                      children: [
                        ...cart.map((product) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(product['thumbnail'], width: 60, height: 60, fit: BoxFit.cover)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(product['title'],
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text('\$${product['price']} x ${product['quantity']}', style: GoogleFonts.poppins(color: Colors.grey[700])),
                                  ]),
                                ),
                                Text('\$${(product['price'] * product['quantity']).toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Subtotal', style: GoogleFonts.poppins()),
                          Text('\$${(getTotal() - (warranty12 ? 175 : 0) - (warranty27 ? 230 : 0)).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Shipping', style: GoogleFonts.poppins()),
                          Text('\$10.00', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ]),
                        if (warranty12)
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('Warranty 12 mo', style: GoogleFonts.poppins()),
                            Text('\$175.00', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))
                          ]),
                        if (warranty27)
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('Warranty 27 mo', style: GoogleFonts.poppins()),
                            Text('\$230.00', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))
                          ]),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Total', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text('\$${(getTotal() + 10).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        await _saveShippingData();

                        final order = myOrder.Order(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          fullName: "${firstController.text} ${lastController.text}",
                          address: addressController.text,
                          phone: phoneController.text,
                          totalPrice: getTotal() + 10,
                          cart: cart,
                          date: DateTime.now(),
                        );

                        Provider.of<OrderProvider>(context, listen: false).addOrder(order);

                        if (paymentMethod == 0 || (paymentMethod == 1 && creditFormKey.currentState!.validate())) {
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
                        }
                      },
                      child: Text('Place Order',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

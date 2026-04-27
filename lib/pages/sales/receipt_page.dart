// import 'package:flutter/material.dart';
// import 'package:chicken_dilivery/bluthooth/printer_service.dart';
// import 'package:chicken_dilivery/Model/salesModel.dart';
// import 'package:chicken_dilivery/Model/CartItemModel.dart';

// class ReceiptPage extends StatelessWidget {
//   final String shopName;
//   final String billNo;
//   final String date;
//   final List<CartItem> cartItems;
//   final double totalAmount;
//   final String rootName;

//   const ReceiptPage({
//     super.key,
//     required this.shopName,
//     required this.billNo,
//     required this.date,
//     required this.cartItems,
//     required this.totalAmount,
//     required this.rootName,
//   });

//   Future<void> _printReceipt(BuildContext context) async {
//     await PrinterService.printReceipt(
//       shopName: shopName,
//       billNo: billNo,
//       date: date,
//       cartItems: cartItems,
//       totalAmount: totalAmount,
//     );
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Receipt sent to printer!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sales Receipt'),
//         backgroundColor: const Color.fromARGB(255, 26, 11, 167),
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Shop Header
//                     _buildShopHeader(),
//                     // Customer Info
//                     _buildCustomerInfo(),
//                     const Divider(height: 24, thickness: 1),
//                     // Receipt Content
//                     ...cartItems.map(
//                       (item) => _buildReceiptRow(
//                         item.itemName,
//                         '${item.weight.toStringAsFixed(2)}kg x RS ${item.sellingPrice.toStringAsFixed(2)} = RS ${item.amount.toStringAsFixed(2)}',
//                       ),
//                     ),
//                     const Divider(height: 24, thickness: 1),
//                     _buildReceiptRow(
//                       'TOTAL',
//                       'RS ${totalAmount.toStringAsFixed(2)}',
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton.icon(
//               onPressed: () => _printReceipt(context),
//               icon: const Icon(Icons.print),
//               label: const Text('Print Receipt'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(255, 26, 11, 167),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShopHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: const [
//         Text(
//           'DILANKA DISTRIBUTOR R W K',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 2),
//         Text(
//           'D.S ABEGUNAWARDANA MAWATHA KATUDENIYA OKANDAWATTA,MORAWAKA',
//           style: TextStyle(fontSize: 13),
//         ),
//         SizedBox(height: 2),
//         Text('TP : 07709109413', style: TextStyle(fontSize: 13)),
//         SizedBox(height: 2),
//         Text('Authorized Distributor For CRYSBRO Chicken', style: TextStyle(fontSize: 13)),
//         SizedBox(height: 2),
//         Text('Hotline : 077-2797276', style: TextStyle(fontSize: 13)),
//         Divider(height: 24, thickness: 1),
//         Text('------------------------------------------------------------------'),
//         SizedBox(height: 3),
//         Center(
//           child: Text(
//             'SALES INVOICE ',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//         SizedBox(height: 3),
//       ],
//     );
//   }

//   Widget _buildCustomerInfo() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Customer : $shopName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 2),
//         Text('Address : $rootName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 2),
//         Text('Deliverd to : $shopName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 2),
//         Text('Inv.Date : $date', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 2),
//         Text('Bill No: $billNo', style: const TextStyle(fontSize: 13)),
//         const SizedBox(height: 2),
//       ],
//     );
//   }

//   Widget _buildReceiptRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
//           ),
//         ],
//       ),
//     );
//   }
// }

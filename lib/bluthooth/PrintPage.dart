// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Printpage extends StatelessWidget {
//   const Printpage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "BT Print Test",
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true),
//       home: const PrinterTestPage(),
//     );
//   }
// }

// class PrinterTestPage extends StatefulWidget {
//   const PrinterTestPage({super.key});

//   @override
//   State<PrinterTestPage> createState() => _PrinterTestPageState();
// }

// class _PrinterTestPageState extends State<PrinterTestPage> {
//   String? selectedPrinterName;
//   bool isPrinting = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedPrinterName();
//   }

//   Future<void> _loadSavedPrinterName() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       selectedPrinterName = prefs.getString("selected_printer_name");
//     });
//   }

//   Future<void> _selectPrinter() async {
//     final devices = await SimplePrinterService.getPairedDevices();
//     if (!mounted) return;

//     if (devices.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No paired Bluetooth devices found.")),
//       );
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       builder: (ctx) {
//         return SafeArea(
//           child: ListView.separated(
//             itemCount: devices.length,
//             separatorBuilder: (_, __) => const Divider(height: 1),
//             itemBuilder: (_, i) {
//               final d = devices[i];
//               final name = d.name ?? "Unknown";
//               final mac = d.address ?? "";
//               return ListTile(
//                 title: Text(name),
//                 subtitle: Text(mac),
//                 onTap: () async {
//                   await SimplePrinterService.saveSelectedPrinter(d);
//                   Navigator.pop(ctx);
//                   await _loadSavedPrinterName();
//                   if (!mounted) return;
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Selected printer: $name")),
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _printTestReceipt() async {
//     setState(() => isPrinting = true);

//     final ok = await SimplePrinterService.printTestReceipt();

//     if (mounted) {
//       setState(() => isPrinting = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             ok
//                 ? "Print sent successfully ✅"
//                 : "Print failed ❌ (Select printer first / connection error)",
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final name = selectedPrinterName ?? "Not selected";

//     return Scaffold(
//       appBar: AppBar(title: const Text("Bluetooth Printer Test")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Card(
//               child: ListTile(
//                 title: const Text("Selected Printer"),
//                 subtitle: Text(name),
//               ),
//             ),
//             const SizedBox(height: 16),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _selectPrinter,
//                 child: const Text("Select Printer"),
//               ),
//             ),
//             const SizedBox(height: 12),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isPrinting ? null : _printTestReceipt,
//                 child: isPrinting
//                     ? const Text("Printing...")
//                     : const Text("Print Test Receipt"),
//               ),
//             ),

//             const SizedBox(height: 18),
//             const Text(
//               "✅ Make sure printer is paired in phone Bluetooth settings first.\n"
//               "✅ Then select printer here.\n"
//               "✅ Then print.\n",
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // -----------------------------------------------------------------------------
// // SIMPLE PRINTER SERVICE (works even if headset connected)
// // -----------------------------------------------------------------------------
// class SimplePrinterService {
//   static final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

//   static const _kPrinterMacKey = "selected_printer_mac";
//   static const _kPrinterNameKey = "selected_printer_name";

//   static Future<List<BluetoothDevice>> getPairedDevices() async {
//     try {
//       return await bluetooth.getBondedDevices();
//     } catch (_) {
//       return [];
//     }
//   }

//   static Future<void> saveSelectedPrinter(BluetoothDevice device) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_kPrinterMacKey, device.address ?? "");
//     await prefs.setString(_kPrinterNameKey, device.name ?? "");
//   }

//   static Future<BluetoothDevice?> _getSavedPrinterDevice() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedMac = prefs.getString(_kPrinterMacKey);
//     if (savedMac == null || savedMac.trim().isEmpty) return null;

//     final devices = await bluetooth.getBondedDevices();
//     for (final d in devices) {
//       if ((d.address ?? "").toLowerCase() == savedMac.toLowerCase()) {
//         return d;
//       }
//     }
//     return null;
//   }

//   static Future<bool> _connectSavedPrinter() async {
//     try {
//       final device = await _getSavedPrinterDevice();
//       if (device == null) return false;

//       // Force reconnect: avoids confusing "connected" states
//       try {
//         final isConn = await bluetooth.isConnected ?? false;
//         if (isConn) {
//           await bluetooth.disconnect();
//         }
//       } catch (_) {}

//       await bluetooth.connect(device);
//       return (await bluetooth.isConnected ?? false);
//     } catch (_) {
//       return false;
//     }
//   }

//   static Future<bool> printTestReceipt() async {
//     try {
//       final ok = await _connectSavedPrinter();
//       if (!ok) return false;

//       final profile = await CapabilityProfile.load();
//       final generator = Generator(PaperSize.mm58, profile);

//       List<int> bytes = [];
//       bytes += generator.text(
//         "TEST RECEIPT",
//         styles: const PosStyles(align: PosAlign.center, bold: true),
//       );
//       bytes += generator.hr();
//       bytes += generator.text("Hello from Flutter ✅");
//       bytes += generator.text("Time: ${DateTime.now()}");
//       bytes += generator.hr();
//       bytes += generator.text(
//         "Thank you!",
//         styles: const PosStyles(align: PosAlign.center, bold: true),
//       );
//       bytes += generator.feed(2);
//       bytes += generator.cut();

//       bluetooth.writeBytes(Uint8List.fromList(bytes));
//       return true;
//     } catch (_) {
//       return false;
//     }
//   }
// }

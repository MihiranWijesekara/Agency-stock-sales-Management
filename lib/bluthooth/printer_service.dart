import 'dart:io';
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'receipt_builder.dart';
import 'package:chicken_dilivery/Model/CartItemModel.dart';

class PrinterService {
  // -------------------- MOBILE BLUETOOTH --------------------
  static final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  static Future<void> printMobileBluetooth({
    required String shopName,
    required String billNo,
    required String date,
    required List<CartItem> cartItems,
    required double totalAmount,
    required String rootName,
  }) async {
    try {
      var isConnected = await bluetooth.isConnected ?? false;
      if (!isConnected) {
        final devices = await bluetooth.getBondedDevices();
        if (devices.isEmpty) return; // No printer found, just return
        await bluetooth.connect(devices[0]);
      }
      List<int> data = await ReceiptBuilder.buildReceipt(
        shopName: shopName,
        billNo: billNo,
        date: date,
        cartItems: cartItems,
        totalAmount: totalAmount,
        rootName: rootName,
      );
      bluetooth.writeBytes(Uint8List.fromList(data));
    } catch (e) {
      // Ignore errors, do not show error to user
    }
  }

  // -------------------- DESKTOP PRINTER --------------------
  // Works for Windows, macOS, Linux via network/USB printers
  static Future<void> printDesktop({
    required String shopName,
    required String billNo,
    required String date,
    required List<CartItem> cartItems,
    required double totalAmount,
    required String rootName,
  }) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm58, profile);

    const printerIp = '192.168.1.100';

    final result = await printer.connect(printerIp, port: 9100);
    if (result == PosPrintResult.success) {
      printer.rawBytes(await ReceiptBuilder.buildReceipt(
        shopName: shopName,
        billNo: billNo,
        date: date,
        cartItems: cartItems,
        totalAmount: totalAmount,
        rootName: rootName,
      ));
      printer.disconnect();
    }
  }

  static Future<void> printReceipt({
    required String shopName,
    required String billNo,
    required String date,
    required List<CartItem> cartItems,
    required double totalAmount,
    required String rootName,
  }) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await printMobileBluetooth(
          shopName: shopName,
          billNo: billNo,
          date: date,
          cartItems: cartItems,
          totalAmount: totalAmount,
          rootName: rootName,
        );
      } else {
        await printDesktop(
          shopName: shopName,
          billNo: billNo,
          date: date,
          cartItems: cartItems,
          totalAmount: totalAmount,
          rootName: rootName,
        );
      }
    } catch (e) {
      // Ignore errors, do not show error to user
    }
  }
}

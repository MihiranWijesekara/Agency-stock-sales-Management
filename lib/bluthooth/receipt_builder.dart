import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:chicken_dilivery/Model/CartItemModel.dart';

class ReceiptBuilder {
  static Future<List<int>> buildReceipt({
    required String shopName,
    required String billNo,
    required String date,
    required List<CartItem> cartItems,
    required double totalAmount,
    required String rootName,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    // ===== HEADER =====
    bytes += generator.feed(2);
    bytes += generator.text(
      'DILANKA DISTRIBUTOR R W K',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);

    bytes += generator.text(
      'D.S ABEGUNAWARDANA MAWATHA\nKATUDENIYA OKANDAWATTA, MORAWAKA',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);

    bytes += generator.text(
      'TP : 07709109413',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Authorized Distributor For CRYSBRO Chicken',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Hotline : 077-2797276',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);

    bytes += generator.hr();
    bytes += generator.text(
      'SALES INVOICE',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.hr();

    // ===== CUSTOMER INFO =====
    bytes += generator.text('Bill No : $billNo');
    bytes += generator.text(
      'Customer : $shopName',
      styles: PosStyles(bold: true),
    );
    bytes += generator.text('Address  : $rootName');
    bytes += generator.text('Delivered to : $shopName');
    bytes += generator.text('Inv.Date : $date');
    bytes += generator.hr();

    // ===== ITEM HEADER =====
    bytes += generator.row([
      PosColumn(text: '#', width: 1, styles: PosStyles(bold: true)),
      PosColumn(text: 'Item', width: 11, styles: PosStyles(bold: true)),
    ]);

    bytes += generator.row([
      PosColumn(text: '', width: 1),
      PosColumn(
        text: 'Weight',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: 'Rate',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
      PosColumn(
        text: 'Amount',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr(ch: '-');

    // ===== ITEMS =====
    int index = 1;
    for (final item in cartItems) {
      final double itemTotal = item.amount;

      // Item name line
      bytes += generator.row([
        PosColumn(text: '$index', width: 1),
        PosColumn(text: item.itemName, width: 11),
      ]);

      // Item details line (TOTAL WIDTH = 12 ✅)
      bytes += generator.row([
        PosColumn(text: '', width: 1),
        PosColumn(
          text: item.weight.toStringAsFixed(3),
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'RS ${item.sellingPrice.toStringAsFixed(2)}',
          width: 4,
          styles: PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: itemTotal.toStringAsFixed(2),
          width: 4,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.feed(1);
      index++;
    }

    bytes += generator.hr();

    // ===== TOTALS =====
    double totalDiscount = cartItems.fold(
      0.0,
      (sum, item) => sum + item.discount,
    );

    bytes += generator.text(
      'TOTAL : RS ${totalAmount.toStringAsFixed(2)}',
      styles: PosStyles(align: PosAlign.right, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'DISCOUNT : RS ${totalDiscount.toStringAsFixed(2)}',
      styles: PosStyles(align: PosAlign.right),
    );

    bytes += generator.feed(2);

    // ===== FOOTER =====
    bytes += generator.text(
      'Printed on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );
    bytes += generator.hr();
    bytes += generator.text(
      '------- Thank You -------',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(4);

    return bytes;
  }
}

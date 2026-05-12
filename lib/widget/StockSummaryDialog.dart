import 'package:flutter/material.dart';
import 'package:chicken_dilivery/Model/StockModel.dart';
import 'package:collection/collection.dart'; // Add this import for grouping

class StockSummaryDialog extends StatelessWidget {
  final int totalItems;
  final int filteredItems;
  final List<StockModel> stocks;

  const StockSummaryDialog({
    Key? key,
    required this.totalItems,
    required this.filteredItems,
    required this.stocks,
  }) : super(key: key);

  double _calculateTotalWeight() {
    double totalWeight = 0;
    for (var stock in stocks) {
      if (stock.quantity_grams != null) {
        totalWeight += stock.quantity_grams!.toDouble();
      }
    }
    return totalWeight / 1000; // Convert to Kg
  }

  @override
  Widget build(BuildContext context) {
    final totalWeightKg = _calculateTotalWeight();

    // Group stocks by item_id and calculate total quantity and packet counts
    final groupedStocks = groupBy(stocks, (StockModel stock) => stock.item_id);
    final List<Widget> stockWidgets = groupedStocks.entries.map((entry) {
      final itemId = entry.key;
      final itemStocks = entry.value;

      final totalGrams = itemStocks.fold<double>(0.0, (sum, stock) {
        return sum + ((stock.quantity_grams ?? 0).toDouble());
      });

      final totalPackets = itemStocks.fold<int>(0, (sum, stock) {
        return sum + (stock.numberofpacks ?? 0);
      });

      final totalWeightKg = totalGrams / 1000;
      final itemName = itemStocks.first.item_name ?? 'Unknown Item';

      String subtitle;
      if (totalPackets > 0 && totalWeightKg > 0) {
        subtitle =
            'Total Stock: ${totalWeightKg.toStringAsFixed(2)} Kg, ${totalPackets} P';
      } else if (totalPackets > 0) {
        subtitle = 'Total Stock: ${totalPackets} P';
      } else {
        subtitle = 'Total Stock: ${totalWeightKg.toStringAsFixed(2)} Kg';
      }

      return ListTile(title: Text(itemName), subtitle: Text(subtitle));
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Stock Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Items:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 49, 49, 49),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(children: stockWidgets),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 26, 11, 167),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        totalWeight += stock.quantity_grams!;
      }
    }
    return totalWeight / 1000; // Convert to Kg
  }

  @override
  Widget build(BuildContext context) {
    final totalWeightKg = _calculateTotalWeight();

    // Group stocks by item_id and calculate total quantity
    final groupedStocks = groupBy(stocks, (StockModel stock) => stock.item_id);
    final List<Widget> stockWidgets = groupedStocks.entries.map((entry) {
      final itemId = entry.key;
      final itemStocks = entry.value;
      final totalQuantity =
          itemStocks.fold(
            0,
            (sum, stock) => sum + (stock.quantity_grams ?? 0),
          ) /
          1000;
      final itemName =
          itemStocks.first.item_name ??
          'Unknown Item'; // Assuming item_name is consistent

      return ListTile(
        title: Text(itemName),
        subtitle: Text('Total Stock: ${totalQuantity} Kg'),
      );
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
            // Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Total Weight',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 54, 54, 54),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${totalWeightKg.toStringAsFixed(2)} Kg',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 26, 11, 167),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Item List
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

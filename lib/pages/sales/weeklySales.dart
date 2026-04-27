import 'package:chicken_dilivery/Model/salesModel.dart';
import 'package:chicken_dilivery/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Weeklysales extends StatefulWidget {
  const Weeklysales({super.key});

  @override
  State<Weeklysales> createState() => _WeeklysalesState();
}

class _WeeklysalesState extends State<Weeklysales> {
  List<Salesmodel> sales = [];
  bool isLoading = false;
  List<Map<String, dynamic>> _items = [];

  double profit = 0.0;

  int _currentPage = 0;
  final int _pageSize = 30;

  // For expansion state
  Set<String> _expandedBills = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadStocks();
    _weeklyProfit();
  }

  Future<void> _weeklyProfit() async {
    final result = await DatabaseHelper.instance.getWeeklyTotalProfit();
    setState(() {
      profit = result is num ? result.toDouble() : 0.0;
    });
  }

  Future<void> _loadItems() async {
    final items = await DatabaseHelper.instance.getAllItems();
    setState(() {
      _items = items.map((item) => {'id': item.id, 'name': item.name}).toList();
    });
  }

  Future<void> _loadStocks() async {
    setState(() => isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getWeeklySales();
      setState(() {
        sales = data.map((map) => Salesmodel.fromMap(map)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading sales: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Group sales by billNo
  Map<String, List<Salesmodel>> get _groupedSales {
    final Map<String, List<Salesmodel>> grouped = {};
    for (final sale in sales) {
      final key =
          '${sale.billNo ?? ''}|${sale.addedDate ?? ''}|${sale.shopName ?? ''}';
      grouped.putIfAbsent(key, () => []).add(sale);
    }
    return grouped;
  }

  // Get item name by ID
  String _getItemName(int? itemId) {
    if (itemId == null) return 'Unknown';
    final item = _items.firstWhere(
      (item) => item['id'] == itemId,
      orElse: () => {'name': 'Item $itemId'},
    );
    return item['name'];
  }

  void _editItem(Salesmodel sale) async {
    int? selectedItemId = sale.itemId;
    final shopController = TextEditingController(text: sale.shopName ?? '');
    final billController = TextEditingController(
      text: sale.billNo?.toString() ?? '',
    );
    final quantityController = TextEditingController(
      text: sale.quantityKg?.toString() ?? '',
    );
    final rateController = TextEditingController(
      text: sale.sellingPrice.toString(),
    );
    final amountController = TextEditingController(
      text: (sale.amount ?? (sale.sellingPrice * (sale.quantityKg ?? 0)))
          .toString(),
    );
    final dateController = TextEditingController(text: sale.addedDate ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Sale'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: billController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Bill No',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: shopController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                AbsorbPointer(
                  child: DropdownButtonFormField<int>(
                    value: selectedItemId,
                    decoration: const InputDecoration(
                      labelText: 'Item',
                      border: OutlineInputBorder(),
                    ),
                    items: _items.map((item) {
                      return DropdownMenuItem<int>(
                        value: item['id'],
                        child: Text(item['name']),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedItemId = v),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Quantity (g)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setDialogState(() {
                    final qtyGrams =
                        double.tryParse(quantityController.text) ?? 0;
                    final qtyKg = qtyGrams / 1000; // Convert grams to kg
                    final rate = double.tryParse(rateController.text) ?? 0;
                    amountController.text = (qtyKg * rate).toStringAsFixed(2);
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rateController,
                  decoration: const InputDecoration(
                    labelText: 'Selling Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setDialogState(() {
                    final qtyGrams =
                        double.tryParse(quantityController.text) ?? 0;
                    final qtyKg = qtyGrams / 1000; // Convert grams to kg
                    final rate = double.tryParse(rateController.text) ?? 0;
                    amountController.text = (qtyKg * rate).toStringAsFixed(2);
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        dateController.text =
                            '${picked.day}/${picked.month}/${picked.year}';
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedItemId == null) return;

                final updateData = {
                  'id': sale.id,
                  'bill_no': billController.text.trim(),
                  'shop_id': sale.shopId,
                  'item_id': selectedItemId!,
                  'selling_price': int.tryParse(rateController.text) ?? 0,
                  'quantity_grams': int.tryParse(quantityController.text),
                  'amount': double.tryParse(amountController.text),
                  'Vat_Number': sale.vatNumber,
                  'added_date': dateController.text,
                };

                await DatabaseHelper.instance.updateSale(sale.id!, updateData);
                Navigator.pop(context);
                await _loadStocks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sale updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteItem(Salesmodel sale) {
    final id = sale.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete: missing id'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: Text('Delete sale for ${sale.shopName ?? 'shop'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final rows = await DatabaseHelper.instance.deleteSale(id);
              Navigator.pop(context);
              if (rows > 0) {
                await _loadStocks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sale deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, List<Salesmodel>>> get _pagedGroupedSales {
    final entries = _groupedSales.entries.toList();
    final start = _currentPage * _pageSize;
    return entries.skip(start).take(_pageSize).toList();
  }

  int get _totalPages {
    final total = _groupedSales.length;
    if (total == 0) return 1;
    return ((total + _pageSize - 1) / _pageSize).floor();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page.clamp(0, _totalPages - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 26, 11, 167),
                const Color.fromARGB(255, 21, 5, 196),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Sales',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profit',
                                  style: TextStyle(
                                    color: const Color.fromARGB(244, 3, 3, 3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'RS ${profit.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by shop name, bill number',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 26, 11, 167),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Bills List
            Expanded(
              child: sales.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sales available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pagedGroupedSales.length,
                      itemBuilder: (context, index) {
                        final entry = _pagedGroupedSales[index];
                        final billKey = entry.key;
                        final billSales = entry.value;
                        final firstSale = billSales.first;
                        final isExpanded = _expandedBills.contains(billKey);

                        // Calculate totals
                        final totalAmount = billSales.fold<double>(
                          0,
                          (sum, sale) => sum + (sale.amount ?? 0),
                        );
                        final totalItems = billSales.length;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Bill Header - Always Visible
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedBills.remove(billKey);
                                    } else {
                                      _expandedBills.add(billKey);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Bill Icon
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                26,
                                                11,
                                                167,
                                              ).withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: Icon(
                                              Icons.receipt,
                                              color: const Color.fromARGB(
                                                255,
                                                26,
                                                11,
                                                167,
                                              ),
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Bill Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Bill #${firstSale.billNo ?? 'N/A'}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      firstSale.shopName ??
                                                          'Unknown Shop',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.08),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '$totalItems items',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.green[700],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 10,
                                                      color: Colors.grey[500],
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      firstSale.addedDate ??
                                                          'N/A',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),

                                                    const Spacer(),
                                                    Text(
                                                      'Total: ${totalAmount.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Expand Icon
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Colors.grey[600],
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded Items
                              if (isExpanded) ...[
                                Divider(height: 1, color: Colors.grey[300]),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      // Items Header
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Item',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: Text(
                                                'Qty',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: Text(
                                                'Rate',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                'Amount',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                'Action',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Items List
                                      ...billSales.map((sale) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  _getItemName(sale.itemId),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 50,
                                                child: Text(
                                                  '${((sale.quantityKg ?? 0) / 1000).toStringAsFixed(2)} kg',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 50,
                                                child: Text(
                                                  sale.sellingPrice.toString(),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 60,
                                                child: Text(
                                                  (sale.amount ?? 0)
                                                      .toStringAsFixed(2),
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      onTap: () =>
                                                          _editItem(sale),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.edit_outlined,
                                                          color: Colors.blue,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    InkWell(
                                                      onTap: () =>
                                                          _deleteItem(sale),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.red,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Pagination Controls
            if (sales.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _currentPage > 0
                                ? const Color.fromARGB(
                                    255,
                                    26,
                                    11,
                                    167,
                                  ).withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _currentPage > 0
                                ? () => _goToPage(_currentPage - 1)
                                : null,
                            icon: Icon(
                              Icons.chevron_left,
                              color: _currentPage > 0
                                  ? const Color.fromARGB(255, 26, 11, 167)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: _currentPage < _totalPages - 1
                                ? const Color.fromARGB(
                                    255,
                                    26,
                                    11,
                                    167,
                                  ).withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _currentPage < _totalPages - 1
                                ? () => _goToPage(_currentPage + 1)
                                : null,
                            icon: Icon(
                              Icons.chevron_right,
                              color: _currentPage < _totalPages - 1
                                  ? const Color.fromARGB(255, 26, 11, 167)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

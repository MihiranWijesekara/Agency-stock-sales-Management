import 'package:chicken_dilivery/Model/ItemModel.dart';
import 'package:chicken_dilivery/Model/StockModel.dart';
import 'package:chicken_dilivery/database/database_helper.dart';
import 'package:chicken_dilivery/pages/Item/addItem.dart';
import 'package:chicken_dilivery/pages/stock/addStock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockDisplay extends StatefulWidget {
  const StockDisplay({super.key});

  @override
  State<StockDisplay> createState() => _StockDisplayState();
}

class _StockDisplayState extends State<StockDisplay> {
  List<StockModel> stocks = [];
  List<ItemModel> _items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadStocks();
  }

  Future<void> _loadItems() async {
    try {
      final data = await DatabaseHelper.instance.getAllItems();
      setState(() => _items = data);
    } catch (_) {}
  }

  Future<void> _loadStocks() async {
    setState(() => isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getACurrentStock();
      setState(() {
        stocks = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading shops: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editStock(int index) async {
    final stock = stocks[index];

    int? selectedItemId = stock.item_id;
    final qtyController = TextEditingController(
      text: stock.quantity_grams?.toString() ?? '',
    );
    final rateController = TextEditingController(
      text: stock.stock_price.toString(),
    );
    final amountController = TextEditingController(
      text: (stock.amount ?? (stock.stock_price * (stock.quantity_grams ?? 0)))
          .toString(),
    );
    final remainController = TextEditingController(
      text: stock.remain_quantity?.toString() ?? '',
    );
    final sellingRateController = TextEditingController(
      text: stock.selling_price?.toString() ?? '',
    );
    final dateController = TextEditingController(text: stock.added_date ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Stock'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedItemId,
                  decoration: const InputDecoration(
                    labelText: 'Item',
                    border: OutlineInputBorder(),
                  ),
                  items: _items.map((item) {
                    return DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedItemId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity (Kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setDialogState(() {
                    final q = int.tryParse(qtyController.text) ?? 0;
                    final r = double.tryParse(rateController.text) ?? 0;
                    amountController.text = (q * r).toStringAsFixed(2);
                    if (remainController.text.isEmpty) {
                      remainController.text = q.toString();
                    }
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rateController,
                  decoration: const InputDecoration(
                    labelText: 'Rate',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setDialogState(() {
                    final q = int.tryParse(qtyController.text) ?? 0;
                    final r = double.tryParse(rateController.text) ?? 0;
                    amountController.text = (q * r).toStringAsFixed(2);
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
                  controller: remainController,
                  decoration: const InputDecoration(
                    labelText: 'Remain Stock',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                final updated = StockModel(
                  id: stock.id,
                  item_id: selectedItemId!,
                  stock_price:
                      int.tryParse(rateController.text) ?? stock.stock_price,
                  selling_price:
                      int.tryParse(sellingRateController.text) ??
                      stock.selling_price,
                  quantity_grams: int.tryParse(qtyController.text),
                  remain_quantity: double.tryParse(remainController.text),
                  amount: double.tryParse(amountController.text),
                  added_date: dateController.text,
                );
                await DatabaseHelper.instance.updateStock(updated);
                Navigator.pop(context);
                await _loadStocks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stock updated'),
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

  void _deleteItem(int index) {
    final stock = stocks[index];
    final id = stock.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete: missing id'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Only allow delete if remain_quantity == quantity_grams (full stock remains)
    if ((stock.remain_quantity ?? 0).toDouble() !=
        (stock.quantity_grams ?? 0).toDouble()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete: Some stock has already been used.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete ${stocks[index].item_name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final rows = await DatabaseHelper.instance.deleteStock(id);
              if (rows == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error deleting item'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              await _loadStocks();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.04;
    final cardRadius = screenWidth * 0.03;
    final iconSize = screenWidth * 0.07;
    final fontSizeTitle = screenWidth * 0.045;
    final fontSizeSubtitle = screenWidth * 0.035;
    final fontSizeSmall = screenWidth * 0.03;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.08,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
          onPressed: () {
            Navigator.pop(context);
          },
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
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: iconSize),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeTitle,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stocks.length} RECORDS FOUND',
                style: TextStyle(
                  fontSize: fontSizeSmall,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: padding),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : stocks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: screenWidth * 0.18,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: padding),
                            Text(
                              'No items available',
                              style: TextStyle(
                                fontSize: fontSizeSubtitle,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: stocks.length,
                        itemBuilder: (context, index) {
                          final stock = stocks[index];
                          return _buildStockCard(
                            stock,
                            index,
                            cardRadius,
                            iconSize,
                            fontSizeTitle,
                            fontSizeSubtitle,
                            fontSizeSmall,
                            padding,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStockPage()),
          );
          if (result == true) _loadStocks();
        },
        backgroundColor: const Color.fromARGB(255, 224, 237, 51),
        icon: Icon(Icons.add, size: iconSize),
        label: Text(
          'Add Stock',
          style: TextStyle(
            color: Color.fromARGB(255, 18, 16, 16),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: fontSizeSubtitle,
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard(
    StockModel stock,
    int index,
    double cardRadius,
    double iconSize,
    double fontSizeTitle,
    double fontSizeSubtitle,
    double fontSizeSmall,
    double padding,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: padding * 0.75),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding * 0.1,
          ),
          childrenPadding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3), // Optional: add spacing
                    Text(
                      stock.item_name ?? 'Unknown Item',
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    // Add date at the top
                    Text(
                      stock.added_date ?? '',
                      style: TextStyle(
                        fontSize: fontSizeSmall,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Weight: ',
                          style: TextStyle(
                            fontSize: fontSizeSmall,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${stock.quantity_grams != null ? (stock.quantity_grams! / 1000).toStringAsFixed(3) : '0.000'} Kg',
                          style: TextStyle(
                            fontSize: fontSizeSmall,
                            color: Colors.grey[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: padding * 0.5),
                        Text(
                          'Amount: ',
                          style: TextStyle(
                            fontSize: fontSizeSmall,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Rs ${stock.amount?.toStringAsFixed(0) ?? '0'}',
                          style: TextStyle(
                            fontSize: fontSizeSmall,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: padding * 0.3),
                    Row(
                      children: [
                        Text(
                          'Remaining Stock: ',
                          style: TextStyle(
                            fontSize: fontSizeSmall,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          // '${stock.remain_quantity?.toStringAsFixed(1) ?? '0'} Kg',
                          '${stock.remain_quantity != null ? (stock.remain_quantity! / 1000).toStringAsFixed(3) : '0.000'} Kg',
                          style: TextStyle(
                            fontSize: fontSizeSmall,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: padding * 0.5),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'QTY',
                    stock.QTY?.toString() ?? '0',
                    Icons.format_list_numbered,
                    iconSize,
                    fontSizeSmall,
                    fontSizeSubtitle,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Weight',
                    '${stock.quantity_grams != null ? (stock.quantity_grams! / 1000).toStringAsFixed(3) : '0.000'} Kg',
                    Icons.scale,
                    iconSize,
                    fontSizeSmall,
                    fontSizeSubtitle,
                  ),
                ),
              ],
            ),
            SizedBox(height: padding * 0.4),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Stock Rate',
                    'Rs ${stock.stock_price ?? 0}',
                    // sale.sellingPrice.toString(),
                    Icons.attach_money,
                    iconSize,
                    fontSizeSmall,
                    fontSizeSubtitle,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Selling Rate',
                    'Rs ${stock.selling_price ?? 0}',
                    Icons.attach_money,
                    iconSize,
                    fontSizeSmall,
                    fontSizeSubtitle,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Amount',
                    'Rs ${stock.amount?.toStringAsFixed(0) ?? '0'}',
                    Icons.attach_money,
                    iconSize,
                    fontSizeSmall,
                    fontSizeSubtitle,
                  ),
                ),
              ],
            ),
            SizedBox(height: padding * 0.4),
            _buildDetailItemWithoutIcon(
              'Remaining Stock',
              '${stock.remain_quantity != null ? (stock.remain_quantity! / 1000).toStringAsFixed(3) : '0.000'} Kg',
              fontSizeSmall,
              fontSizeSubtitle,
              padding,
            ),
            SizedBox(height: padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _editStock(index),
                  icon: Icon(Icons.edit, size: iconSize * 0.7),
                  label: Text(
                    'Edit',
                    style: TextStyle(fontSize: fontSizeSmall),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: padding * 0.5,
                    ),
                  ),
                ),
                SizedBox(width: padding * 0.5),
                OutlinedButton.icon(
                  onPressed: () => _deleteItem(index),
                  icon: Icon(Icons.delete, size: iconSize * 0.7),
                  label: Text(
                    'Delete',
                    style: TextStyle(fontSize: fontSizeSmall),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: padding * 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    double iconSize,
    double fontSizeSmall,
    double fontSizeSubtitle,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: iconSize * 0.2),
      child: Row(
        children: [
          Icon(icon, size: iconSize * 0.7, color: Colors.grey[600]),
          SizedBox(width: iconSize * 0.3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: iconSize * 0.1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSizeSubtitle,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItemWithoutIcon(
    String label,
    String value,
    double fontSizeSmall,
    double fontSizeSubtitle,
    double padding,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding * 0.2),
      child: Row(
        children: [
          SizedBox(width: padding * 1.5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: padding * 0.1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSizeSubtitle,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateYear(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('/');
    if (parts.length != 3) return date;
    return parts[2]; // year
  }

  String _formatDateDayMonth(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('/');
    if (parts.length != 3) return date;
    return '${parts[0]}/${parts[1]}'; // day/month
  }
}

import 'package:chicken_dilivery/Model/CartItemModel.dart';
import 'package:chicken_dilivery/Model/ItemModel.dart';
import 'package:chicken_dilivery/Model/RootModel.dart';
import 'package:chicken_dilivery/Model/ShopModel.dart';
import 'package:chicken_dilivery/Model/StockModel.dart';
import 'package:chicken_dilivery/Model/salesModel.dart';
import 'package:chicken_dilivery/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chicken_dilivery/bluthooth/printer_service.dart'; // Add this import

class Addsales extends StatefulWidget {
  const Addsales({super.key});

  @override
  State<Addsales> createState() => _AddsalesState();
}

class _AddsalesState extends State<Addsales> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _paymentMethods = const ['Cash', 'Check', 'Debit'];
  final _sellingRateController = TextEditingController();
  final _billNumberController = TextEditingController();
  final _vatController = TextEditingController();
  final _dateController = TextEditingController();
  final _qtyController = TextEditingController(); // <-- Add this line
  final _weightController = TextEditingController();

  DateTime? _selectedDate;
  int? _selectedItemId;
  String? _selectedPaymentMethod;

  //stock model
  List<StockModel> _stockList = [];

  // Cart items list
  List<CartItem> _cartItems = [];

  // Items state
  List<ItemModel> _items = [];
  bool _isLoadingItems = true;

  // Root + shops state
  List<RootModel> _roots = [];
  List<Shopmodel> _shops = [];
  int? _selectedRootId;
  Shopmodel? _selectedShop;
  bool _isLoadingRoots = true;
  bool _isLoadingShops = true;
  bool _isGeneratingBillNumber = true;

  @override
  void initState() {
    super.initState();
    _loadStock();
    _loadItems();
    _loadRoots();
    _loadShops();
    _generateBillNumber();
    _selectedDate = DateTime.now();
    _dateController.text =
        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
  }

  @override
  void dispose() {
    _sellingRateController.dispose();
    _billNumberController.dispose();
    _vatController.dispose();
    _dateController.dispose();
    _qtyController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final items = await DatabaseHelper.instance.getAllItems();
      setState(() {
        _items = items;
        _isLoadingItems = false;
      });
    } catch (e) {
      setState(() => _isLoadingItems = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading items: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadRoots() async {
    try {
      final roots = await DatabaseHelper.instance.getAllRoots();
      setState(() {
        _roots = roots;
        _isLoadingRoots = false;
      });
    } catch (e) {
      setState(() => _isLoadingRoots = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading roots: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadStock() async {
    try {
      final now = DateTime.now();
      final stock = await DatabaseHelper.instance.getStockByMonthAndYear(
        now.month,
        now.year,
      );
      if (mounted) {
        setState(() {
          _stockList = stock;
          _isLoadingRoots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRoots = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading roots: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadShops() async {
    try {
      final shops = await DatabaseHelper.instance.getAllShops();
      setState(() {
        _shops = shops;
        _isLoadingShops = false;
      });
    } catch (e) {
      setState(() => _isLoadingShops = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading shops: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _onItemSelected(int? itemId) {
    if (itemId == null) return;
    final stock = _getStockForItem(itemId);
    setState(() {
      _selectedItemId = itemId;
      _sellingRateController.text = (stock?.selling_price.toDouble() ?? 0)
          .toStringAsFixed(2);
    });
  }

  Future<void> _generateBillNumber() async {
    try {
      final billNo = await DatabaseHelper.instance.getNextBillNumber();
      setState(() {
        _billNumberController.text = billNo;
        _isGeneratingBillNumber = false;
      });
    } catch (e) {
      setState(() => _isGeneratingBillNumber = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating bill number: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addToCart() {
    debugPrint('--- _addToCart called ---');
    debugPrint('Selected item id: [32m$_selectedItemId[0m');
    debugPrint('Selling rate: [32m${_sellingRateController.text}[0m');
    debugPrint('Weight: [32m${_weightController.text}[0m');
    if (_selectedItemId == null) {
      debugPrint('No item selected.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_sellingRateController.text.isEmpty || _weightController.text.isEmpty) {
      debugPrint('Selling rate or weight is empty.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter selling price and weight'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final weightText = _weightController.text.trim();
    final weightPattern = RegExp(r'^\d+(\.\d{1,3})?$');
    if (!weightPattern.hasMatch(weightText)) {
      debugPrint('Invalid weight format: $weightText');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter weight like 2.500 (kg.gram)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final parts = weightText.split('.');
    final kg = int.tryParse(parts[0]) ?? 0;
    final gramsText = parts.length > 1 ? parts[1].padRight(3, '0') : '000';
    final gram = int.tryParse(gramsText) ?? 0;
    final weight = kg + (gram / 1000);

    debugPrint('Parsed kg: $kg, gram: $gram, total weight: $weight');
    if (weight <= 0) {
      debugPrint('Weight <= 0');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight greater than 0'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // Set the weightController for compatibility (if needed elsewhere)

    final stock = _getStockForItem(_selectedItemId!);
    final selectedItem = _items.firstWhere(
      (item) => item.id == _selectedItemId,
    );
    final sellingPrice = double.tryParse(_sellingRateController.text) ?? 0;
    final originalPrice = stock?.selling_price.toDouble() ?? sellingPrice;
    final amount = sellingPrice * weight;
    final discount = (originalPrice > sellingPrice)
        ? (originalPrice - sellingPrice) * weight
        : 0.0;

    debugPrint(
      'originalPrice: $originalPrice, sellingPrice: $sellingPrice, amount: $amount, discount: $discount',
    );

    setState(() {
      _cartItems.add(
        CartItem(
          itemId: _selectedItemId!,
          itemName: selectedItem.name,
          originalPrice: originalPrice,
          sellingPrice: sellingPrice,
          weight: weight,
          amount: amount,
          discount: discount,
        ),
      );

      // Clear fields
      _selectedItemId = null;
      _sellingRateController.clear();
      _weightController.clear();
    });

    debugPrint('Cart items count: ${_cartItems.length}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedItem.name} added to cart'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateCartItem(int index, double newWeight) {
    setState(() {
      _cartItems[index].weight = newWeight;
      _cartItems[index].amount = _cartItems[index].sellingPrice * newWeight;
    });
  }

  double get _totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalDiscount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.discount);
  }

  Future<void> _saveAllSales() async {
    debugPrint('--- _saveAllSales called ---');
    debugPrint('Cart items: ${_cartItems.length}');
    debugPrint('Selected shop: $_selectedShop');
    if (_cartItems.isEmpty) {
      debugPrint('Cart is empty.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty. Add items first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedShop == null) {
      debugPrint('No shop selected.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a shop'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show dialog to ask if user wants to print receipt
    final bool? shouldPrint = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Print Receipt?'),
          content: const Text(
            'Do you want to print the receipt for this sale?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 26, 11, 167),
              ),
              child: const Text('Print'),
            ),
          ],
        );
      },
    );

    // User cancelled the dialog
    if (shouldPrint == null) {
      debugPrint('User cancelled print dialog.');
      return;
    }

    try {
      final billNumber = _billNumberController.text;
      final date = _dateController.text;
      final vatNumber = _vatController.text;
      final paymentMethod = _selectedPaymentMethod;
      if (paymentMethod == null || paymentMethod.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a payment method'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      debugPrint(
        'Saving sales: billNo=$billNumber, date=$date, vat=$vatNumber, paymentMethod=$paymentMethod',
      );
      for (var cartItem in _cartItems) {
        final int qtyGrams = (cartItem.weight * 1000)
            .round(); // ✅ convert kg -> grams

        if (qtyGrams <= 0) {
          throw Exception('Invalid quantity (grams). Check KG/Gram inputs.');
        }

        final newSales = Salesmodel(
          billNo: billNumber,
          shopId: _selectedShop!.id,
          itemId: cartItem.itemId,

          // store as int if your DB column is int (price per KG)
          sellingPrice: cartItem.sellingPrice.toInt(),

          // ❌ don't do this: cartItem.weight.toInt()
          // ✅ instead pass grams through map (see below)
          quantityKg: cartItem.weight
              .toInt(), // convert double to int for quantityKg

          amount: cartItem.amount,
          vatNumber: vatNumber,
          paymentMethod: paymentMethod,
          addedDate: date,
          qty: int.tryParse(_qtyController.text),
        );

        final saleMap = newSales.toMap();

        // ✅ this is what insertSaleFIFO expects
        saleMap['quantity_grams'] = qtyGrams;

        // ✅ make sure these keys match your DB columns
        // If your Sales table expects item_id / selling_price, ensure these exist:
        saleMap['item_id'] = cartItem.itemId;
        saleMap['selling_price'] = cartItem.sellingPrice.toInt();
        saleMap['PaymentMethod'] = paymentMethod;

        await DatabaseHelper.instance.insertSaleFIFO(saleMap);
      }

      // Print receipt only if user chose to print
      if (shouldPrint) {
        debugPrint('Printing receipt...');
        await PrinterService.printReceipt(
          shopName: _selectedShop!.Shopname,
          billNo: billNumber,
          date: date,
          cartItems: _cartItems,
          totalAmount: _totalAmount,
          rootName: _selectedRootId != null
              ? _roots.firstWhere((root) => root.id == _selectedRootId!).name
              : '',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shouldPrint
                ? 'Sales saved and bill printed successfully!'
                : 'Sales saved successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear cart and reset
      setState(() {
        _cartItems.clear();
        _selectedShop = null;
        _selectedRootId = null;
        _vatController.clear();
        _qtyController.clear();
      });

      // Generate new bill number for next sale
      debugPrint('Generating new bill number...');
      _generateBillNumber();
    } catch (e) {
      debugPrint('Error saving sales: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving sales: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  StockModel? _getStockForItem(int itemId) {
    try {
      return _stockList.lastWhere((s) => s.item_id == itemId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color.fromARGB(255, 26, 11, 167),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Sales',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Info Section
            _buildSectionHeader('Bill Information'),
            const SizedBox(height: 10),
            _buildBillNumberField(),
            const SizedBox(height: 10),
            _buildDateField(),
            const SizedBox(height: 18),

            // Shop Selection Section
            _buildSectionHeader('Shop Details'),
            const SizedBox(height: 10),
            _buildRootField(),
            const SizedBox(height: 10),
            _buildShopField(),
            const SizedBox(height: 10),
            _buildPaymentMethodField(),
            const SizedBox(height: 10),
            // _buildVatField(),
            // const SizedBox(height: 18),

            // Item Entry Section
            _buildSectionHeader('Add Items'),
            const SizedBox(height: 10),
            _buildItemField(),
            const SizedBox(height: 10),
            _buildSellingPriceField(),
            const SizedBox(height: 10),
            _buildWeightField(),
            const SizedBox(height: 10),
            _buildQTYField(),
            const SizedBox(height: 1),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart, size: 19),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 26, 11, 167),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cart Summary Section
            _buildSectionHeader('Cart'),
            const SizedBox(height: 10),
            _cartItems.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Cart is empty',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) => _buildCartItem(index),
                  ),
            const SizedBox(height: 20),

            // Total and Save Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'RS ${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 26, 11, 167),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Discount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'RS ${_totalDiscount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveAllSales,
                      icon: const Icon(Icons.save, size: 20), // smaller icon
                      label: const Text(
                        'Complete Sale',
                        style: TextStyle(
                          fontSize: 16, // reduced font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ), // reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 26, 11, 167),
      ),
    );
  }

  Widget _buildBillNumberField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill No.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _isGeneratingBillNumber
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : TextFormField(
                    controller: _billNumberController,
                    readOnly: true,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRootField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Root',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _selectedRootId,
              items: _roots
                  .map(
                    (r) =>
                        DropdownMenuItem<int>(value: r.id, child: Text(r.name)),
                  )
                  .toList(),
              decoration: InputDecoration(
                hintText: 'Select root',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {
                  _selectedRootId = val;
                  _selectedShop = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Name',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Autocomplete<Shopmodel>(
              displayStringForOption: (s) => s.Shopname,
              optionsBuilder: (TextEditingValue text) {
                if (_selectedRootId == null)
                  return const Iterable<Shopmodel>.empty();
                final query = text.text.toLowerCase();
                return _shops.where((shop) {
                  final matchesRoot = shop.rootId == _selectedRootId;
                  final matchesQuery =
                      query.isEmpty ||
                      shop.Shopname.toLowerCase().contains(query);
                  return matchesRoot && matchesQuery;
                });
              },
              onSelected: (shop) {
                setState(() => _selectedShop = shop);
              },
              fieldViewBuilder: (context, textController, focusNode, onSubmit) {
                return TextFormField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: _selectedRootId == null
                        ? 'Select root first'
                        : 'Search shop name',
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  enabled: _selectedRootId != null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              items: _paymentMethods
                  .map(
                    (method) => DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                hintText: 'Select payment method',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onChanged: (val) {
                setState(() {
                  _selectedPaymentMethod = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildVatField() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(8),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.08),
  //           spreadRadius: 0,
  //           blurRadius: 3,
  //           offset: const Offset(0, 1),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(12.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             'VAT Number',
  //             style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  //           ),
  //           const SizedBox(height: 6),
  //           TextFormField(
  //             controller: _vatController,
  //             decoration: InputDecoration(
  //               hintText: 'Enter VAT number',
  //               filled: true,
  //               fillColor: const Color(0xFFF5F7FA),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(6),
  //                 borderSide: const BorderSide(color: Colors.black),
  //               ),
  //               contentPadding: const EdgeInsets.symmetric(
  //                 horizontal: 12,
  //                 vertical: 10,
  //               ),
  //               isDense: true,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildItemField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item Name',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _selectedItemId,
              onChanged: _onItemSelected,
              decoration: InputDecoration(
                hintText: 'Select Item',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              items: _items
                  .map(
                    (item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellingPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price (RS/kg)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _sellingRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: 'RS ',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weight',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(fontSize: 14),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(
                hintText: '2.500',
                suffixText: 'kg',
                helperText: 'Format: kg.gram (e.g. 2.500 = 2kg 500g)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter weight';
                }
                final valid = RegExp(
                  r'^\d+(\.\d{1,3})?$',
                ).hasMatch(value.trim());
                if (!valid) {
                  return 'Use 2.500 format';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQTYField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QTY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: 'qty',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8), // less margin
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // smaller radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(8), // less padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 13, // reduced font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ), // smaller icon
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _removeFromCart(index),
                ),
              ],
            ),
            const SizedBox(height: 4), // less spacing
            Row(
              children: [
                Text(
                  'RS ${item.sellingPrice.toStringAsFixed(2)}/kg',
                  style: TextStyle(
                    fontSize: 11, // reduced font size
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 10), // less spacing
                Text(
                  '× ${item.weight.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontSize: 11, // reduced font size
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4), // less spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RS ${item.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13, // reduced font size
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 26, 11, 167),
                  ),
                ),
                SizedBox(
                  width: 80, // reduced width
                  child: TextFormField(
                    initialValue: item.weight.toStringAsFixed(2),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 11), // reduced font size
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      labelStyle: const TextStyle(fontSize: 11),
                      suffixText: 'kg',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final newWeight = double.tryParse(value);
                      if (newWeight != null && newWeight > 0) {
                        _updateCartItem(index, newWeight);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

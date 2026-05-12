import 'package:chicken_dilivery/Model/ItemModel.dart';
import 'package:chicken_dilivery/Model/RootModel.dart';
import 'package:chicken_dilivery/Model/ShopModel.dart';
import 'package:chicken_dilivery/Model/StockModel.dart';
import 'package:chicken_dilivery/pages/Report/report.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chicken_delivery.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = kIsWeb ? filePath : join(await getDatabasesPath(), filePath);

    return await openDatabase(
      path,
      version: 12, // bump version to apply Sales.sellPacket migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        unit TEXT NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE roots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        PaymentMethod TEXT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE shops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_name TEXT NOT NULL,
        root_id INTEGER,
        FOREIGN KEY (root_id) REFERENCES roots (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Stock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        stock_price INTEGER NOT NULL,
        selling_price INTEGER NOT NULL,
        quantity_grams  INTEGER,           -- Total stock in grams
        remain_quantity INTEGER,           -- Remaining stock in grams
        numberofpacks INTEGER,                -- NEW COLUMN for number of packs
        remainingNumberOfPack INTEGER,     -- Remaining number of packs
        amount REAL DEFAULT 0,             -- NEW COLUMN
        added_date TEXT,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_no TEXT NOT NULL,
        shop_id INTEGER,
        item_id INTEGER NOT NULL,
        selling_price INTEGER NOT NULL,
        quantity_grams INTEGER,
        amount REAL DEFAULT 0,          
        Vat_Number TEXT,
        PaymentMethod TEXT,
        sellPacket INTEGER,
        is_checked INTEGER DEFAULT 0,
        QTY INTEGER,
        added_date TEXT,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE SET NULL,
        FOREIGN KEY (shop_id) REFERENCES shops (id) ON DELETE SET NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 9) {
      final itemColumns = await db.rawQuery('PRAGMA table_info(items)');
      final hasUnit = itemColumns.any((c) => c['name'] == 'unit');
      if (!hasUnit) {
        await db.execute(
          "ALTER TABLE items ADD COLUMN unit TEXT NOT NULL DEFAULT ''",
        );
      }
    }

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS roots (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shops (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          shop_name TEXT NOT NULL,
          root_id INTEGER,
          FOREIGN KEY (root_id) REFERENCES roots (id) ON DELETE SET NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS Stock (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_id INTEGER NOT NULL,
          stock_price INTEGER NOT NULL,
          selling_price INTEGER NOT NULL,
          quantity_grams INTEGER,
          remain_quantity INTEGER,
          amount REAL DEFAULT 0,
          QTY REAL,
          added_date TEXT,
          FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE SET NULL
        )
      ''');
    }

    // Migration to add amount column
    if (oldVersion < 5) {
      final columns = await db.rawQuery('PRAGMA table_info(Stock)');
      final hasAmount = columns.any((c) => c['name'] == 'amount');
      if (!hasAmount) {
        await db.execute('ALTER TABLE Stock ADD COLUMN amount REAL DEFAULT 0');
      }
    }

    // Add Sales table for existing users
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS Sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bill_no TEXT NOT NULL,
          shop_id INTEGER,
          item_id INTEGER NOT NULL,
          selling_price INTEGER NOT NULL,
          quantity_grams INTEGER,
          amount REAL DEFAULT 0,
          Vat_Number TEXT,
          PaymentMethod TEXT,
          sellPacket INTEGER,
          is_checked INTEGER DEFAULT 0,
          added_date TEXT,
          FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE SET NULL,
          FOREIGN KEY (shop_id) REFERENCES shops (id) ON DELETE SET NULL
        )
      ''');
    }

    if (oldVersion < 7) {
      final salesColumns = await db.rawQuery('PRAGMA table_info(Sales)');
      final hasPaymentMethod = salesColumns.any(
        (c) => c['name'] == 'PaymentMethod',
      );
      if (!hasPaymentMethod) {
        await db.execute('ALTER TABLE Sales ADD COLUMN PaymentMethod TEXT');
      }
    }

    if (oldVersion < 8) {
      final salesColumns = await db.rawQuery('PRAGMA table_info(Sales)');
      final hasPaymentMethod = salesColumns.any(
        (c) => c['name'] == 'PaymentMethod',
      );
      if (!hasPaymentMethod) {
        await db.execute('ALTER TABLE Sales ADD COLUMN PaymentMethod TEXT');
      }
    }

    final salesColumns = await db.rawQuery('PRAGMA table_info(Sales)');
    final hasIsChecked = salesColumns.any((c) => c['name'] == 'is_checked');
    if (!hasIsChecked) {
      await db.execute(
        'ALTER TABLE Sales ADD COLUMN is_checked INTEGER DEFAULT 0',
      );
    }

    if (oldVersion < 10) {
      final stockColumns = await db.rawQuery('PRAGMA table_info(Stock)');
      final hasNumberOfPacks = stockColumns.any(
        (c) => c['name'] == 'numberofpacks',
      );
      if (!hasNumberOfPacks) {
        await db.execute('ALTER TABLE Stock ADD COLUMN numberofpacks INTEGER');
      }
    }

    if (oldVersion < 11) {
      final stockColumns = await db.rawQuery('PRAGMA table_info(Stock)');
      final hasRemainingNumberOfPack = stockColumns.any(
        (c) => c['name'] == 'remainingNumberOfPack',
      );
      if (!hasRemainingNumberOfPack) {
        await db.execute(
          'ALTER TABLE Stock ADD COLUMN remainingNumberOfPack INTEGER',
        );
      }
    }

    if (oldVersion < 12) {
      final salesColumns = await db.rawQuery('PRAGMA table_info(Sales)');
      final hasSellPacket = salesColumns.any((c) => c['name'] == 'sellPacket');
      if (!hasSellPacket) {
        await db.execute('ALTER TABLE Sales ADD COLUMN sellPacket INTEGER');
      }
    }
  }

  // Debug method to check if table exists
  Future<bool> doesTableExist(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  // Debug method to get all table names
  Future<List<String>> getAllTableNames() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    return result.map((map) => map['name'] as String).toList();
  }

  // Insert item
  Future<int> insertItem(ItemModel item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  // Insert root
  Future<int> insertRoot(RootModel root) async {
    final db = await database;
    return await db.insert('roots', root.toMap());
  }

  // Insert shop
  Future<int> insertShop(Shopmodel shop) async {
    final db = await database;
    return await db.insert('shops', shop.toMap());
  }

  // Insert stock
  Future<int> insertStock(StockModel stock) async {
    final db = await database;
    return await db.insert('Stock', stock.toMap());
  }

  Future<int> insertSaleFIFO(Map<String, dynamic> sale) async {
    final db = await database;

    final int itemId = sale['item_id'] as int;
    num qtyToSell = (sale['quantity_grams'] ?? 0) as num;
    num qtyToSellInPacks = (sale['sellPacket'] ?? 0) as num;

    if (qtyToSell <= 0 && qtyToSellInPacks <= 0) {
      throw Exception('Quantity must be greater than 0');
    }

    return await db.transaction<int>((txn) async {
      if (qtyToSell > 0) {
        final stockList = await txn.query(
          'Stock',
          where: 'item_id = ? AND COALESCE(remain_quantity, 0) > 0',
          whereArgs: [itemId],
          orderBy: 'added_date ASC, id ASC',
        );

        for (var stock in stockList) {
          final double remainQty = ((stock['remain_quantity'] ?? 0) as num)
              .toDouble();

          if (remainQty >= qtyToSell) {
            final newRemain = remainQty - qtyToSell;

            await txn.update(
              'Stock',
              {'remain_quantity': newRemain},
              where: 'id = ?',
              whereArgs: [stock['id']],
            );

            qtyToSell = 0;
            break;
          } else {
            qtyToSell -= remainQty;

            await txn.update(
              'Stock',
              {'remain_quantity': 0},
              where: 'id = ?',
              whereArgs: [stock['id']],
            );
          }
        }

        if (qtyToSell > 0) {
          throw Exception('Insufficient stock for item ID $itemId');
        }
      }

      if (qtyToSellInPacks > 0) {
        final stockList = await txn.query(
          'Stock',
          where: 'item_id = ? AND COALESCE(remainingNumberOfPack, 0) > 0',
          whereArgs: [itemId],
          orderBy: 'added_date ASC, id ASC',
        );

        for (var stock in stockList) {
          final double remainPacks =
              ((stock['remainingNumberOfPack'] ?? 0) as num).toDouble();

          if (remainPacks >= qtyToSellInPacks) {
            final newRemain = remainPacks - qtyToSellInPacks;

            await txn.update(
              'Stock',
              {
                'remainingNumberOfPack': newRemain,
                'remain_quantity': newRemain,
              },
              where: 'id = ?',
              whereArgs: [stock['id']],
            );

            qtyToSellInPacks = 0;
            break;
          } else {
            qtyToSellInPacks -= remainPacks;

            await txn.update(
              'Stock',
              {'remainingNumberOfPack': 0, 'remain_quantity': 0},
              where: 'id = ?',
              whereArgs: [stock['id']],
            );
          }
        }

        if (qtyToSellInPacks > 0) {
          throw Exception('Insufficient packet stock for item ID $itemId');
        }
      }

      // ✅ correct amount: grams -> kg * pricePerKg
      final num grams = (sale['quantity_grams'] ?? 0) as num;
      final num pricePerKg = (sale['selling_price'] ?? 0) as num;
      sale['amount'] = (grams / 1000.0) * pricePerKg;

      // ✅ prevent schema errors
      sale.remove('quantity_kg');
      sale.remove('id');

      final allowed = <String>{
        'bill_no',
        'shop_id',
        'item_id',
        'selling_price',
        'quantity_grams',
        'amount',
        'Vat_Number',
        'PaymentMethod',
        'sellPacket',
        'is_checked',
        'added_date',
        'QTY',
      };
      sale.removeWhere((k, v) => !allowed.contains(k));

      final saleId = await txn.insert('Sales', sale);
      return saleId;
    });
  }

  // Get all items
  Future<List<ItemModel>> getAllItems() async {
    final db = await database;
    final result = await db.query('items', orderBy: 'id ASC');
    return result.map((map) => ItemModel.fromMap(map)).toList();
  }

  // Get all roots
  Future<List<RootModel>> getAllRoots() async {
    final db = await database;
    final result = await db.query('roots', orderBy: 'id ASC');
    return result.map((map) => RootModel.fromMap(map)).toList();
  }

  // Get all shops
  Future<List<Shopmodel>> getAllShops() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT shops.*, roots.name as root_name
      FROM shops
      LEFT JOIN roots ON shops.root_id = roots.id
      ORDER BY shops.id ASC
    ''');
    return result.map((map) => Shopmodel.fromMap(map)).toList();
  }

  // Get all stock
  Future<List<StockModel>> getStockByMonthAndYear(int month, int year) async {
    final db = await database;
    final paddedMonth = month.toString().padLeft(2, '0');
    final yyyy = year.toString();

    final result = await db.rawQuery(
      '''
      SELECT Stock.*, items.name as item_name
      FROM Stock
      LEFT JOIN items ON Stock.item_id = items.id
     WHERE added_date LIKE ? OR added_date LIKE ?
    ORDER BY Stock.id ASC
  ''',
      [
        '%/$paddedMonth/$yyyy%', // DD/MM/YYYY (01/01/2026)
        '%/$month/$yyyy%', // D/M/YYYY (1/1/2026)
      ],
    );

    return result.map((m) => StockModel.fromMap(m)).toList();
  }

  // Get all available stock (remain_quantity > 0)
  Future<List<StockModel>> getACurrentStock() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT Stock.*, items.name as item_name
      FROM Stock
      LEFT JOIN items ON Stock.item_id = items.id
      WHERE COALESCE(Stock.remain_quantity, 0) > 0
      ORDER BY Stock.id ASC
    ''');
    return result.map((m) => StockModel.fromMap(m)).toList();
  }

  // Get all sales
  Future<List<Map<String, dynamic>>> getSalesByMonthAndYear(
    int month,
    int year,
  ) async {
    final db = await database;
    final paddedMonth = month.toString().padLeft(2, '0');
    final yyyy = year.toString();

    return await db.rawQuery(
      '''
    SELECT Sales.*, items.name as item_name, shops.shop_name
    FROM Sales
    LEFT JOIN items ON Sales.item_id = items.id
    LEFT JOIN shops ON Sales.shop_id = shops.id
    WHERE (added_date LIKE ? OR added_date LIKE ?)
    ORDER BY Sales.id DESC
    ''',
      [
        '%/$paddedMonth/$yyyy%', // DD/MM/YYYY (01/01/2026)
        '%/$month/$yyyy%', // D/M/YYYY (1/1/2026)
      ],
    );
  }

  //Today sales
  Future<List<Map<String, dynamic>>> getTodaySales() async {
    final db = await database;
    final today = DateTime.now();
    // Change to DD/MM/YYYY format to match your database
    final todayString = '${today.day}/${today.month}/${today.year}';

    print('🔍 Querying for date: $todayString'); // Debug

    final result = await db.rawQuery(
      '''
    SELECT Sales.*, items.name as item_name, shops.shop_name
    FROM Sales
    LEFT JOIN items ON Sales.item_id = items.id
    LEFT JOIN shops ON Sales.shop_id = shops.id
    WHERE Sales.added_date = ?
    ORDER BY Sales.id DESC
  ''',
      [todayString],
    );

    print('✅ Found ${result.length} records'); // Debug
    return result;
  }

  //Get sales Payment Methods (Check and Debit only)
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final db = await database;

    final result = await db.rawQuery(''' 
    SELECT Sales.*, items.name as item_name, shops.shop_name
    FROM Sales 
    LEFT JOIN items ON Sales.item_id = items.id
    LEFT JOIN shops ON Sales.shop_id = shops.id
    WHERE Sales.PaymentMethod IN ('Check', 'Debit')
      AND COALESCE(Sales.is_checked, 0) = 0
    ORDER BY Sales.id DESC
  ''');

    print('✅ Found ${result.length} records'); // Debug
    return result;
  }

  //Weekly sales
  Future<List<Map<String, dynamic>>> getWeeklySales() async {
    final db = await database;
    final now = DateTime.now();

    // Get the start of the week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Generate all dates in the current week as D/M/YYYY (no leading zeros)
    List<String> weekDates = [];
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      weekDates.add('${date.day}/${date.month}/${date.year}');
    }

    print('🗓️ Week dates: $weekDates'); // Debug

    // Create placeholders for the IN clause
    final placeholders = List.filled(weekDates.length, '?').join(',');

    final result = await db.rawQuery('''
    SELECT Sales.*, items.name as item_name, shops.shop_name
    FROM Sales
    LEFT JOIN items ON Sales.item_id = items.id
    LEFT JOIN shops ON Sales.shop_id = shops.id
    WHERE Sales.added_date IN ($placeholders)
    ORDER BY Sales.id DESC
  ''', weekDates);

    print('✅ Found ${result.length} weekly records'); // Debug
    return result;
  }

  //Monthly sales
  Future<List<Map<String, dynamic>>> getMonthlySales() async {
    final db = await database;
    final now = DateTime.now();

    // Get the first day of the current month
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // Get the last day of the current month
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Generate all dates in the current month
    List<String> monthDates = [];
    for (int i = 0; i < lastDayOfMonth.day; i++) {
      final date = firstDayOfMonth.add(Duration(days: i));
      monthDates.add('${date.day}/${date.month}/${date.year}');
    }

    print('📆 Month dates: ${monthDates.length} dates generated'); // Debug

    // Create placeholders for the IN clause
    final placeholders = List.filled(monthDates.length, '?').join(',');

    final result = await db.rawQuery('''
    SELECT Sales.*, items.name as item_name, shops.shop_name
    FROM Sales
    LEFT JOIN items ON Sales.item_id = items.id
    LEFT JOIN shops ON Sales.shop_id = shops.id
    WHERE Sales.added_date IN ($placeholders)
    ORDER BY Sales.id DESC
  ''', monthDates);

    print('✅ Found ${result.length} monthly records'); // Debug
    return result;
  }

  //Daily total Profit (Correct)
  Future<double> getTodayTotalProfit() async {
    final db = await database;
    final today = DateTime.now();
    final padded =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    final unpadded = '${today.day}/${today.month}/${today.year}';
    // For each sale today, get the latest stock_price for the item
    final rows = await db.rawQuery(
      '''
      SELECT S.selling_price, S.quantity_grams AS quantity_grams, St.stock_price
      FROM Sales S
      LEFT JOIN (
        SELECT item_id, MAX(id) as max_stock_id
        FROM Stock
        GROUP BY item_id
      ) latestStock ON S.item_id = latestStock.item_id
      LEFT JOIN Stock St ON St.id = latestStock.max_stock_id
      WHERE S.added_date = ? OR S.added_date = ?
    ''',
      [padded, unpadded],
    );
    double totalProfit = 0.0;
    for (final row in rows) {
      final sellingPrice = (row['selling_price'] ?? 0) as num;
      final stockPrice = (row['stock_price'] ?? 0) as num;
      final qtyGrams = (row['quantity_grams'] ?? 0) as num;
      final profit = (sellingPrice - stockPrice) * (qtyGrams / 1000.0);
      totalProfit += profit;
    }
    return totalProfit;
  }

  // Current Week total profit
  Future<double> getWeeklyTotalProfit() async {
    final db = await database;
    final now = DateTime.now();
    // Get the start of the week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Generate all dates in the current week as both D/M/YYYY and DD/MM/YYYY
    final Set<String> weekDates = <String>{};
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      weekDates.add('${date.day}/${date.month}/${date.year}');
      weekDates.add(
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      );
    }
    // Create placeholders for the IN clause
    final placeholders = List.filled(weekDates.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT S.selling_price, S.quantity_grams AS quantity_grams, St.stock_price
      FROM Sales S
      LEFT JOIN (
        SELECT item_id, MAX(id) as max_stock_id
        FROM Stock
        GROUP BY item_id
      ) latestStock ON S.item_id = latestStock.item_id
      LEFT JOIN Stock St ON St.id = latestStock.max_stock_id
      WHERE S.added_date IN ($placeholders)
    ''', weekDates.toList());
    double totalProfit = 0.0;
    for (final row in rows) {
      final sellingPrice = (row['selling_price'] ?? 0) as num;
      final stockPrice = (row['stock_price'] ?? 0) as num;
      final qtyGrams = (row['quantity_grams'] ?? 0) as num;
      final profit = (sellingPrice - stockPrice) * (qtyGrams / 1000.0);
      totalProfit += profit;
    }
    return totalProfit;
  }

  //Current Month Total Profit
  Future<double> getMonthlyTotalProfit() async {
    final db = await database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // Get the last day of the current month
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Generate all dates in the current month as both D/M/YYYY and DD/MM/YYYY
    final Set<String> monthDates = <String>{};
    for (int i = 0; i < lastDayOfMonth.day; i++) {
      final date = firstDayOfMonth.add(Duration(days: i));
      monthDates.add('${date.day}/${date.month}/${date.year}');
      monthDates.add(
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
      );
    }

    // Create placeholders for the IN clause
    final placeholders = List.filled(monthDates.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT S.selling_price, S.quantity_grams AS quantity_grams, St.stock_price
      FROM Sales S
      LEFT JOIN (
        SELECT item_id, MAX(id) as max_stock_id
        FROM Stock
        GROUP BY item_id
      ) latestStock ON S.item_id = latestStock.item_id
      LEFT JOIN Stock St ON St.id = latestStock.max_stock_id
      WHERE S.added_date IN ($placeholders)
    ''', monthDates.toList());
    double totalProfit = 0.0;
    for (final row in rows) {
      final sellingPrice = (row['selling_price'] ?? 0) as num;
      final stockPrice = (row['stock_price'] ?? 0) as num;
      final qtyGrams = (row['quantity_grams'] ?? 0) as num;
      final profit = (sellingPrice - stockPrice) * (qtyGrams / 1000.0);
      totalProfit += profit;
    }
    return totalProfit;
  }

  //Today Sales Amount Total Price
  Future<double> getTodaySalesTotalAmount() async {
    final db = await database;
    final now = DateTime.now();
    final padded =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final unpadded = '${now.day}/${now.month}/${now.year}';
    final rows = await db.rawQuery(
      '''
    SELECT IFNULL(SUM(amount),0) AS total_amount
    FROM Sales
    WHERE added_date = ? OR added_date = ?
  ''',
      [padded, unpadded],
    );
    return (rows.first['total_amount'] as num).toDouble();
  }

  //Yesterday Sales Amount Total Price
  Future<double> getYesterdaySalesTotalAmount() async {
    final db = await database;
    final y = DateTime.now().subtract(const Duration(days: 1));
    final padded =
        '${y.day.toString().padLeft(2, '0')}/${y.month.toString().padLeft(2, '0')}/${y.year}';
    final unpadded = '${y.day}/${y.month}/${y.year}';
    final rows = await db.rawQuery(
      '''
    SELECT IFNULL(SUM(amount),0) AS total_amount
    FROM Sales
    WHERE added_date = ? OR added_date = ?
  ''',
      [padded, unpadded],
    );
    return (rows.first['total_amount'] as num).toDouble();
  }

  // Update item
  Future<int> updateItem(ItemModel item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Update root
  Future<int> updateRoot(RootModel root) async {
    final db = await database;
    return await db.update(
      'roots',
      root.toMap(),
      where: 'id = ?',
      whereArgs: [root.id],
    );
  }

  // Update shop
  Future<int> updateShop(Shopmodel shop) async {
    final db = await database;
    return await db.update(
      'shops',
      shop.toMap(),
      where: 'id = ?',
      whereArgs: [shop.id],
    );
  }

  // Update stock
  Future<int> updateStock(StockModel stock) async {
    final db = await database;
    return await db.update(
      'Stock',
      stock.toMap(),
      where: 'id = ?',
      whereArgs: [stock.id],
    );
  }

  // Update sale
  Future<int> updateSale(int id, Map<String, dynamic> sale) async {
    final db = await database;
    return await db.update('Sales', sale, where: 'id = ?', whereArgs: [id]);
  }

  // Delete item
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // Delete root
  Future<int> deleteRoot(int id) async {
    final db = await database;
    return await db.delete('roots', where: 'id = ?', whereArgs: [id]);
  }

  // Delete shop
  Future<int> deleteShop(int id) async {
    final db = await database;
    return await db.delete('shops', where: 'id = ?', whereArgs: [id]);
  }

  // Delete stock
  Future<int> deleteStock(int id) async {
    final db = await database;
    return await db.delete('Stock', where: 'id = ?', whereArgs: [id]);
  }

  // Delete sale and restore stock
  Future<int> deleteSale(int id) async {
    final db = await database;
    return await db.transaction<int>((txn) async {
      // Get the sale to know how much stock to restore
      final saleList = await txn.query(
        'Sales',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (saleList.isEmpty) return 0;

      final sale = saleList.first;
      final itemId = sale['item_id'] as int;
      final quantityToRestore = (sale['quantity_grams'] ?? 0) as num;

      // Restore stock in reverse FIFO order (newest stock first)
      if (quantityToRestore > 0) {
        final stockList = await txn.query(
          'Stock',
          where: 'item_id = ?',
          whereArgs: [itemId],
          orderBy: 'added_date DESC, id DESC',
        );

        num remainingToRestore = quantityToRestore.toDouble();

        for (var stock in stockList) {
          if (remainingToRestore <= 0) break;

          final currentRemain = ((stock['remain_quantity'] ?? 0) as num)
              .toDouble();
          final totalQty = ((stock['quantity_grams'] ?? 0) as num).toDouble();
          final canRestore = totalQty - currentRemain; // How much was sold

          if (canRestore > 0) {
            final restoreAmount = remainingToRestore > canRestore
                ? canRestore
                : remainingToRestore;

            final newRemain = currentRemain + restoreAmount;

            await txn.update(
              'Stock',
              {'remain_quantity': newRemain},
              where: 'id = ?',
              whereArgs: [stock['id']],
            );

            remainingToRestore -= restoreAmount;
          }
        }
      }

      // Delete the sale
      return await txn.delete('Sales', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Get next bill number
  Future<String> getNextBillNumber() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT bill_no FROM Sales ORDER BY CAST(bill_no AS INTEGER) DESC LIMIT 1',
    );

    if (result.isEmpty) {
      return '000001';
    }

    final lastBillNo = result.first['bill_no'] as String;
    final nextNumber = (int.parse(lastBillNo) + 1).toString().padLeft(6, '0');
    return nextNumber;
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }

  Future<Map<String, dynamic>> getMonthlyReport(int month, int year) async {
    final db = await database;

    String paddedMonth = month.toString().padLeft(2, '0');
    String yyyy = year.toString();
    String like1 = '%/$paddedMonth/$yyyy%'; 
    String like2 = '%/$month/$yyyy%'; 

    // Get all items
    final items = await db.query('items');

    List<ReportItem> reportList = [];

    for (var item in items) {
      int itemId = item['id'] as int;
      String itemName = item['name'] as String;

      // 1️⃣ Total Stock (for the month)
      final stockResult = await db.rawQuery(
        '''
      SELECT 
        IFNULL(SUM(quantity_grams),0) as total_stock
      FROM Stock
      WHERE item_id = ?
        AND (added_date LIKE ? OR added_date LIKE ?)
    ''',
        [itemId, like1, like2],
      );

      double totalStockG = (stockResult.first['total_stock'] as num).toDouble();
      String totalStockKgStr = (totalStockG / 1000).toStringAsFixed(2);
      print('Item $itemName - Total Stock: $totalStockKgStr Kg'); // Debug

      // 2️⃣ Monthly Sales
      final salesResult = await db.rawQuery(
        '''
      SELECT 
        IFNULL(SUM(quantity_grams),0) as total_sold,
        IFNULL(SUM(amount),0) as total_income
      FROM Sales
      WHERE item_id = ?
        AND (added_date LIKE ? OR added_date LIKE ?)
    ''',
        [itemId, like1, like2],
      );

      int totalSoldG = salesResult.first['total_sold'] as int;
      print('Item $itemName - Total Sold (g): $totalSoldG'); // Debug
      double totalIncome = (salesResult.first['total_income'] as num)
          .toDouble();
      print('Item $itemName - Total Income: $totalIncome'); // Debug

      // 3️⃣ Profit Calculation (use actual stock price for each sale)
      // Get all sales for this item in the month
      final salesRows = await db.rawQuery(
        '''
        SELECT S.quantity_grams, S.amount, S.added_date, S.selling_price, St.stock_price
        FROM Sales S
        LEFT JOIN (
          SELECT item_id, MAX(id) as max_stock_id
          FROM Stock
          GROUP BY item_id
        ) latestStock ON S.item_id = latestStock.item_id
        LEFT JOIN Stock St ON St.id = latestStock.max_stock_id
        WHERE S.item_id = ? AND (S.added_date LIKE ? OR S.added_date LIKE ?)
        ''',
        [itemId, like1, like2],
      );

      double totalCost = 0.0;
      for (final row in salesRows) {
        final qtyGrams = (row['quantity_grams'] ?? 0) as num;
        final stockPrice = (row['stock_price'] ?? 0) as num;
        totalCost += (qtyGrams / 1000.0) * stockPrice;
      }
      double totalProfit = totalIncome - totalCost;

      reportList.add(
        ReportItem(
          name: itemName,
          stockKg: totalStockG / 1000,
          soldKg: totalSoldG / 1000,
          income: totalIncome,
          profit: totalProfit,
        ),
      );
    }

    // 4️⃣ Grand Totals
    double grandIncome = reportList.fold(0, (sum, item) => sum + item.income);
    print('Grand Total Income: $grandIncome'); // Debug

    double grandProfit = reportList.fold(0, (sum, item) => sum + item.profit);
    print('Grand Total Profit: $grandProfit'); // Debug

    return {
      "items": reportList,
      "total_income": grandIncome,
      "total_profit": grandProfit,
    };
  }
}

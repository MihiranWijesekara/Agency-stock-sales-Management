import 'package:chicken_dilivery/pages/Managemnt/managementDashboard.dart';
import 'package:chicken_dilivery/pages/Report/report.dart';
import 'package:chicken_dilivery/pages/sales/addSales.dart';
import 'package:chicken_dilivery/pages/sales/allSalesDashboard.dart';
import 'package:chicken_dilivery/pages/sales/salesDashboard.dart';
import 'package:chicken_dilivery/pages/stock/allStockDashboard.dart';
import 'package:chicken_dilivery/pages/stock/currentStockDisplay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_DashCardData>[
      _DashCardData(
        title: 'Sales',
        subtitle: 'View sales',
        icon: Icons.trending_up,
        color: const Color(0xFF4CAF50),
        gradientColors: [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
        onTap: () {
          // Navigate to Items page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalesDashboard()),
          );
        },
      ),
      _DashCardData(
        title: 'Stock',
        subtitle: 'Inventory',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF2196F3),
        gradientColors: [const Color(0xFF2196F3), const Color(0xFF42A5F5)],
        onTap: () {
          // Navigate to Items page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StockDisplay()),
          );
        },
      ),
      _DashCardData(
        title: 'All Sales',
        subtitle: 'History of sales',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFFF9800),
        gradientColors: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
        onTap: () {
          // Navigate to Items page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allsalesdashboard()),
          );
        },
      ),
      _DashCardData(
        title: 'All Stocks',
        subtitle: 'History of stocks',
        icon: Icons.history,
        color: const Color(0xFFE91E63),
        gradientColors: [const Color(0xFFE91E63), const Color(0xFFF06292)],
        onTap: () {
          // Navigate to Items page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstockdashboard()),
          );
        },
      ),

      _DashCardData(
        title: 'Management',
        subtitle: 'Items & Settings',
        icon: Icons.category_outlined,
        color: const Color(0xFF9C27B0),
        gradientColors: [const Color(0xFF9C27B0), const Color(0xFFAB47BC)],
        onTap: () {
          // Navigate to Items page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Managementdashboard(),
            ),
          );
        },
      ),
      _DashCardData(
        title: 'Reports',
        subtitle: 'Generate reports',
        icon: Icons.bar_chart_outlined,
        // Using a vibrant Indigo to contrast the Pink and Brown cards
        color: const Color(0xFF5C6BC0),
        gradientColors: [
          const Color(0xFF5C6BC0), // Lighter top-left
          const Color(0xFF3F51B5), // Darker bottom-right for depth
        ],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportPage()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            // Navigate to notifications
                            // Navigator.pushNamed(context, '/notifications');
                          },
                        ),
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
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
                1.1, // Increased from 0.95 to make cards smaller/shorter
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return _DashboardCard(cardData: cards[index]);
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to Add Item page
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Addsales()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 26, 11, 167),
        elevation: 4,
        icon: const Icon(
          Icons.add_circle_outline,
          color: Colors.white,
          size: 24,
        ),
        label: const Text(
          'Add Sales',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _DashCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _DashCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.onTap,
  });
}

class _DashboardCard extends StatefulWidget {
  final _DashCardData cardData;

  const _DashboardCard({required this.cardData});

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.cardData.gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.cardData.color.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _controller.forward().then((_) => _controller.reverse());
              widget.cardData.onTap();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.cardData.icon,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.cardData.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.cardData.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

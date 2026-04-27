import 'package:chicken_dilivery/pages/Item/itemPage.dart';
import 'package:chicken_dilivery/pages/Managemnt/rootPage.dart';
import 'package:chicken_dilivery/pages/Managemnt/shopPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Managementdashboard extends StatelessWidget {
  const Managementdashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_DashCardData>[
      _DashCardData(
        title: 'Item',
        subtitle: 'Manage Products',
        icon: Icons.inventory_outlined,
        color: const Color(0xFF4CAF50),
        gradientColors: [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
        onTap: () {
          // Navigate to Items page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ItemPage()),
          );
        },
      ),
      _DashCardData(
        title: 'Shop',
        subtitle: 'Store Settings',
        icon: Icons.store_outlined,
        color: const Color(0xFF2196F3),
        gradientColors: [const Color(0xFF2196F3), const Color(0xFF42A5F5)],
        onTap: () {
          // Navigate to Shop page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShopPage()),
          );
        },
      ),
      _DashCardData(
        title: 'Root',
        subtitle: 'Admin Access',
        icon: Icons.admin_panel_settings_outlined,
        color: const Color(0xFFE91E63),
        gradientColors: [const Color(0xFFE91E63), const Color(0xFFF06292)],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Rootpage()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Management Dashboard',
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.cardData.icon,
                      size: 32,
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
                  const SizedBox(height: 4),
                  Text(
                    widget.cardData.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
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

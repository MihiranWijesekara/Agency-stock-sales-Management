import 'package:chicken_dilivery/pages/stock/allStock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Allstockdashboard extends StatelessWidget {
  const Allstockdashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_DashCardData>[
      _DashCardData(
        title: 'January',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.blue,
        gradientColors: [Colors.blue, Colors.lightBlueAccent],
        onTap: () {
          // Navigate to Items page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 1)),
          );
        },
      ),
      _DashCardData(
        title: 'February',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.purple,
        gradientColors: [Colors.purple, Colors.deepPurpleAccent],
        onTap: () {
          // Navigate to Shop page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 2)),
          );
        },
      ),
      _DashCardData(
        title: 'March',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.green,
        gradientColors: [Colors.green, Colors.lightGreenAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 3)),
          );
        },
      ),
      _DashCardData(
        title: 'April',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.orange,
        gradientColors: [Colors.orange, Colors.deepOrangeAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 4)),
          );
        },
      ),
      _DashCardData(
        title: 'May',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.teal,
        gradientColors: [Colors.teal, Colors.tealAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 5)),
          );
        },
      ),
      _DashCardData(
        title: 'June',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.indigo,
        gradientColors: [Colors.indigo, Colors.indigoAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 6)),
          );
        },
      ),
      _DashCardData(
        title: 'July',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.red,
        gradientColors: [Colors.red, Colors.redAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 7)),
          );
        },
      ),
      _DashCardData(
        title: 'August',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.cyan,
        gradientColors: [Colors.cyan, Colors.cyanAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 8)),
          );
        },
      ),
      _DashCardData(
        title: 'September',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.amber,
        gradientColors: [Colors.amber, Colors.amberAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 9)),
          );
        },
      ),
      _DashCardData(
        title: 'October',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.brown,
        gradientColors: [Colors.brown, Colors.brown.shade300],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 10)),
          );
        },
      ),
      _DashCardData(
        title: 'November',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.deepOrange,
        gradientColors: [Colors.deepOrange, Colors.orangeAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 11)),
          );
        },
      ),
      _DashCardData(
        title: 'December',
        subtitle: 'Stock Overview',
        icon: Icons.warehouse,
        color: Colors.deepPurple,
        gradientColors: [Colors.deepPurple, Colors.purpleAccent],
        onTap: () {
          // Navigate to Root page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allstock( month: 12)),
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
                            'All Stock Dashboard',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75, // Square cards
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return _DashboardCard(cardData: cards[index]);
            },
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
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.cardData.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.cardData.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
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

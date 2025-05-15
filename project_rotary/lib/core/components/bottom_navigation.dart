import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class BottomNavigation extends StatefulWidget {
  final int initialIndex;

  const BottomNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/categories');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/loans');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/applicants');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: CustomColors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.grid2x2),
          label: 'Categorias',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.layoutList),
          label: 'Empréstimos',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.users),
          label: 'Solicitantes',
        ),
      ],
      currentIndex: currentIndex,
      onTap: _onTap,
    );
  }
}

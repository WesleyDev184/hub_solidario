import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/drawer/applicants/presentation/pages/applicants_page.dart';
import 'package:project_rotary/app/drawer/categories/presentation/pages/categories_page.dart';
import 'package:project_rotary/app/drawer/loans/presentation/pages/loans_page.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/background_wrapper.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  int currentIndex = 0;

  final List<Widget> _pages = const [
    CategoriesPage(),
    LoansPage(),
    ApplicantsPage(),
  ];

  void _onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  String _getTitle() {
    switch (currentIndex) {
      case 0:
        return 'Categorias';
      case 1:
        return 'Empréstimos';
      case 2:
        return 'Solicitantes';
      default:
        return 'App';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: _getTitle()),
      body: BackgroundWrapper(
        child: IndexedStack(index: currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: CustomColors.white,
        currentIndex: currentIndex,
        onTap: _onTap,
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
      ),
    );
  }
}

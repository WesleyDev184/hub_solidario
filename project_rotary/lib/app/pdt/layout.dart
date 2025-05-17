import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/pages/applicants_page.dart';
import 'package:project_rotary/app/pdt/categories/presentation/pages/categories_page.dart';
import 'package:project_rotary/app/pdt/loans/presentation/pages/loans_page.dart';
import 'package:project_rotary/core/components/background_wrapper.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int currentIndex = 0;

  // Cada aba terá sua própria key para manter histórico de navegação
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Lista de páginas iniciais de cada aba
  final List<Widget> _pages = const [
    CategoriesPage(),
    LoansPage(),
    ApplicantsPage(),
  ];

  void _onTap(int index) {
    if (index == currentIndex) {
      // Se desejar, você pode zerar a pilha da aba atual
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    }
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWrapper(
        child: IndexedStack(
          index: currentIndex,
          children: List.generate(_pages.length, (index) {
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (context) => _pages[index]);
              },
            );
          }),
        ),
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

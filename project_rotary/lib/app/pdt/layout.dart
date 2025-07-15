import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/applicants/pages/applicants_page.dart';
import 'package:project_rotary/app/pdt/categories/pages/categories_page.dart';
import 'package:project_rotary/app/pdt/loans/pages/loans_page.dart';
import 'package:project_rotary/core/components/background_wrapper.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int currentIndex = 0;

  // Controle para saber se houve navegação em cada aba
  final List<bool> _hasNavigated = [false, false, false];

  // Cada aba terá sua própria key para manter histórico de navegação
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Callbacks para recarregar as páginas
  final List<VoidCallback?> _refreshCallbacks = [null, null, null];

  // Método para marcar navegação
  void _markNavigation(int index) {
    _hasNavigated[index] = true;
  }

  // Lista de páginas iniciais de cada aba
  List<Widget> get _pages => [
    CategoriesPage(
      onRefreshCallback: (callback) => _refreshCallbacks[0] = callback,
    ),
    LoansPage(onRefreshCallback: (callback) => _refreshCallbacks[1] = callback),
    ApplicantsPage(
      onRefreshCallback: (callback) => _refreshCallbacks[2] = callback,
    ),
  ];

  void _onTap(int index) {
    if (index == currentIndex) {
      // Verifica se houve navegação na aba atual
      final navigator = _navigatorKeys[index].currentState;
      if (navigator != null && navigator.canPop()) {
        // Se houve navegação, volta para a página inicial
        navigator.popUntil((route) => route.isFirst);
        // Recarrega a página imediatamente após voltar
        _refreshCallbacks[index]?.call();
        _hasNavigated[index] = false;
      } else if (_hasNavigated[index]) {
        // Se não há navegação mas já houve antes, recarrega a página
        _refreshCallbacks[index]?.call();
        _hasNavigated[index] = false;
      }
    } else {
      // Mudança de aba
      setState(() {
        currentIndex = index;
      });
    }
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
              observers: [
                _CustomNavigatorObserver(
                  onNavigation: () => _markNavigation(index),
                ),
              ],
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

class _CustomNavigatorObserver extends NavigatorObserver {
  final VoidCallback onNavigation;

  _CustomNavigatorObserver({required this.onNavigation});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null) {
      onNavigation();
    }
  }
}

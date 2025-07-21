import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PtdLayout extends StatefulWidget {
  const PtdLayout({super.key});

  static const List<String> _routes = [
    '/ptd/stocks',
    '/ptd/option2',
    '/ptd/option3',
  ];

  @override
  State<PtdLayout> createState() => _PtdLayoutState();
}

class _PtdLayoutState extends State<PtdLayout> {
  int _currentIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    3,
    (_) => GlobalKey<NavigatorState>(),
  );

  void _onTap(int index) {
    if (_currentIndex == index) {
      // Se já está na aba, faz pop até a primeira rota
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
      context.go(PtdLayout._routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Atualiza o índice baseado na rota atual
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < PtdLayout._routes.length; i++) {
      if (location.startsWith(PtdLayout._routes[i])) {
        _currentIndex = i;
      }
    }
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTabNavigator(0, '/ptd/stocks'),
          _buildTabNavigator(1, '/ptd/option2'),
          _buildTabNavigator(2, '/ptd/option3'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Stocks'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Option 2'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Option 3'),
        ],
      ),
    );
  }

  Widget _buildTabNavigator(int index, String initialRoute) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        // O GoRouter renderiza a subroute, então só retorna um container vazio
        return MaterialPageRoute(
          builder: (context) => const SizedBox.expand(
            child: Center(child: Text('Selecione uma opção')),
          ),
        );
      },
    );
  }
}

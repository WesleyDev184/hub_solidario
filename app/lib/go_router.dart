import 'package:app/app/ptd/applicants/add_applicant_page.dart';
import 'package:app/app/ptd/applicants/applicant_page.dart';
import 'package:app/app/ptd/applicants/applicants_page.dart';
import 'package:app/app/ptd/applicants/delete_applicant_page.dart';
import 'package:app/app/ptd/applicants/edit_applicant_page.dart';
import 'package:app/app/ptd/loans/edit_loan_page.dart';
import 'package:app/app/ptd/loans/finalize_loan_page.dart';
import 'package:app/app/ptd/loans/loan_page.dart';
import 'package:app/app/ptd/loans/loans_page.dart';
import 'package:app/app/ptd/stocks/add_item_page.dart';
import 'package:app/app/ptd/stocks/add_stock_page.dart';
import 'package:app/app/ptd/stocks/borrow_item_page.dart';
import 'package:app/app/ptd/stocks/delete_item_page.dart';
import 'package:app/app/ptd/stocks/delete_stock_page.dart';
import 'package:app/app/ptd/stocks/edit_item_page.dart';
import 'package:app/app/ptd/stocks/edit_stock_page.dart';
import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/app_page.dart';
import 'app/auth/forgot_password_page.dart';
import 'app/auth/signin_page.dart';
import 'app/auth/signup_page.dart';
import 'app/ptd/info/info_page.dart';
import 'app/ptd/ptd_layout.dart';
import 'app/ptd/stocks/stock_page.dart';
import 'app/ptd/stocks/stocks_page.dart';

GoRouter createGoRouter(AuthController authController) {
  return GoRouter(
    initialLocation: RoutePaths.root,
    routes: [
      GoRoute(
        path: RoutePaths.root,
        builder: (context, state) => const AppPage(),
      ),
      GoRoute(
        path: RoutePaths.auth.signin,
        builder: (context, state) => const SigninPage(),
      ),
      GoRoute(
        path: RoutePaths.auth.signup,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: RoutePaths.auth.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => PtdLayout(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.ptd.stocks,
            builder: (context, state) => const StocksPage(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) =>
                    StockPage(id: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) =>
                    EditStockPage(stockId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'delete/:id',
                builder: (context, state) =>
                    DeleteStockPage(stockId: state.pathParameters['id']!),
              ),

              GoRoute(
                path: 'add_item/:id',
                builder: (context, state) =>
                    AddItemPage(stockId: state.pathParameters['id']!),
              ),

              GoRoute(
                path: 'edit_item/:id/:stockId',
                builder: (context, state) => EditItemPage(
                  itemId: state.pathParameters['id']!,
                  stockId: state.pathParameters['stockId']!,
                ),
              ),
              GoRoute(
                path: 'delete_item/:id/:stockId',
                builder: (context, state) => DeleteItemPage(
                  itemId: state.pathParameters['id']!,
                  stockId: state.pathParameters['stockId']!,
                ),
              ),
              GoRoute(
                path: 'borrow_item/:id',
                builder: (context, state) =>
                    BorrowItemPage(stockId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddStockPage(),
              ),
            ],
          ),

          GoRoute(
            path: RoutePaths.ptd.info,
            builder: (context, state) => const InfoPage(),
          ),

          GoRoute(
            path: RoutePaths.ptd.loans,
            builder: (context, state) => const LoansPage(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) =>
                    LoanPage(loanId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'finalize/:id',
                builder: (context, state) =>
                    FinalizeLoanPage(loanId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) =>
                    EditLoanPage(loanId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.ptd.applicants,
            builder: (context, state) => const ApplicantsPage(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) =>
                    ApplicantPage(applicantId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => AddApplicantPage(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) =>
                    EditApplicantPage(applicantId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'delete/:id',
                builder: (context, state) => DeleteApplicantPage(
                  applicantId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    // --- Adicione a função de redirecionamento aqui ---
    redirect: (BuildContext context, GoRouterState state) async {
      final bool isLoggedIn = authController.isAuthenticated;
      final bool hasValidToken = await authController.cacheService
          .hasValidToken();
      final String currentPath = state.matchedLocation;
      debugPrint("Current path: $currentPath");

      final List<String> publicPaths = [
        RoutePaths.auth.signin,
        RoutePaths.auth.signup,
        RoutePaths.auth.forgotPassword,
      ];

      final bool goingToPublicPath = publicPaths.contains(currentPath);

      if (!isLoggedIn && !goingToPublicPath) {
        return RoutePaths.auth.signin;
      }

      if (isLoggedIn && goingToPublicPath) {
        return RoutePaths.ptd.stocks;
      }

      if (isLoggedIn && !hasValidToken) {
        await authController.logout();
        return RoutePaths.auth.signin;
      }

      if (isLoggedIn && currentPath == RoutePaths.root) {
        return RoutePaths.ptd.stocks;
      }

      return null;
    },
    // Opcional: Tratamento de erros para rotas não encontradas
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(child: Text('Página não encontrada: ${state.error}')),
    ),
  );
}

// Helpers para navegação por nome
class RoutePaths {
  static const String root = '/';
  static const auth = _AuthPaths();
  static const ptd = _PtdPaths();
}

class _AuthPaths {
  const _AuthPaths();
  String get signin => '/auth/signin';
  String get signup => '/auth/signup';
  String get forgotPassword => '/auth/forgot_password';
}

class _PtdPaths {
  const _PtdPaths();
  String get root => '/ptd';
  // Stocks
  String get stocks => '/ptd/stocks';
  String get addStock => '/ptd/stocks/add';
  String editStock(String id) => '/ptd/stocks/edit/$id';
  String deleteStock(String id) => '/ptd/stocks/delete/$id';
  String stockId(String id) => '/ptd/stocks/detail/$id';
  String addItem(String id) => '/ptd/stocks/add_item/$id';
  String editItem(String itemId, String stockId) =>
      '/ptd/stocks/edit_item/$itemId/$stockId';
  String deleteItem(String itemId, String stockId) =>
      '/ptd/stocks/delete_item/$itemId/$stockId';
  String borrowItem(String stockId) => '/ptd/stocks/borrow_item/$stockId';

  // Info
  String get info => '/ptd/info';

  // Loans
  String get loans => '/ptd/loans';
  String loanId(String id) => '/ptd/loans/detail/$id';
  String editLoan(String id) => '/ptd/loans/edit/$id';
  String loanFinalize(String id) => '/ptd/loans/finalize/$id';

  // Applicants
  String get applicants => '/ptd/applicants';
  String get addApplicant => '/ptd/applicants/add';
  String applicantId(String id) => '/ptd/applicants/detail/$id';
  String applicantEdit(String id) => '/ptd/applicants/edit/$id';
  String applicantDelete(String id) => '/ptd/applicants/delete/$id';
}

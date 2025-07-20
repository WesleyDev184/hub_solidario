import 'package:routefly/routefly.dart';

import 'app/app_page.dart' as a0;
import 'app/auth/forgot_password_page.dart' as a9;
import 'app/auth/signin_page.dart' as a8;
import 'app/auth/signup_page.dart' as a7;
import 'app/info/info_page.dart' as a1;
import 'app/ptd/option2_page.dart' as a4;
import 'app/ptd/option3_page.dart' as a5;
import 'app/ptd/ptd_layout.dart' as a6;
import 'app/ptd/stocks/[id]_page.dart' as a2;
import 'app/ptd/stocks/stocks_page.dart' as a3;

List<RouteEntity> get routes => [
  RouteEntity(
    key: '/',
    uri: Uri.parse('/'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a0.AppPage(),
    ),
  ),
  RouteEntity(
    key: '/info',
    uri: Uri.parse('/info'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a1.InfoPage(),
    ),
  ),
  RouteEntity(
    key: '/ptd/stocks/[id]',
    parent: '/ptd',
    uri: Uri.parse('/ptd/stocks/[id]'),
    routeBuilder: a2.routeBuilder,
  ),
  RouteEntity(
    key: '/ptd/stocks',
    parent: '/ptd',
    uri: Uri.parse('/ptd/stocks'),
    routeBuilder: a3.routeBuilder,
  ),
  RouteEntity(
    key: '/ptd/option2',
    parent: '/ptd',
    uri: Uri.parse('/ptd/option2'),
    routeBuilder: a4.routeBuilder,
  ),
  RouteEntity(
    key: '/ptd/option3',
    parent: '/ptd',
    uri: Uri.parse('/ptd/option3'),
    routeBuilder: a5.routeBuilder,
  ),
  RouteEntity(
    key: '/ptd',
    uri: Uri.parse('/ptd'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a6.PtdLayout(),
    ),
  ),
  RouteEntity(
    key: '/auth/signup',
    uri: Uri.parse('/auth/signup'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a7.SignUpPage(),
    ),
  ),
  RouteEntity(
    key: '/auth/signin',
    uri: Uri.parse('/auth/signin'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a8.SigninPage(),
    ),
  ),
  RouteEntity(
    key: '/auth/forgot_password',
    uri: Uri.parse('/auth/forgot_password'),
    routeBuilder: (ctx, settings) => Routefly.defaultRouteBuilder(
      ctx,
      settings,
      const a9.ForgotPasswordPage(),
    ),
  ),
];

const routePaths = (
  path: '/',
  info: '/info',
  ptd: (
    path: '/ptd',
    stocks: (
      path: '/ptd/stocks',
      $id: '/ptd/stocks/[id]',
    ),
    option2: '/ptd/option2',
    option3: '/ptd/option3',
  ),
  auth: (
    path: '/auth',
    signup: '/auth/signup',
    signin: '/auth/signin',
    forgotPassword: '/auth/forgot_password',
  ),
);

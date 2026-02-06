import 'package:flutter/material.dart';

import 'screens/add_gig_screen.dart';
import 'screens/gig_detail_screen.dart';
import 'screens/my_gigs_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/route_optimization_screen.dart';
import 'screens/today_dashboard_screen.dart';

class GigOptimizerApp extends StatelessWidget {
  const GigOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gig Optimizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: OnboardingScreen.routeName,
      routes: {
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        TodayDashboardScreen.routeName: (_) => const TodayDashboardScreen(),
        AddGigScreen.routeName: (_) => const AddGigScreen(),
        GigDetailScreen.routeName: (_) => const GigDetailScreen(),
        RouteOptimizationScreen.routeName: (_) => const RouteOptimizationScreen(),
        MyGigsScreen.routeName: (_) => const MyGigsScreen(),
      },
    );
  }
}

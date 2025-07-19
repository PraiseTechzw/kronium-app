import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/widgets/app_drawer.dart';

class AdminScaffold extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final bool showDrawer;
  final bool showAppBar;
  final bool? isDarkMode;
  final ValueChanged<bool>? onDarkModeChanged;
  final Widget? bottomNavigationBar;

  const AdminScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.showDrawer = true,
    this.showAppBar = true,
    this.isDarkMode,
    this.onDarkModeChanged,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: widget.actions,
            )
          : null,
      drawer: widget.showDrawer
          ? AppDrawer(
              isDarkMode: _isDarkMode,
              userAuthService: Get.find<UserAuthService>(),
              adminAuthService: Get.find<AdminAuthService>(),
              onDarkModeChanged: (val) {
                setState(() => _isDarkMode = val);
                widget.onDarkModeChanged?.call(val);
              },
              onShowAbout: () {},
              onShowContact: () {},
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: widget.body,
        ),
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
} 
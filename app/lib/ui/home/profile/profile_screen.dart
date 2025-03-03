import 'package:emma/infrastructure/app_info.dart';
import 'package:emma/infrastructure/window_size_writer.dart';
import 'package:emma/ui/app_icons.dart';
import 'package:emma/ui/home/profile/development/screen_size_selector.dart';
import 'package:emma/ui/locator.dart';
import 'package:emma/ui/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppInfo _appInfo;
  late final UserViewModel _vm;

  @override
  void initState() {
    super.initState();
    _appInfo = locator.get<AppInfo>();
    _vm = locator.get<UserViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Watch((context) => ListTile(
            leading: const Icon(AppIcons.logout),
            title: const Text("Logout"),
            onTap: _vm.logout.call,
            enabled: !_vm.logout.isRunning.value,
          ))
    ];

    if (WindowSizeWriter.isSupported) {
      items.add(const ListTile(
          leading: Icon(Icons.fit_screen_rounded),
          title: ScreenSizeSelector()));
    }

    items.add(Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Version: ${_appInfo.version}",
        style: Theme.of(context).textTheme.labelMedium,
      ),
    )));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        children: [
          ...ListTile.divideTiles(context: context, tiles: items),
        ],
      ),
    );
  }
}

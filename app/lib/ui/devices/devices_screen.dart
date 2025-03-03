import 'dart:async';

import 'package:emma/ui/app_icons.dart';
import 'package:emma/ui/app_navigator.dart';
import 'package:emma/ui/devices/add/select_device_category_screen.dart';
import 'package:emma/ui/devices/devices_view_model.dart';
import 'package:emma/ui/devices/widgets/devices_list.dart';
import 'package:emma/ui/locator.dart';
import 'package:emma/ui/shared/noop.dart';
import 'package:emma/ui/shared/app_bar_command_progress_indicator.dart';
import 'package:flutter/material.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _disposed = false;
  Timer? _timer;

  // The view model has to be stored in the state for it to work.
  // Otherwise the DevicesVieModel would be created multiple times
  // because on every screen change the DevicesScreen ctor is called.
  late final DevicesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = locator.get<DevicesViewModel>();
    viewModel.init();
    _timer = Timer(const Duration(seconds: 1), _timerCallback);
  }

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            const IconButton(onPressed: noop, icon: Icon(Icons.low_priority)),
            IconButton(
                onPressed: _startAddFlow, icon: const Icon(AppIcons.add)),
          ],
          bottom: AppBarCommandProgressIndicator(command: viewModel.init),
        ),
        body: DevicesList(viewModel: viewModel));
  }

  void _startAddFlow() {
    AppNavigator.push(const SelectDeviceCategoryScreen());
  }

  Future<void> _timerCallback() async {
    var success = false;
    do {
      success = await viewModel.refresh();
    } while (!_disposed && success);

    if (!success) {
      // on failure: retry after 30 seconds
      _timer = Timer(const Duration(seconds: 30), _timerCallback);
    }
  }
}

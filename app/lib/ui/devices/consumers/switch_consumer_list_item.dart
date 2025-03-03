import 'package:emma/ui/app_icons.dart';
import 'package:emma/ui/app_navigator.dart';
import 'package:emma/ui/devices/consumers/edit_switch_consumer_screen.dart';
import 'package:emma/ui/devices/consumers/switch_consumer_view_model.dart';
import 'package:emma/ui/devices/widgets/on_off_indicator.dart';
import 'package:emma/ui/shared/unit_text.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class SwitchConsumerListItem extends StatelessWidget {
  const SwitchConsumerListItem({super.key, required this.viewModel});

  final SwitchConsumerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Watch((context) => Expanded(
                      child: SegmentedButton<SwitchConsumerMode>(
                        segments: const [
                          ButtonSegment(
                            value: SwitchConsumerMode.off,
                            label: Text("Aus"),
                          ),
                          ButtonSegment(
                            value: SwitchConsumerMode.on,
                            label: Text("An"),
                          ),
                          ButtonSegment(
                            value: SwitchConsumerMode.smart,
                            label: Text("Smart"),
                          )
                        ],
                        selected: {viewModel.mode.value},
                        showSelectedIcon: false,
                        onSelectionChanged: _onSelectionChanged,
                      ),
                    )),
              ],
            ),
          ),
          ListTile(
            leading: Watch((context) => OnOffIndicator(
                  status: _getIndicatorStatus(viewModel.status.value),
                )),
            title: Watch((context) => Text(
                  viewModel.name.value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: _getTextColor(context, viewModel.status.value)),
                )),
            subtitle: Watch(
              (context) => UnitText.power(
                  viewModel.currentPowerConsumption.value,
                  color: _getTextColor(context, viewModel.status.value)),
            ),
            trailing: IconButton(
              icon: const Icon(AppIcons.arrow_next),
              onPressed: _gotoEdit,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSelectionChanged(Set<SwitchConsumerMode> selection) async {
    var mode = selection.first;
    switch (mode) {
      case SwitchConsumerMode.off:
        await viewModel.switchOff();
        return;

      case SwitchConsumerMode.on:
        await viewModel.switchOn();
        return;

      case SwitchConsumerMode.smart:
        viewModel.activateSmartMode();
        return;
    }
  }

  void _gotoEdit() {
    AppNavigator.push(EditSwitchConsumerScreen(viewModel: viewModel));
  }

  static bool _getIndicatorStatus(SwitchConsumerStatus status) {
    return switch (status) {
      SwitchConsumerStatus.off => false,
      SwitchConsumerStatus.on => true,
    };
  }

  static Color _getTextColor(
      BuildContext context, SwitchConsumerStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status) {
      SwitchConsumerStatus.off => colorScheme.secondary,
      SwitchConsumerStatus.on => colorScheme.primary,
    };
  }
}

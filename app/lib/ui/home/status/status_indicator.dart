import 'package:emma/ui/app_icons.dart';
import 'package:emma/ui/shared/unit_text.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class StatusIndicator extends StatelessWidget {
  static const double _indicatorSize = 96;
  static const double _iconSize = 32;

  StatusIndicator({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    this.maxValue,
    ReadonlySignal<StatusIndicatorDirection>? direction,
  }) : direction = direction ?? signal(StatusIndicatorDirection.none);

  final ReadonlySignal<IconData> icon;
  final ReadonlySignal<double> value;
  final ReadonlySignal<double>? maxValue;
  final String unit;
  final ReadonlySignal<StatusIndicatorDirection> direction;

  late final _indicatorValue = computed(() {
    if (value.value == 0) {
      return 0;
    } else if (maxValue == null || maxValue!.value == 0) {
      return 1;
    } else if (maxValue!.value < value.value) {
      return 1;
    } else {
      return value.value / maxValue!.value;
    }
  });

  late final _tween = computed(() => Tween<double>(
        begin: _indicatorValue.previousValue?.toDouble() ?? 0.0,
        end: _indicatorValue.value.toDouble(),
      ));

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Watch((context) => Row(
                mainAxisSize: MainAxisSize.min, children: _getIcons(context))),
            Watch((context) => UnitText(value.value, unit)),
          ],
        ),
        SizedBox(
          height: _indicatorSize,
          width: _indicatorSize,
          child: Watch(
            (context) => TweenAnimationBuilder<double>(
              tween: _tween.value,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ),
        )
      ],
    );
  }

  List<Icon> _getIcons(BuildContext context) {
    final defaultIcon = Icon(icon.value, size: _iconSize);
    final directionIcon = switch (direction.value) {
      StatusIndicatorDirection.none => null,
      StatusIndicatorDirection.up => Icon(
          AppIcons.arrow_upward,
          size: _iconSize,
          color: Theme.of(context).colorScheme.primary,
        ),
      StatusIndicatorDirection.down => Icon(
          AppIcons.arrow_downward,
          size: _iconSize,
          color: Theme.of(context).colorScheme.error,
        )
    };

    return [defaultIcon, if (directionIcon != null) directionIcon];
  }
}

enum StatusIndicatorDirection { none, up, down }

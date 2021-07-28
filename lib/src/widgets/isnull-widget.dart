import 'package:flutter/material.dart';

class IsNullWidget<T> extends StatefulWidget {
  final T? value;
  final Widget Function(BuildContext, T, Widget?) child;
  final Widget Function(BuildContext, T?, Widget?) nullWidget;
  const IsNullWidget({Key? key, this.value, required this.child, required this.nullWidget}) : super(key: key);

  @override
  _IsNullWidgetState<T> createState() => _IsNullWidgetState<T>();
}

class _IsNullWidgetState<T> extends State<IsNullWidget<T>> {
  late ValueNotifier<T?> notifier;

  @override
  void initState() {
    notifier = ValueNotifier(widget.value);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant IsNullWidget<T> oldWidget) {
    notifier.value = widget.value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T?>(
        valueListenable: notifier,
        builder: (context, value, child) {
          return value == null ? widget.nullWidget(context, value, child) : widget.child(context, value, child);
        });
  }
}

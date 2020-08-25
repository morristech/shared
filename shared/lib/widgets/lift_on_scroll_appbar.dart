import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class LiftOnScrollAppBar extends StatefulWidget {
  final Widget body;
  final Color shadowColor;
  final double maxElevation;
  final double minElevation;
  final Widget leading;
  final bool automaticallyImplyLeading;
  final Widget title;
  final List<Widget> actions;
  final Widget flexibleSpace;
  final PreferredSizeWidget bottom;
  final ShapeBorder shape;
  final Color backgroundColor;
  final IconThemeData iconTheme;
  final IconThemeData actionsIconTheme;
  final TextTheme textTheme;
  final bool primary;
  final bool centerTitle;
  final double titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final Brightness brightness;
  const LiftOnScrollAppBar({
    Key key,
    @required this.body,
    this.shadowColor,
    this.maxElevation = 12.0,
    this.minElevation = 0.0,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.shape,
    this.backgroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.brightness,
  }) : super(key: key);

  @override
  _LiftOnScrollAppBarState createState() => _LiftOnScrollAppBarState();
}

class _LiftOnScrollAppBarState extends State<LiftOnScrollAppBar> {
  final ValueNotifier<double> _elevation = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();

    _elevation.value = widget.minElevation;
  }

  @override
  Widget build(BuildContext context) {
    final height = context.mq.padding.top + kToolbarHeight;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.horizontal) {
          return false;
        }

        final offset = notification.metrics.pixels.atLeast(0);

        final minElevation = widget.minElevation;
        final maxElevation = widget.maxElevation;
        final elevation = lerpDouble(
          minElevation,
          maxElevation,
          ((offset / 10) / maxElevation).clamp(0.0, 1.0),
        );

        _elevation.value = elevation;

        return false;
      },
      child: Stack(
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: _elevation,
            builder: (context, value, appBar) {
              return Box(
                elevation: value,
                shadowColor: widget.shadowColor ?? Colors.black.withOpacity(0.2),
                child: appBar,
              );
            },
            child: SizedBox.fromSize(
              size: Size.fromHeight(height),
              child: AppBar(
                elevation: 0.0,
                actions: widget.actions,
                actionsIconTheme: widget.actionsIconTheme,
                automaticallyImplyLeading: widget.automaticallyImplyLeading,
                backgroundColor: widget.backgroundColor,
                bottom: widget.bottom,
                bottomOpacity: widget.bottomOpacity,
                centerTitle: widget.centerTitle,
                flexibleSpace: widget.flexibleSpace,
                iconTheme: widget.iconTheme,
                leading: widget.leading,
                primary: widget.primary,
                shape: widget.shape,
                textTheme: widget.textTheme,
                title: widget.title,
                titleSpacing: widget.titleSpacing,
                toolbarOpacity: widget.toolbarOpacity,
                brightness: widget.brightness,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height),
            child: widget.body,
          ),
        ],
      ),
    );
  }
}

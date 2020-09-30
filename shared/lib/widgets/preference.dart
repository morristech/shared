import 'dart:async';

import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'package:shared/shared.dart';

class Preference extends StatefulWidget {
  final String dependentKey;
  final bool Function(dynamic value) disableWhenDependent;
  final bool isEnabled;
  final bool reserveIconSpace;
  final dynamic title;
  final dynamic summary;
  final Widget leading;
  final Widget trailing;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final bool show;
  const Preference({
    Key key,
    this.dependentKey,
    this.disableWhenDependent,
    this.isEnabled = true,
    this.reserveIconSpace,
    @required this.title,
    this.summary,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.show,
  }) : super(key: key);

  @override
  _PreferenceState createState() => _PreferenceState();
}

class _PreferenceState extends State<Preference> {
  Preferences _prefs;
  StreamSubscription _sub;

  bool _isDependetPreferenceEnabled = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    _prefs ??= Preferences(await StreamingSharedPreferences.instance);

    if (widget.dependentKey != null) {
      _sub = _prefs.watchBool(
        widget.dependentKey,
        (data) {
          setState(() {
            _isDependetPreferenceEnabled =
                widget?.disableWhenDependent?.call(data) == false;
          });
        },
        defaultValue: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.dependentKey != null && _isDependetPreferenceEnabled != null
        ? _isDependetPreferenceEnabled
        : widget.isEnabled ?? true;

    final preference = AnimatedOpacity(
      opacity: isEnabled ? 1.0 : .5,
      duration: const Millis(200),
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: buildPreference(),
      ),
    );

    if (widget.show == null) {
      return preference;
    } else {
      return AnimatedSizeFade(
        show: widget.show,
        duration: const Millis(500),
        child: preference,
      );
    }
  }

  Widget buildPreference() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    Widget leading = widget.leading;
    if (leading is Icon) {
      leading = Container(
        width: 40,
        alignment: Alignment.center,
        child: leading,
      );
    }

    Widget trailing = widget.trailing;
    if (trailing is Icon) {
      trailing = Container(
        width: 40,
        alignment: Alignment.center,
        child: trailing,
      );
    }

    final reserveIconSpace = widget.reserveIconSpace ??
        PreferenceGroup.of(context)?.reserveIconSpace ??
        PreferencePage.of(context)?.reserveIconSpace ??
        false;

    final title = widget.title is String
        ? Text(
            widget.title,
            style: textTheme.subtitle1,
          )
        : widget.title;

    final summary = widget.summary is String
        ? AnimatedSwitcherText(
            widget.summary,
            duration: const Millis(350),
            curve: Curves.ease,
            style: textTheme.subtitle2,
          )
        : widget.summary;

    return AnimatedSizeChanges(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
      child: ListBox(
        title: title,
        subtitle: summary,
        leading: leading,
        trailing: trailing,
        reserveIconSpace: reserveIconSpace,
        onTap: widget.onTap,
        padding: widget.padding ?? const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class _CheckableBasePreference extends StatefulWidget {
  final bool isChecked;
  final String prefsKey;
  final bool defaultValue;
  final void Function(bool value) onChanged;
  final String dependentKey;
  final bool Function(dynamic value) disableWhenDependent;
  final bool isEnabled;
  final bool reserveIconSpace;
  final dynamic title;
  final dynamic summary;
  final dynamic summaryActive;
  final dynamic summaryInActive;
  final Widget leading;
  final Widget Function(bool value, void Function(bool) set) trailing;
  final EdgeInsets padding;
  final bool show;
  const _CheckableBasePreference({
    Key key,
    this.prefsKey,
    this.defaultValue,
    this.isChecked = false,
    this.summaryActive,
    this.summaryInActive,
    this.onChanged,
    this.dependentKey = '',
    this.disableWhenDependent,
    this.isEnabled = true,
    this.reserveIconSpace ,
    this.title,
    this.summary,
    this.leading,
    @required this.trailing,
    this.padding,
    this.show,
  })  : assert(prefsKey == null || (prefsKey != null && defaultValue != null)),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _CheckableBasePreferenceState();
}

class _CheckableBasePreferenceState<P extends _CheckableBasePreference> extends State<P> {
  StreamSubscription _sub;
  Preferences _prefs;

  bool value = false;
  bool get isChecked => value ?? false;

  bool get hasKey => widget.prefsKey != null;

  @override
  void initState() {
    super.initState();

    if (hasKey) {
      watchKey();
    } else {
      value = widget.isChecked;
    }
  }

  @override
  void didUpdateWidget(_CheckableBasePreference oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.prefsKey != widget.prefsKey) {
      widget.prefsKey == null ? _sub?.cancel() : watchKey();
    }

    if (!hasKey) {
      value = widget.isChecked;
    }
  }

  Future<void> watchKey() async {
    _prefs ??= Preferences(await StreamingSharedPreferences.instance);

    _sub = _prefs.watchBool(
      widget.prefsKey,
      (v) => setState(() => value = v),
      defaultValue: widget.defaultValue,
    );
  }

  Future setChecked(bool checked) async {
    if (hasKey) {
      await _prefs.setBool(widget.prefsKey, checked);
    }

    widget.onChanged?.call(checked);
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding ?? const EdgeInsets.all(16);

    return Preference(
      onTap: () => setChecked(!isChecked),
      title: widget.title,
      summary: getSummary(),
      leading: widget.leading,
      isEnabled: widget.isEnabled,
      trailing: widget.trailing(isChecked, setChecked),
      dependentKey: widget.dependentKey,
      reserveIconSpace: widget.reserveIconSpace,
      disableWhenDependent: widget.disableWhenDependent,
      padding: getSummary() == null
          ? EdgeInsets.fromLTRB(padding.left, 8, padding.right, 8)
          : widget.padding,
      show: widget.show,
    );
  }

  dynamic getSummary() {
    if (widget.summaryActive != null && isChecked) {
      return widget.summaryActive;
    } else if (widget.summaryInActive != null && !isChecked) {
      return widget.summaryInActive;
    }

    return widget.summary;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class SwitchPreference extends _CheckableBasePreference {
  SwitchPreference({
    bool isChecked = false,
    String prefsKey,
    bool defaultValue,
    Key key,
    String dependentKey,
    bool isEnabled,
    bool reserveIconSpace,
    @required dynamic title,
    dynamic summary,
    dynamic summaryActive,
    dynamic summaryInActive,
    void Function(bool value) onChanged,
    bool Function(dynamic value) disableWhenDependent,
    Widget leading,
    EdgeInsets padding,
    bool show,
  }) : super(
          key: key,
          prefsKey: prefsKey,
          defaultValue: defaultValue,
          isChecked: isChecked,
          dependentKey: dependentKey,
          disableWhenDependent: disableWhenDependent,
          isEnabled: isEnabled,
          reserveIconSpace: reserveIconSpace,
          title: title,
          summary: summary,
          summaryActive: summaryActive,
          summaryInActive: summaryInActive,
          onChanged: onChanged,
          leading: leading,
          padding: padding,
          show: show,
          trailing: (value, set) => Switch(
            value: isChecked,
            onChanged: (checked) => set(checked),
          ),
        );
}

class CheckBoxPreference extends _CheckableBasePreference {
  CheckBoxPreference({
    String prefsKey,
    bool defaultValue,
    Key key,
    String dependentKey,
    bool isEnabled,
    bool reserveIconSpace ,
    @required dynamic title,
    dynamic summary,
    dynamic summaryActive,
    dynamic summaryInActive,
    void Function(bool value) onChanged,
    bool Function(dynamic value) disableWhenDependent,
    Widget leading,
    EdgeInsets padding,
    bool show,
  }) : super(
          key: key,
          prefsKey: prefsKey,
          defaultValue: defaultValue,
          dependentKey: dependentKey,
          disableWhenDependent: disableWhenDependent,
          isEnabled: isEnabled,
          reserveIconSpace: reserveIconSpace,
          title: title,
          summary: summary,
          summaryActive: summaryActive,
          summaryInActive: summaryInActive,
          onChanged: onChanged,
          leading: leading,
          padding: padding,
          show: show,
          trailing: (value, set) => Checkbox(
            value: value,
            onChanged: (checked) => set(checked),
          ),
        );
}

class PreferenceGroup extends StatelessWidget {
  final String title;
  final TextTheme style;
  final List<Widget> children;
  final bool isEnabled;
  final bool reserveIconSpace;
  const PreferenceGroup({
    Key key,
    this.title,
    @required this.children,
    this.style,
    this.isEnabled = true,
    this.reserveIconSpace,
  }) : super(key: key);

  static PreferenceGroup of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<PreferenceGroup>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final reserveIconSpace =
        this.reserveIconSpace ?? PreferencePage.of(context)?.reserveIconSpace ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null) const SizedBox(height: 8),
        if (title != null)
          Padding(
            padding: EdgeInsets.fromLTRB(reserveIconSpace ? 72 : 16, 8, 16, 8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style ??
                  textTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.accentColor,
                    fontSize: 14,
                  ),
            ),
          ),
        AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class PreferencePage extends StatefulWidget {
  final bool reserveIconSpace;

  /// Type is dynamic because usually you should hide
  /// the implementation using dependency injection.
  ///
  /// If this is not of type [AppPreference], no listener
  /// will be attached.
  final dynamic prefs;

  final WidgetBuilder builder;
  const PreferencePage({
    Key key,
    this.reserveIconSpace = false,
    @required this.prefs,
    @required this.builder,
  }) : super(key: key);

  static PreferencePage of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<PreferencePage>();
  }

  @override
  _PreferencePageState createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  @override
  void initState() {
    super.initState();

    whenAppPreferences((prefs) => prefs.addListener(_onPreferencesChanged));
  }

  void whenAppPreferences(void Function(AppPreferences prefs) callback) {
    final prefs = widget.prefs;

    if (prefs is AppPreferences) {
      callback(prefs);
    }
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  void dispose() {
    whenAppPreferences((prefs) => prefs.removeListener(_onPreferencesChanged));
    super.dispose();
  }
}

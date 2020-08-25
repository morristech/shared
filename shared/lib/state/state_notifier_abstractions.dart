/* import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:state_notifier/state_notifier.dart';

import 'package:shared/shared.dart';

abstract class Cubit<S> extends StateNotifier<S> {
  Cubit(S state) : super(state);

  @override
  S get state => super.state;

  void emit(S state) => this.state = state;
}

class CubitBuilder<C extends Cubit<S>, S> extends StatelessWidget {
  /// A callback that builds a [Widget] based on the current value of [stateNotifier]
  ///
  /// Cannot be `null`.
  final Widget Function(BuildContext context, S value) builder;

  /// The listened [Cubit].
  final C cubit;

  /// A cache of a subtree that does not depend on [stateNotifier].
  ///
  /// It will be sent untouched to [builder]. This is useful for performance
  /// optimizations to not rebuild the entire widget tree if it isn't needed.
  final Widget child;
  CubitBuilder({
    @required this.builder,
    this.cubit,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StateNotifierBuilder<S>(
      // ignore: invalid_use_of_protected_member
      builder: (context, state, _) => builder(context, state),
      stateNotifier: cubit ?? Provider.of<C>(context, listen: false),
      child: child,
    );
  }
}

abstract class CubitProvider<C extends Cubit<S>, S> extends StatelessWidget {
  factory CubitProvider({
    @required Create<C> create,
    bool lazy,
    TransitionBuilder builder,
    Widget child,
  }) = _CubitProvider<C, S>;

  factory CubitProvider.value({
    @required C value,
    TransitionBuilder builder,
    Widget child,
  }) = _CubitProviderValue<C, S>;
}

class _CubitProvider<C extends Cubit<S>, S> extends StatelessWidget implements CubitProvider<C, S> {
  final Create<C> create;
  final bool lazy;
  final TransitionBuilder builder;
  final Widget child;
  _CubitProvider({
    Key key,
    @required this.create,
    this.lazy,
    this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<C, S>(
      create: create,
      builder: builder,
      lazy: lazy,
      child: Builder(
        builder: (context) => child,
      ),
    );
  }
}

class _CubitProviderValue<C extends Cubit<S>, S> extends StatelessWidget implements CubitProvider<C, S> {
  final C value;
  final TransitionBuilder builder;
  final Widget child;
  _CubitProviderValue({
    Key key,
    @required this.value,
    this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<C, S>.value(
      value: value,
      builder: builder,
      child: child,
    );
  }
}

extension CubitExtension on BuildContext {
  C cubit<C extends Cubit>() => Provider.of<C>(this, listen: false);
}
 */
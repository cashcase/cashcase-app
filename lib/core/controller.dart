import 'package:cashcase/core/app/controller.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

enum ScreenSizeType {
  tablet,
  desktop,
  mobile,
}

typedef ViewBuilder = Widget Function(BuildContext context);

abstract class ResponsiveViewState<C extends Controller>
    extends StatelessWidget {
  C Function() create;
  ResponsiveViewState({
    required this.create,
  });

  Widget get watchView;

  Widget get mobileView;

  Widget get tabletView;

  Widget get desktopView;

  Widget get view {
    return ScreenTypeLayout.builder(
      mobile: (_) => mobileView,
      tablet: (_) => tabletView,
      desktop: (_) => desktopView,
      watch: (_) => watchView,
    );
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<C>(
      create: (context) => create(),
      builder: (_, __) {
        return ControlledView<C>(
          builder: (controller, app) {
            return view;
          },
        );
      },
    );
  }
}

abstract class ResponsivePageState<Page extends ResponsiveView,
    C extends Controller> extends PageState<Page, C> {
  ResponsivePageState(super.controller);

  AppView get watchView;

  AppView get mobileView;

  AppView get tabletView;

  AppView get desktopView;

  @override
  @nonVirtual
  Widget get view {
    return ScreenTypeLayout.builder(
      mobile: (_) => mobileView,
      tablet: (_) => tabletView,
      desktop: (_) => desktopView,
      watch: (_) => watchView,
    );
  }
}

abstract class PageState<Page extends ResponsiveView, C extends Controller>
    extends State<Page> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  final C _controller;
  late Logger _logger;
  late ViewBuilder builder;

  Widget get view;

  PageState(this._controller) {
    _controller.initController(globalKey);
    WidgetsBinding.instance.addObserver(_controller);
    _logger = Logger('$runtimeType');
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (widget.routeObserver != null) {
      _logger.info('$runtimeType is observing route events.');
      widget.routeObserver!.subscribe(_controller, ModalRoute.of(context)!);
    }

    _logger.info('didChangeDependencies triggered on $runtimeType');
    _controller.onDidChangeDependencies();
    super.didChangeDependencies();
  }

  @override
  @nonVirtual
  void initState() {
    _logger.info('Initializing state of $runtimeType');
    _controller.onInitState();
    super.initState();
  }

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<C>(
      create: (_) => _controller,
      builder: (_, __) {
        return view;
      },
    );
  }

  @override
  @mustCallSuper
  void deactivate() {
    _logger.info(
        'Deactivating $runtimeType. (This is usually called right before dispose)');
    _controller.onDeactivated();
    super.deactivate();
  }

  @override
  @mustCallSuper
  void reassemble() {
    _logger.info('Reassembling $runtimeType.');
    _controller.onReassembled();
    super.reassemble();
  }

  @override
  @mustCallSuper
  void dispose() {
    _logger.info('Disposing $runtimeType.');
    _controller.onDisposed();
    super.dispose();
  }
}

abstract class ResponsiveView extends StatefulWidget {
  @override
  final Key? key;
  final RouteObserver? routeObserver;

  const ResponsiveView({this.routeObserver, this.key}) : super(key: key);
}

//
typedef ControlledBuilder<C extends Controller> = Widget Function(
    C controller, AppController app);

//
class ControlledView<C extends Controller> extends StatelessWidget {
  final ControlledBuilder<C> builder;

  const ControlledView({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<C>(
      builder: (context, controller, child) {
        return builder(controller, Provider.of<AppController>(context));
      },
    );
  }
}

abstract class AppView extends StatelessWidget {
  const AppView({super.key});
  @override
  ControlledView build(BuildContext context);
}

extension ContextExtension on BuildContext {
  T once<T>() {
    return Provider.of<T>(this, listen: false);
  }

  T listen<T>() {
    return Provider.of<T>(this, listen: true);
  }

  void clearAndReplace(String path, {Object? extra}) {
    while (GoRouter.of(this).canPop() == true) {
      GoRouter.of(this).pop();
    }
    GoRouter.of(this).pushReplacement(path, extra: extra);
  }

  void attemptPop() {
    if (canPop()) pop();
  }
}

abstract class Controller
    with WidgetsBindingObserver, RouteAware, ChangeNotifier {
  late bool _isMounted;
  late Logger logger;
  late GlobalKey<State<StatefulWidget>> _globalKey;

  // ignore: invalid_annotation_target
  @mustCallSuper
  Controller() {
    logger = Logger('$runtimeType');
    _isMounted = true;
    initListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isMounted) {
      switch (state) {
        case AppLifecycleState.inactive:
          onInActive();
          break;
        case AppLifecycleState.paused:
          onPaused();
          break;
        case AppLifecycleState.resumed:
          onResumed();
          break;
        case AppLifecycleState.detached:
          onDetached();
          break;
        default:
          break;
      }
    }
  }

  @protected
  void refreshUI() {
    if (_isMounted) {
      notifyListeners();
    }
  }

  @mustCallSuper
  void onDisposed() {
    assert(
        _globalKey.currentContext == null,
        'Make sure you are not calling `dispose` in any other call. This '
        'method should only be called from view `dispose` method.'
        'Also, the usage of context `onDispose` lifecycle is unsafe and '
        'it may lead to errors. If you need to remove any resources from the'
        'tree, please check if `onDeactivate` lifecycle, that controls '
        '`deactivate` view state are enough to your case.');
    dispose();
  }

  @override
  @nonVirtual
  void dispose() {
    _isMounted = false;
    logger.info('Disposing $runtimeType');
    super.dispose();
  }

  @protected
  State<StatefulWidget> getState() {
    assert(
        _globalKey.currentState != null,
        'Make sure you are using the `globalKey` that is built into the '
        '`ViewState` inside your `build()` method.');

    return _globalKey.currentState!;
  }

  @protected
  GlobalKey<State<StatefulWidget>> getStateKey() {
    return _globalKey;
  }

  void initController(GlobalKey<State<StatefulWidget>> key) {
    _globalKey = key;
  }

  @protected
  BuildContext getContext() {
    assert(_globalKey.currentContext != null,
        '''Make sure you are using the `globalKey` that is built into the `ViewState` inside your `build()` method.
        For example:
        `key: globalKey,` Otherwise, there is no context that the `Controller` could access.
        If this does not solve the issue, please open an issue at `https://github.com/ShadyBoukhary/flutter_clean_architecture` describing 
     the error.''');

    return _globalKey.currentContext!;
  }

  @protected
  void initListeners();

  @visibleForOverriding
  void onInActive() {}

  @visibleForOverriding
  void onPaused() {}

  @visibleForOverriding
  void onResumed() {}

  @visibleForOverriding
  void onDetached() {}

  @visibleForOverriding
  void onDeactivated() {}

  @visibleForOverriding
  void onReassembled() {}

  @visibleForOverriding
  void onDidChangeDependencies() {}

  @visibleForOverriding
  void onInitState() {}
}

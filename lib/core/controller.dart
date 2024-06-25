import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
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

/**
 * Step 1: Create Page that extends BasePage
 */
abstract class BasePage extends StatefulWidget {
  @override
  final Key? key;
  final RouteObserver? routeObserver;

  const BasePage({this.routeObserver, this.key}) : super(key: key);
}

/**
 * Step 2: Create View that extends BaseView
 */
abstract class BaseView<Page extends BasePage, C extends Controller>
    extends PageState<Page, C> {
  BaseView(super.controller);

  Widget get watchView;

  Widget get mobileView;

  Widget get tabletView;

  Widget get desktopView;

  @override
  @nonVirtual
  Widget get view {
    return BaseConsumer<C>(builder: (controller, app) {
      return ScreenTypeLayout.builder(
        mobile: (_) => mobileView,
        tablet: (_) => tabletView,
        desktop: (_) => desktopView,
        watch: (_) => watchView,
      );
    });
  }
}

/**
 * Step 3: Create Widget that extends BaseWidget
 */
abstract class BaseWidget extends StatelessWidget {
  const BaseWidget({super.key});
  @override
  BaseConsumer build(BuildContext context);
}

/**
 * Step 4: Create Controller for Page that extends Controller
 */
abstract class Controller
    with WidgetsBindingObserver, RouteAware, ChangeNotifier {
  late bool _isMounted;
  late Logger logger;
  late GlobalKey<State<StatefulWidget>> _globalKey;

  BuildContext get context =>
      AppController.router.routerDelegate.navigatorKey.currentContext!;

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

/**
 * NOT USED DIRECTLY IN CODE
 */
class BaseConsumer<C extends Controller> extends StatelessWidget {
  final Widget Function(C controller, AppController app) builder;
  const BaseConsumer({super.key, required this.builder});
  @override
  Widget build(BuildContext context) {
    return Consumer<C>(
      builder: (context, controller, child) {
        return builder(controller, context.once<AppController>());
      },
    );
  }
}

/**
 * NOT USED DIRECTLY IN CODE
 */
abstract class PageState<Page extends BasePage, C extends Controller>
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
    if (_controller._isMounted) _controller.onDeactivated();
    super.deactivate();
  }

  @override
  @mustCallSuper
  void reassemble() {
    _logger.info('Reassembling $runtimeType.');
    if (_controller._isMounted) _controller.onReassembled();
    super.reassemble();
  }

  @override
  @mustCallSuper
  void dispose() {
    _logger.info('Disposing $runtimeType.');
    if (_controller._isMounted) _controller.onDisposed();
    super.dispose();
  }
}

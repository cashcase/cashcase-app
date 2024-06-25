import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/base/page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

/**
 * Step 3: Create Controller for Page that extends Controller
 */
abstract class BaseController
    with WidgetsBindingObserver, RouteAware, ChangeNotifier {
  late bool _isMounted;
  late Logger logger;
  late GlobalKey<State<StatefulWidget>> _globalKey;

  BuildContext get context =>
      AppController.router.routerDelegate.navigatorKey.currentContext!;

  // ignore: invalid_annotation_target
  @mustCallSuper
  BaseController() {
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
  void notify() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        notifyListeners();
      }
    });
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
abstract class PageState<Page extends BasePage, C extends BaseController>
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

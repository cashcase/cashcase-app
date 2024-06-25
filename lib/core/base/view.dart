import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

enum ScreenSizeType {
  tablet,
  desktop,
  mobile,
}

/**
 * Step 2: Create View that extends BaseView
 */
abstract class BaseView<Page extends BasePage, C extends BaseController>
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
 * NOT USED DIRECTLY IN CODE
 */
class BaseConsumer<C extends BaseController> extends StatelessWidget {
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

import 'package:flutter/widgets.dart';

class PlaceObserver extends NavigatorObserver {
  PlaceObserver(this.place);

  String place;

  void _show(Route<dynamic>? route) {
    if (route is PageRoute && route.settings.name != null) place = route.settings.name!;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _show(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _show(previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _show(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _show(newRoute);
}

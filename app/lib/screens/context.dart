import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import 'groups_screen.dart';
import 'head_to_head_screen.dart';
import 'place_screen.dart';
import 'wrestler_screen.dart';

extension Context on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get localeName => Localizations.localeOf(this).toString();

  String date(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed == null ? '' : DateFormat.yMd(localeName).format(parsed);
  }

  String decimal(num value) => NumberFormat('0.00', localeName).format(value);

  String points(String value) {
    final parsed = double.tryParse(value);
    return parsed == null ? value : decimal(parsed);
  }
}

void openWrestler(BuildContext context, Queries queries, String id) => Navigator.of(context).push(
  MaterialPageRoute(
    settings: RouteSettings(name: '/wrestler/$id'),
    builder: (_) => WrestlerScreen(queries: queries, id: id),
  ),
);

void openGroup(BuildContext context, Queries queries, GroupLevel level, String id) => Navigator.of(context).push(
  MaterialPageRoute(
    settings: RouteSettings(name: '/associations/${level.name}/$id'),
    builder: (_) => GroupScreen(queries: queries, level: level, id: id),
  ),
);

void openPlace(BuildContext context, Queries queries, String id) => Navigator.of(context).push(
  MaterialPageRoute(
    settings: RouteSettings(name: '/rankings/$id'),
    builder: (_) => PlaceScreen(queries: queries, id: id),
  ),
);

void openHeadToHead(BuildContext context, Queries queries, Person first, Person second) => Navigator.of(context).push(
  MaterialPageRoute(
    settings: RouteSettings(name: '/head2head/${first.id}-${second.id}'),
    builder: (_) => HeadToHeadScreen(queries: queries, first: first, second: second),
  ),
);

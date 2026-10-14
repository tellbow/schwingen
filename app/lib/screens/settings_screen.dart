import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/release.dart';
import '../settings.dart';
import 'context.dart';
import 'data_gate.dart';
import 'widgets.dart';

final websiteUrl = Uri.parse('https://schwingen.tellbow.ch');
final sourceUrl = Uri.parse('https://esv.ch');

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.dataTag,
    required this.dataBytes,
    required this.onCheck,
    required this.onReload,
  });

  final Settings settings;
  final String? dataTag;
  final int dataBytes;
  final Future<Release?> Function() onCheck;
  final VoidCallback onReload;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _info = PackageInfo.fromPlatform();
  Future<Release?>? _check;

  Future<void> _confirmReload() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reloadData),
        content: Text(l10n.reloadDataText),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.reload)),
        ],
      ),
    );
    if (confirmed == true) widget.onReload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = widget.settings;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Section(
              title: l10n.appearance,
              children: [
                _Choice<ThemeMode>(
                  selected: settings.themeMode,
                  onSelected: settings.setThemeMode,
                  options: {ThemeMode.system: l10n.system, ThemeMode.light: l10n.light, ThemeMode.dark: l10n.dark},
                ),
              ],
            ),
            Section(
              title: l10n.language,
              children: [
                _Choice<String>(
                  selected: settings.locale?.languageCode ?? '',
                  onSelected: (code) => settings.setLocale(code.isEmpty ? null : Locale(code)),
                  options: {'': l10n.system, 'de': 'Deutsch', 'fr': 'Français'},
                ),
              ],
            ),
            Section(
              title: l10n.data,
              children: [
                ListTile(
                  title: Text(l10n.installedData),
                  subtitle: Text(l10n.dataInstalled(widget.dataTag ?? '–', megabytes(widget.dataBytes))),
                ),
                FutureBuilder(
                  future: _check,
                  builder: (context, snapshot) {
                    final checking = snapshot.connectionState == ConnectionState.waiting;
                    final done = snapshot.connectionState == ConnectionState.done;
                    final release = snapshot.data;
                    return ListTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(l10n.checkForData),
                      subtitle: !done
                          ? null
                          : Text(
                              snapshot.hasError
                                  ? l10n.failed('${snapshot.error}')
                                  : release == null
                                  ? l10n.upToDate
                                  : l10n.updateAvailable(release.tag, megabytes(release.size)),
                            ),
                      trailing: checking
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator.adaptive())
                          : null,
                      onTap: checking
                          ? null
                          : () => setState(() {
                              _check = widget.onCheck();
                            }),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.reloadData),
                  onTap: _confirmReload,
                ),
              ],
            ),
            Section(
              title: l10n.about,
              children: [
                FutureBuilder(
                  future: _info,
                  builder: (context, snapshot) => ListTile(
                    title: Text(l10n.version),
                    subtitle: Text(switch (snapshot.data) {
                      final info? => '${info.version} (${info.buildNumber})',
                      null => '–',
                    }),
                  ),
                ),
                _LinkTile(title: l10n.website, url: websiteUrl),
                _LinkTile(title: l10n.dataSource, subtitle: l10n.dataSourceText, url: sourceUrl),
                FutureBuilder(
                  future: _info,
                  builder: (context, snapshot) => ListTile(
                    title: Text(l10n.licenses),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: l10n.appTitle,
                      applicationVersion: snapshot.data?.version,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice<T> extends StatelessWidget {
  const _Choice({required this.selected, required this.onSelected, required this.options});

  final T selected;
  final ValueChanged<T> onSelected;
  final Map<T, String> options;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: SegmentedButton<T>(
      showSelectedIcon: false,
      segments: [for (final MapEntry(:key, :value) in options.entries) ButtonSegment(value: key, label: Text(value))],
      selected: {selected},
      onSelectionChanged: (values) => onSelected(values.single),
    ),
  );
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.title, required this.url, this.subtitle});

  final String title;
  final String? subtitle;
  final Uri url;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title),
    subtitle: Text(subtitle ?? url.host),
    trailing: const Icon(Icons.open_in_new),
    onTap: () => launchUrl(url, mode: LaunchMode.externalApplication),
  );
}

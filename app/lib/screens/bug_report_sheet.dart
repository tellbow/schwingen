import 'package:flutter/material.dart';

import '../data/bug_report.dart';
import 'context.dart';

class BugReportSheet extends StatefulWidget {
  const BugReportSheet({super.key, required this.place, required this.send});

  final String place;
  final Future<void> Function(String description) send;

  @override
  State<BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<BugReportSheet> {
  final _text = TextEditingController();
  var _sending = false;
  var _sent = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.send(_text.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = e is BugReportException && e.busy ? l10n.bugBusy : l10n.bugFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: _sent
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.bugSent),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Text(l10n.bugReport, style: theme.textTheme.titleMedium),
                    TextField(
                      controller: _text,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 4000,
                      decoration: InputDecoration(labelText: l10n.bugWhat, border: const OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    Text(
                      l10n.bugPrivacy(widget.place),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (_error case final error?) Text(error, style: TextStyle(color: theme.colorScheme.error)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 8,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                        FilledButton(
                          onPressed: _sending || _text.text.trim().isEmpty ? null : _send,
                          child: Text(l10n.bugSend),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

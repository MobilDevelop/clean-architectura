import 'dart:convert';

import 'package:colloborator_v3/core/network/interceptors/http_log_interceptor.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Staging'dagi HTTP so'rovlar ro'yxati.
final class HttpLogPage extends StatelessWidget {
  const HttpLogPage({super.key, required this.log});

  final HttpLog log;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: log,
      builder: (BuildContext context, Widget? child) {
        final List<HttpLogEntry> entries = log.entries;

        return Scaffold(
          backgroundColor: _Palette.background,
          appBar: AppBar(
            backgroundColor: _Palette.surface,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text('HTTP Logs', style: TextStyle(color: Colors.white, fontSize: ScreenSize.sp18)),
            actions: [
              if (entries.isNotEmpty)
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: log.clear),
            ],
          ),
          body: entries.isEmpty
              ? Center(
                  child: Text("Hali so'rovlar yo'q", style: TextStyle(color: Colors.white54, fontSize: ScreenSize.sp15)),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: ScreenSize.h8),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (BuildContext context, int index) => _RequestTile(entry: entries[index], log: log),
                ),
        );
      },
    );
  }
}

/// Jurnaldagi tanani o'qiladigan matnga aylantiradi.
abstract final class HttpLogFormat {
  // Kodlab bo'lmaydigan qiymat matnga aylanadi — formatlash hech qachon otilmaydi.
  static const JsonEncoder _json = JsonEncoder.withIndent('  ', _asText);

  static Object? _asText(Object? value) => '$value';

  static String body(Object? value) => switch (value) {
    final String text => text,
    final List<int> bytes => '<${bytes.length} bayt>',
    Stream<Object?>() => '<oqim>',
    final FormData form => _formData(form),
    _ => _json.convert(value),
  };

  static String _formData(FormData form) => [
    for (final MapEntry<String, String> field in form.fields) '${field.key}: ${field.value}',
    for (final MapEntry<String, MultipartFile> file in form.files)
      '${file.key}: ${file.value.filename ?? '-'} (${file.value.length} bayt)',
  ].join('\n');
}

// Ilova mavzusidan ataylab alohida: bu ekran ish ekrani bilan adashtirilmasin.
abstract final class _Palette {
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
}

Color _statusColor(HttpLogEntry entry) {
  if (entry.isPending) return Colors.orangeAccent;

  return entry.hasError ? Colors.redAccent : Colors.greenAccent;
}

String _statusText(HttpLogEntry entry) => entry.statusCode?.toString() ?? (entry.isPending ? 'yuborilmoqda...' : '---');

String _clock(DateTime time) =>
    [time.hour, time.minute, time.second].map((int part) => part.toString().padLeft(2, '0')).join(':');

final class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.entry, required this.log});

  final HttpLogEntry entry;
  final HttpLog log;

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(entry);
    final Duration? duration = entry.duration;

    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => _DetailPage(entry: entry, log: log)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: ScreenSize.w16, vertical: ScreenSize.h4),
      leading: Container(
        width: ScreenSize.w52,
        height: ScreenSize.h32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(ScreenSize.r6),
          border: Border.all(color: color.withValues(alpha: .4)),
        ),
        child: entry.isPending
            ? SizedBox.square(
                dimension: ScreenSize.h14,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Text(
                _statusText(entry),
                style: TextStyle(color: color, fontSize: ScreenSize.sp12, fontWeight: FontWeight.bold),
              ),
      ),
      title: Text(
        entry.url.path,
        style: TextStyle(color: Colors.white, fontSize: ScreenSize.sp13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          _Badge(entry.method, Colors.blueAccent),
          if (entry.isPending) ...[
            Gap(ScreenSize.w6),
            Text('yuborilmoqda...', style: TextStyle(color: Colors.orangeAccent, fontSize: ScreenSize.sp11)),
          ],
          if (duration != null) ...[
            Gap(ScreenSize.w6),
            Text('${duration.inMilliseconds}ms', style: TextStyle(color: Colors.white38, fontSize: ScreenSize.sp11)),
          ],
          if (entry.error case final String error) ...[
            Gap(ScreenSize.w6),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.redAccent, fontSize: ScreenSize.sp11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      trailing: Text(_clock(entry.sentAt), style: TextStyle(color: Colors.white38, fontSize: ScreenSize.sp11)),
    );
  }
}

final class _DetailPage extends StatefulWidget {
  const _DetailPage({required this.entry, required this.log});

  final HttpLogEntry entry;
  final HttpLog log;

  @override
  State<_DetailPage> createState() => _DetailPageState();
}

final class _DetailPageState extends State<_DetailPage> {
  @override
  void initState() {
    super.initState();
    // Faqat javob kelguncha tinglanadi: yakunlangan yozuv o'zgarmaydi, jurnaldagi
    // har yangi so'rovda katta tanani qayta formatlab chizish esa ekranni sekinlashtirardi.
    if (widget.entry.isPending) widget.log.addListener(_onLogChanged);
  }

  @override
  void dispose() {
    widget.log.removeListener(_onLogChanged);
    super.dispose();
  }

  void _onLogChanged() {
    if (widget.entry.isPending) return;

    widget.log.removeListener(_onLogChanged);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final HttpLogEntry entry = widget.entry;
    final Duration? duration = entry.duration;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _Palette.background,
        appBar: AppBar(
          backgroundColor: _Palette.surface,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge(entry.method, Colors.blueAccent),
                  Gap(ScreenSize.w8),
                  Text(
                    _statusText(entry),
                    style: TextStyle(color: _statusColor(entry), fontSize: ScreenSize.sp14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                entry.url.path,
                style: TextStyle(color: Colors.white70, fontSize: ScreenSize.sp11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            indicatorColor: Colors.blueAccent,
            tabs: [Tab(text: 'Request'), Tab(text: 'Response')],
          ),
        ),
        body: TabBarView(
          children: [
            _InfoPanel(
              sections: [
                _Section('URL', entry.url.toString()),
                _Section('Headers', HttpLogFormat.body(entry.requestHeaders)),
                if (entry.requestBody != null) _Section('Body', HttpLogFormat.body(entry.requestBody)),
              ],
            ),
            _InfoPanel(
              sections: [
                _Section('Status', entry.statusCode?.toString() ?? (entry.isPending ? 'Kutilmoqda...' : "Javob yo'q")),
                if (duration != null) _Section('Duration', '${duration.inMilliseconds} ms'),
                if (entry.error case final String error) _Section('Error', error),
                if (entry.responseBody != null) _Section('Body', HttpLogFormat.body(entry.responseBody)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _Section {
  const _Section(this.title, this.content);

  final String title;
  final String content;
}

final class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.sections});

  final List<_Section> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(ScreenSize.h12),
      children: [for (final _Section section in sections) _SectionCard(section)],
    );
  }
}

final class _SectionCard extends StatelessWidget {
  const _SectionCard(this.section);

  // KATM javobi ~1.7 MB matn: `SelectableText` uni bir kadrda o'lchay olmay
  // ekranni qotiradi. Nusxalash baribir to'liq matnni oladi.
  static const int _previewLimit = 20000;

  final _Section section;

  @override
  Widget build(BuildContext context) {
    final String content = section.content;
    final int hidden = content.length - _previewLimit;
    final String preview = hidden > 0
        ? "${content.substring(0, _previewLimit)}\n\n… yana $hidden belgi — to'liq matn nusxalanganda olinadi"
        : content;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.h10),
      decoration: BoxDecoration(color: _Palette.surface, borderRadius: BorderRadius.circular(ScreenSize.r8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(ScreenSize.w12, ScreenSize.h10, ScreenSize.w12, ScreenSize.h6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  section.title,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: ScreenSize.sp11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: () => _copy(context, content),
                  child: Icon(Icons.copy, size: ScreenSize.h14, color: Colors.white38),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: EdgeInsets.all(ScreenSize.h12),
            child: SelectableText(
              preview,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenSize.sp12,
                // iOS'da `monospace` oilasi yo'q.
                fontFamily: 'monospace',
                fontFamilyFallback: const <String>['Menlo', 'Courier'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nusxalandi'), duration: Duration(seconds: 1)),
    );
  }
}

final class _Badge extends StatelessWidget {
  const _Badge(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.w6, vertical: ScreenSize.h2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(ScreenSize.r4),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: ScreenSize.sp10, fontWeight: FontWeight.bold)),
    );
  }
}

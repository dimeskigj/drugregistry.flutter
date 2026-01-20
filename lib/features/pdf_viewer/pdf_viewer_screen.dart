import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final Uri url;

  const PdfViewerScreen({super.key, required this.title, required this.url});

  static Route<void> route({required String title, required Uri url}) {
    return MaterialPageRoute(
      builder:
          (context) =>
              PdfViewerScreen(title: title, url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed:
                () => launchUrl(url, mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: PdfViewer.uri(
        url,
        params: PdfViewerParams(
          loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
            return Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBannerBuilder: (context, error, stackTrace, documentRef) {
            return Container(
              color: Theme.of(context).colorScheme.surface,
              child: _PdfErrorDisplay(error: error),
            );
          },
        ),
      ),
    );
  }
}

class _PdfErrorDisplay extends StatefulWidget {
  final Object error;
  const _PdfErrorDisplay({required this.error});

  @override
  State<_PdfErrorDisplay> createState() => _PdfErrorDisplayState();
}

class _PdfErrorDisplayState extends State<_PdfErrorDisplay> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Неуспешно вчитување на документот.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_expanded ? 'Сокриј детали' : 'Прикажи детали'),
              ),
              if (_expanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SelectableText(
                    '${widget.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

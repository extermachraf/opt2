import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class PdfViewerModal extends StatefulWidget {
  const PdfViewerModal({Key? key}) : super(key: key);

  @override
  State<PdfViewerModal> createState() => _PdfViewerModalState();
}

class _PdfViewerModalState extends State<PdfViewerModal> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdfFromAssets();
  }

  Future<void> _loadPdfFromAssets() async {
    try {
      // Load PDF from assets and copy to temporary directory
      final ByteData data = await rootBundle.load('assets/documents/Informativa sulla Privacy (1).pdf');
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/informativa_privacy.pdf');

      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      setState(() {
        _localPath = tempFile.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Errore nel caricamento del documento: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'INFORMATIVA SULLA PRIVACY',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // PDF Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Caricamento documento...',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Text(
                              _error!,
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _localPath != null
                          ? PDFView(
                              filePath: _localPath!,
                              enableSwipe: true,
                              swipeHorizontal: false,
                              autoSpacing: false,
                              pageFling: true,
                              pageSnap: true,
                              fitPolicy: FitPolicy.BOTH,
                              fitEachPage: true,
                              defaultPage: 0,
                              preventLinkNavigation: false,
                              onRender: (pages) {
                                setState(() {
                                  _totalPages = pages ?? 0;
                                });
                              },
                              onPageChanged: (page, total) {
                                setState(() {
                                  _currentPage = page ?? 0;
                                });
                              },
                              onError: (error) {
                                setState(() {
                                  _error = 'Errore nella visualizzazione: $error';
                                });
                              },
                            )
                          : Center(
                              child: Text(
                                'Documento non disponibile',
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                              ),
                            ),
            ),

            // Page indicator and close button
            if (!_isLoading && _error == null && _totalPages > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    // Page indicator
                    Text(
                      'Pagina ${_currentPage + 1} di $_totalPages',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimaryLight,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                        child: Text(
                          'Ho letto l\'informativa',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

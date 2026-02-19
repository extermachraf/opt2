import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class SharingService {
  static final SharingService _instance = SharingService._internal();
  static SharingService get instance => _instance;
  SharingService._internal();

  /// Share report via WhatsApp with generated PDF content
  Future<bool> shareViaWhatsApp(String reportContent, String filename) async {
    try {
      if (kIsWeb) {
        return await _shareViaWhatsAppWeb(reportContent);
      } else {
        return await _shareViaWhatsAppMobile(reportContent, filename);
      }
    } catch (e) {
      print('Error sharing via WhatsApp: $e');
      return false;
    }
  }

  /// Share report via other social platforms
  Future<bool> shareViaOtherPlatforms(
    String reportContent,
    String filename,
    String platform,
  ) async {
    try {
      if (kIsWeb) {
        return await _shareViaOtherPlatformsWeb(reportContent, platform);
      } else {
        return await _shareViaOtherPlatformsMobile(
          reportContent,
          filename,
          platform,
        );
      }
    } catch (e) {
      print('Error sharing via $platform: $e');
      return false;
    }
  }

  /// Share report using system share sheet
  Future<bool> shareViaSystemSheet(
      String reportContent, String filename) async {
    try {
      if (kIsWeb) {
        // Fallback to download on web
        final bytes = utf8.encode(reportContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        return true;
      } else {
        // Save to temp directory and share on mobile
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(reportContent);

        final result = await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Il mio Report Nutrizionale NutriVita',
          subject: 'Report Nutrizionale NutriVita',
        );

        return result.status == ShareResultStatus.success;
      }
    } catch (e) {
      print('Error sharing via system sheet: $e');
      return false;
    }
  }

  // Mobile WhatsApp sharing
  Future<bool> _shareViaWhatsAppMobile(
      String reportContent, String filename) async {
    try {
      // Save report to temp directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(reportContent);

      // Create WhatsApp URL with text message
      final message = '''
🏥 *Report Nutrizionale NutriVita*

📊 Il mio report nutrizionale personalizzato generato da NutriVita.

Scarica l'app NutriVita per monitorare la tua salute nutrizionale!

#NutriVita #Salute #Nutrizione
      ''';

      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = Uri.parse('https://wa.me/?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);

        // Also share the file via system sheet for the actual report
        await Share.shareXFiles(
          [XFile(file.path)],
          text: message,
          subject: 'Report Nutrizionale NutriVita',
        );

        return true;
      }
      return false;
    } catch (e) {
      print('Error in mobile WhatsApp sharing: $e');
      return false;
    }
  }

  // Web WhatsApp sharing
  Future<bool> _shareViaWhatsAppWeb(String reportContent) async {
    try {
      final message = '''
🏥 *Report Nutrizionale NutriVita*

📊 Il mio report nutrizionale personalizzato generato da NutriVita.

${_getReportSummary(reportContent)}

Scarica l'app NutriVita per monitorare la tua salute nutrizionale!

#NutriVita #Salute #Nutrizione
      ''';

      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = Uri.parse('https://wa.me/?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('Error in web WhatsApp sharing: $e');
      return false;
    }
  }

  // Mobile other platforms sharing
  Future<bool> _shareViaOtherPlatformsMobile(
    String reportContent,
    String filename,
    String platform,
  ) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(reportContent);

      String message = _getShareMessage(platform, reportContent);
      Uri? platformUrl = _getPlatformUrl(platform, message);

      if (platformUrl != null && await canLaunchUrl(platformUrl)) {
        await launchUrl(platformUrl, mode: LaunchMode.externalApplication);

        // Also share via system sheet
        await Share.shareXFiles(
          [XFile(file.path)],
          text: message,
          subject: 'Report Nutrizionale NutriVita',
        );

        return true;
      }

      // Fallback to system share
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: message,
        subject: 'Report Nutrizionale NutriVita',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      print('Error in mobile platform sharing: $e');
      return false;
    }
  }

  // Web other platforms sharing
  Future<bool> _shareViaOtherPlatformsWeb(
      String reportContent, String platform) async {
    try {
      String message = _getShareMessage(platform, reportContent);
      Uri? platformUrl = _getPlatformUrl(platform, message);

      if (platformUrl != null && await canLaunchUrl(platformUrl)) {
        await launchUrl(platformUrl, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      print('Error in web platform sharing: $e');
      return false;
    }
  }

  String _getShareMessage(String platform, String reportContent) {
    final summary = _getReportSummary(reportContent);

    switch (platform.toLowerCase()) {
      case 'telegram':
        return '''
🏥 *Report Nutrizionale NutriVita*

📊 Il mio report nutrizionale personalizzato:

$summary

Monitora la tua salute con NutriVita! 🌱
#NutriVita #Salute #Nutrizione
        ''';

      case 'email':
        return '''
🏥 Report Nutrizionale NutriVita

📊 Il mio report nutrizionale personalizzato generato da NutriVita.

$summary

Monitora la tua salute nutrizionale con NutriVita!

Cordiali saluti
        ''';

      case 'sms':
        return '''
🏥 Il mio Report Nutrizionale NutriVita

$summary

Scarica NutriVita per monitorare la tua salute!
        ''';

      default:
        return '''
🏥 Report Nutrizionale NutriVita

📊 Il mio report nutrizionale personalizzato.

$summary

#NutriVita #Salute #Nutrizione
        ''';
    }
  }

  Uri? _getPlatformUrl(String platform, String message) {
    final encodedMessage = Uri.encodeComponent(message);

    switch (platform.toLowerCase()) {
      case 'telegram':
        return Uri.parse('https://t.me/share/url?text=$encodedMessage');

      case 'email':
        return Uri.parse(
            'mailto:?subject=${Uri.encodeComponent("Report Nutrizionale NutriVita")}&body=$encodedMessage');

      case 'sms':
        return Uri.parse('sms:?body=$encodedMessage');

      case 'twitter':
      case 'x':
        // Limit message for Twitter character count
        final shortMessage = Uri.encodeComponent(_getShortMessage());
        return Uri.parse('https://twitter.com/intent/tweet?text=$shortMessage');

      default:
        return null;
    }
  }

  String _getReportSummary(String reportContent) {
    // Extract key metrics from report content
    try {
      final lines = reportContent.split('\n');
      String summary = '';

      for (String line in lines) {
        if (line.contains('Calorie Totali:') ||
            line.contains('Calorie Giornaliere Medie:') ||
            line.contains('Pasti Registrati:')) {
          summary += '📈 ${line.trim()}\n';
        }
        if (line.contains('Proteine Totali:') ||
            line.contains('Carboidrati Totali:') ||
            line.contains('Grassi Totali:')) {
          summary += '🥗 ${line.trim()}\n';
        }
      }

      return summary.isNotEmpty
          ? summary
          : '📊 Report nutrizionale completo disponibile!';
    } catch (e) {
      return '📊 Report nutrizionale completo disponibile!';
    }
  }

  String _getShortMessage() {
    return '''
🏥 Il mio Report Nutrizionale NutriVita 📊
Monitora la tua salute nutrizionale!
#NutriVita #Salute #Nutrizione
    ''';
  }

  /// Check if WhatsApp is available on the device
  Future<bool> isWhatsAppAvailable() async {
    try {
      if (kIsWeb) {
        return true; // Always available via web
      }

      const whatsappUrl = 'whatsapp://send';
      return await canLaunchUrl(Uri.parse(whatsappUrl));
    } catch (e) {
      return false;
    }
  }

  /// Check if platform-specific app is available
  Future<bool> isPlatformAvailable(String platform) async {
    try {
      if (kIsWeb) {
        return true; // Web versions available
      }

      String urlScheme = '';
      switch (platform.toLowerCase()) {
        case 'telegram':
          urlScheme = 'tg://';
          break;
        case 'twitter':
        case 'x':
          urlScheme = 'twitter://';
          break;
        default:
          return true; // Fallback to system share
      }

      if (urlScheme.isNotEmpty) {
        return await canLaunchUrl(Uri.parse(urlScheme));
      }

      return true;
    } catch (e) {
      return true; // Assume available, fallback to system share
    }
  }
}

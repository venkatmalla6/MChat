class UrlHelper {
  /// Converts a regular Google Drive share link into a direct image link.
  /// Example: https://drive.google.com/file/d/12345/view?usp=sharing
  /// To: https://drive.google.com/uc?export=view&id=12345
  static String convertDriveLink(String url) {
    String cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return cleanUrl;

    // Auto-add protocol if missing
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }

    if (!cleanUrl.contains("drive.google.com") && !cleanUrl.contains("docs.google.com")) return cleanUrl;

    // Pattern for /file/d/ID/...
    final fileIdRegExp = RegExp(r"\/file\/d\/([a-zA-Z0-9_-]+)");
    final match = fileIdRegExp.firstMatch(cleanUrl);

    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return "https://drive.google.com/uc?export=view&id=$id";
    }

    // Pattern for ?id=ID or &id=ID
    final idParamRegExp = RegExp(r"[?&]id=([a-zA-Z0-9_-]+)");
    final idMatch = idParamRegExp.firstMatch(cleanUrl);
    if (idMatch != null && idMatch.groupCount >= 1) {
      final id = idMatch.group(1);
      return "https://drive.google.com/uc?export=view&id=$id";
    }

    return cleanUrl;
  }
  
  /// Checks if a link is a Google Drive folder link.
  static bool isFolderLink(String url) {
    return url.contains("drive.google.com/drive/folders/") || url.contains("drive.google.com/open?id=");
  }

  /// Extracts the Google Drive folder ID.
  static String getFolderId(String url) {
    if (url.contains("/folders/")) {
      final regExp = RegExp(r"\/folders\/([a-zA-Z0-9_-]+)");
      final match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1)!;
    } else if (url.contains("id=")) {
      final regExp = RegExp(r"id=([a-zA-Z0-9_-]+)");
      final match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1)!;
    }
    return "";
  }
}

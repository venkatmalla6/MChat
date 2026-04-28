import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

enum UploadType { image, pdf }

class SelectedFileResult {
  final String fileName;
  final String filePath;
  final Uint8List fileBytes;
  final UploadType type;

  const SelectedFileResult({
    required this.fileName,
    required this.filePath,
    required this.fileBytes,
    required this.type,
  });
}

class FileService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Opens the gallery/camera to pick an image (JPG or PNG).
  Future<SelectedFileResult?> pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (pickedFile == null) return null;

    final bytes = await pickedFile.readAsBytes();

    return SelectedFileResult(
      fileName: pickedFile.name,
      filePath: pickedFile.path,
      fileBytes: bytes,
      type: UploadType.image,
    );
  }

  /// Opens the file picker to select a PDF.
  Future<SelectedFileResult?> pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: true, // Crucial for Web to get bytes
    );

    if (result == null || result.files.isEmpty) return null;

    final PlatformFile file = result.files.first;
    return SelectedFileResult(
      fileName: file.name,
      filePath: file.path ?? '',
      fileBytes: file.bytes!,
      type: UploadType.pdf,
    );
  }
}

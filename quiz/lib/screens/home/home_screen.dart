import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../services/file_service.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/selected_file_card.dart';
import '../../widgets/upload_option_card.dart';
import '../processing/processing_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FileService _fileService = FileService();
  SelectedFileResult? _selectedFile;
  bool _isLoading = false;

  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _handleImageUpload() async {
    setState(() => _isLoading = true);
    try {
      final result = await _fileService.pickImage();
      setState(() => _selectedFile = result);
    } catch (_) {
      _showError(AppStrings.errorFileSelection);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePdfUpload() async {
    setState(() => _isLoading = true);
    try {
      final result = await _fileService.pickPdf();
      setState(() => _selectedFile = result);
    } catch (_) {
      _showError(AppStrings.errorFileSelection);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToProcessing() {
    if (_selectedFile == null) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProcessingScreen(
          selectedFile: _selectedFile!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history_rounded, color: AppColors.primary),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Header ──────────────────────────────────────────
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.appTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.appSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Divider label ────────────────────────────────────
                Text(
                  AppStrings.chooseFileType.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: 16),

                // ── Upload Image Card ────────────────────────────────
                UploadOptionCard(
                  icon: Icons.image_rounded,
                  title: AppStrings.uploadImage,
                  subtitle: AppStrings.uploadImageSubtitle,
                  iconColor: AppColors.primary,
                  iconBackground: AppColors.primary.withValues(alpha: 0.12),
                  onTap: _isLoading ? () {} : _handleImageUpload,
                ),
                const SizedBox(height: 16),

                // ── Upload PDF Card ──────────────────────────────────
                UploadOptionCard(
                  icon: Icons.picture_as_pdf_rounded,
                  title: AppStrings.uploadPdf,
                  subtitle: AppStrings.uploadPdfSubtitle,
                  iconColor: AppColors.accent,
                  iconBackground: AppColors.accent.withValues(alpha: 0.12),
                  onTap: _isLoading ? () {} : _handlePdfUpload,
                ),

                const SizedBox(height: 32),

                // ── Selected File Display ────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _selectedFile != null
                      ? SelectedFileCard(
                          key: ValueKey(_selectedFile!.fileName),
                          fileName: _selectedFile!.fileName,
                          icon: _selectedFile!.type == UploadType.image
                              ? Icons.image_rounded
                              : Icons.picture_as_pdf_rounded,
                          iconColor: _selectedFile!.type == UploadType.image
                              ? AppColors.primary
                              : AppColors.accent,
                          onClear: () =>
                              setState(() => _selectedFile = null),
                        )
                      : const SizedBox.shrink(),
                ),

                if (_selectedFile != null) const SizedBox(height: 24),

                // ── Generate Quiz Button ─────────────────────────────
                GradientButton(
                  label: AppStrings.generateQuiz,
                  icon: Icons.rocket_launch_rounded,
                  onPressed:
                      _selectedFile != null ? _navigateToProcessing : null,
                ),

                SizedBox(height: size.height * 0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../services/file_service.dart';
import '../../services/api_service.dart';
import '../../widgets/gradient_button.dart';
import '../result/result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final SelectedFileResult selectedFile;

  const ProcessingScreen({
    super.key,
    required this.selectedFile,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _contentController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  final ApiService _apiService = ApiService();
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentController.forward();
        _processFile();
      }
    });
  }

  Future<void> _processFile() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final text = await _apiService.extractText(widget.selectedFile);

      if (!mounted) return;

      // Navigate to results
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResultScreen(extractedText: text),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isImage = widget.selectedFile.type == UploadType.image;
    final iconColor = _hasError ? AppColors.accent : (isImage ? AppColors.primary : AppColors.accent);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // Back button row
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      // ── Animated Loader ──────────────────────────────
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                iconColor.withValues(alpha: 0.25),
                                iconColor.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surfaceLight,
                                boxShadow: [
                                  BoxShadow(
                                    color: iconColor.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  RotationTransition(
                                    turns: _rotateController,
                                    child: SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                iconColor),
                                        backgroundColor:
                                            iconColor.withValues(alpha: 0.1),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isImage
                                        ? Icons.image_search_rounded
                                        : Icons.find_in_page_rounded,
                                    size: 28,
                                    color: iconColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Title ─────────────────────────────────────────
                      Text(
                        AppStrings.processingTitle,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              fontSize: 26,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // ── Message ───────────────────────────────────────
                      Text(
                        _hasError ? 'Extraction Failed' : AppStrings.processingMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: iconColor,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      Text(
                        _hasError ? _errorMessage : AppStrings.processingSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _hasError ? AppColors.accent : null,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // ── File chip ─────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: iconColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isImage
                                  ? Icons.image_rounded
                                  : Icons.picture_as_pdf_rounded,
                              size: 16,
                              color: iconColor,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.selectedFile.fileName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: iconColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (_hasError) ...[
                        const SizedBox(height: 40),
                        GradientButton(
                          label: 'Try Again',
                          icon: Icons.refresh_rounded,
                          onPressed: _processFile,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ── Steps indicator ──────────────────────────────────────
              if (!_hasError)
                FadeTransition(
                  opacity: _contentFade,
                  child: _ProcessingSteps(iconColor: iconColor),
                ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessingSteps extends StatelessWidget {
  final Color iconColor;
  const _ProcessingSteps({required this.iconColor});

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Reading file content',
      'Analyzing with AI',
      'Crafting questions',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Container(
            width: 30,
            height: 1.5,
            color: iconColor.withValues(alpha: 0.25),
          );
        }
        final stepIndex = i ~/ 2;
        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                steps[stepIndex],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      }),
    );
  }
}

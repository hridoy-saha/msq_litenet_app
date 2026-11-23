import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/mango_prediction.dart';
import '../services/tflite_classifier_service.dart';
import '../widgets/confidence_breakdown_card.dart';
import '../widgets/image_source_sheet.dart';
import '../widgets/model_info_dialog.dart';
import '../widgets/result_detail_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TfliteClassifierService _classifier = TfliteClassifierService();
  final ImagePicker _picker = ImagePicker();

  final List<MangoPrediction> _history = [];
  MangoPrediction? _currentPrediction;
  String? _selectedImagePath;
  bool _isModelReady = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      await _classifier.initialize();
      if (!mounted) return;
      setState(() {
        _isModelReady = true;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isModelReady = false;
        _errorMessage = 'মডেল লোড করা যায়নি। assets ফোল্ডার যাচাই করুন।';
      });
    }
  }

  Future<void> _startScanFlow() async {
    if (_isAnalyzing) return;
    final source = await ImageSourceSheet.show(context);
    if (source == null) return;
    await _pickAndClassify(source);
  }

  Future<void> _pickAndClassify(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 92,
      );
      if (pickedFile == null) return;

      setState(() {
        _selectedImagePath = pickedFile.path;
        _isAnalyzing = true;
        _errorMessage = null;
      });

      final prediction = await _classifier.classifyImage(pickedFile.path);
      if (!mounted) return;

      setState(() {
        _currentPrediction = prediction;
        _history.insert(0, prediction);
        if (_history.length > 10) {
          _history.removeLast();
        }
        _isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'ছবি বিশ্লেষণ ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';
      });
      _showToast('ছবি বিশ্লেষণে সমস্যা হয়েছে');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  void _resetCurrent() {
    setState(() {
      _selectedImagePath = null;
      _currentPrediction = null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: AppConstants.pagePadding,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  AppConstants.appSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _StatusChip(isReady: _isModelReady),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              onPressed: () => ModelInfoDialog.show(context),
              icon: const Icon(Icons.info_outline_rounded, size: 22),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.background,
                fixedSize: const Size(40, 40),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _buildErrorBanner(_errorMessage!),
                  ],
                  if (_currentPrediction != null) ...[
                    const SizedBox(height: AppConstants.sectionGap),
                    _buildPrimaryResultCard(_currentPrediction!),
                    const SizedBox(height: 14),
                    ConfidenceBreakdownCard(prediction: _currentPrediction!),
                  ],
                  if (_history.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.sectionGap),
                    _buildHistorySection(),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      height: AppConstants.previewHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_selectedImagePath != null)
              Image.file(
                File(_selectedImagePath!),
                fit: BoxFit.cover,
              )
            else
              InkWell(
                onTap: _startScanFlow,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.center_focus_strong_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'আমের ছবি নির্বাচন করুন',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ক্যামেরা বা গ্যালারি থেকে 256×256 AI বিশ্লেষণ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            if (_selectedImagePath != null && !_isAnalyzing)
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.black.withAlpha(140),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _resetCurrent,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentPrediction != null && !_isAnalyzing)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(165),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFFBBF24),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentPrediction!.inferenceTimeMs} ms',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isAnalyzing)
              Container(
                color: Colors.black.withAlpha(145),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'MSQ-LiteNet বিশ্লেষণ চলছে...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _startScanFlow,
            icon: const Icon(Icons.document_scanner_rounded, size: 20),
            label: Text(_currentPrediction == null ? 'আম স্ক্যান করুন' : 'নতুন স্ক্যান'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : () => _pickAndClassify(ImageSource.gallery),
            icon: const Icon(Icons.photo_outlined, size: 20),
            label: const Text('গ্যালারি'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.rotten.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.rotten.withAlpha(70)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.rotten, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.rotten,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryResultCard(MangoPrediction prediction) {
    final profile = prediction.profile;
    final percentText = '${(prediction.confidence * 100).toStringAsFixed(1)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: profile.color.withAlpha(85), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: profile.color.withAlpha(24),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(profile.icon, color: profile.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.titleBn,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.label} • ${profile.grade}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: profile.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: profile.color.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  percentText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: profile.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'সম্ভাব্য শেলফ-লাইফ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.shelfLife,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: TextButton.icon(
                  onPressed: () => ResultDetailDialog.show(context, prediction),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primarySurface,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.assignment_outlined, size: 17),
                  label: const Text(
                    'বিস্তারিত রিপোর্ট',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profile.storageAdvice,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'সাম্প্রতিক স্ক্যান (${_history.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextButton(
              onPressed: () => setState(() => _history.clear()),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('মুছে ফেলুন', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _history.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = _history[index];
              final profile = item.profile;
              final isSelected = _currentPrediction == item;

              return InkWell(
                onTap: () {
                  setState(() {
                    _currentPrediction = item;
                    _selectedImagePath = item.imagePath;
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 196,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(item.imagePath),
                          width: 64,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.titleBn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${(item.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: profile.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.shelfLife,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isReady;

  const _StatusChip({required this.isReady});

  @override
  Widget build(BuildContext context) {
    final color = isReady ? AppColors.fullyRipe : AppColors.accent;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isReady ? 'AI Ready' : 'Loading',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

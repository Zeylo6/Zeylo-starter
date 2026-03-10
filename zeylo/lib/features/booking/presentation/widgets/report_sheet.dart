import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Reusable Report Bottom Sheet Widget
class ReportSheet extends ConsumerStatefulWidget {
  /// The UID of the user being reported
  final String reportedUserId;
  /// Optional booking ID associated with the report
  final String? bookingId;
  /// Role of the person reporting ('seeker' or 'host')
  final String reporterRole;
  /// Role of the person being reported ('host' or 'seeker')
  final String reportedRole;

  const ReportSheet({
    super.key,
    required this.reportedUserId,
    this.bookingId,
    required this.reporterRole,
    required this.reportedRole,
  });

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  String? _selectedReason;
  bool _isSubmitting = false;
  final TextEditingController _detailsController = TextEditingController();

  List<String> get _reportReasons {
    if (widget.reporterRole == 'host') {
      return [
        'Payment Refused',
        'Did not show up',
        'Not friendly / Rude',
        'Violent / Aggressive behavior',
        'Property damage',
        'Other...'
      ];
    } else {
      // Seeker reporting Host
      return [
        'Experience not as described',
        'Host did not show up',
        'Not friendly / Rude',
        'Violent / Aggressive behavior',
        'Unsafe environment',
        'Other...'
      ];
    }
  }

  Future<void> _submitReport() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for reporting.')),
      );
      return;
    }

    if (_selectedReason == 'Other...' && _detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide additional details.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reporterId': user.uid,
        'reportedUid': widget.reportedUserId,
        'bookingId': widget.bookingId,
        'reporterRole': widget.reporterRole,
        'reportedRole': widget.reportedRole,
        'reason': _selectedReason,
        'details': _detailsController.text.trim(),
        'status': 'pending', // pending, actioned, dismissed
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully. Our team will review it shortly.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.sm,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Issue',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Let us know what went wrong.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                'Why are you reporting this?',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),

              ..._reportReasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason, style: AppTypography.bodyMedium),
                  value: reason,
                  groupValue: _selectedReason,
                  activeColor: AppColors.error,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                );
              }),

              const SizedBox(height: AppSpacing.md),

              if (_selectedReason != null) ...[
                Text(
                  'Additional Details',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                ZeyloTextField(
                  label: 'Reason for Reporting',
                  hint: 'Please provide details about your report...',
                  maxLines: 4,
                  controller: _detailsController,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              ZeyloButton(
                label: 'Submit Report',
                onPressed: _submitReport,
                isLoading: _isSubmitting,
                width: double.infinity,
                isDisabled: _selectedReason == null || _detailsController.text.isEmpty,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  'Your report will be reviewed by our admin team.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

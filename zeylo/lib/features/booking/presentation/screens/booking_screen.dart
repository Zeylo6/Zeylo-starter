import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../providers/booking_provider.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/guest_selector.dart';
import '../widgets/payment_card_input.dart';
import '../../domain/entities/booking_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Booking screen for completing a booking reservation
/// Responsive: 
/// - Desktop (>=800px): Two-column layout (form left, summary right)
/// - Mobile: Single column layout
class BookingScreen extends ConsumerStatefulWidget {
  final String experienceId;
  final String experienceTitle;
  final String experienceCoverImage;
  final String hostId;
  final double totalPrice;

  const BookingScreen({
    required this.experienceId,
    required this.experienceTitle,
    required this.experienceCoverImage,
    required this.hostId,
    required this.totalPrice,
    super.key,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _dateError;
  String? _cardNumberError;
  String? _expiryError;
  String? _cvcError;
  String? _cardholderError;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    _fullNameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        final notifier = ref.read(bookingFormProvider.notifier);
        notifier.updateFullName(user.displayName);
        notifier.updateEmail(user.email);
        if (user.phoneNumber != null) {
          notifier.updatePhoneNumber(user.phoneNumber!);
        }
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final formState = ref.read(bookingFormProvider);

    setState(() {
      _fullNameError = Validators.validateName(formState.fullName);
      _emailError = Validators.validateEmail(formState.email);
      _phoneError = Validators.validatePhone(formState.phoneNumber);
      _dateError = formState.date.isEmpty ? 'Date is required' : null;
      _cardNumberError = Validators.validateCardNumber(formState.cardNumber);
      _expiryError = Validators.validateExpiry(formState.expiry);
      _cvcError = Validators.validateCVC(formState.cvc);
      _cardholderError = Validators.validateRequired(formState.cardholderName);
    });

    if (_fullNameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _dateError == null &&
        _cardNumberError == null &&
        _expiryError == null &&
        _cvcError == null &&
        _cardholderError == null) {
      _submitBooking();
    }
  }

  Future<void> _submitBooking() async {
    final formNotifier = ref.read(bookingFormProvider.notifier);
    formNotifier.setLoading(true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        throw Exception('User details not found. Please try again.');
      }

      final formState = ref.read(bookingFormProvider);
      DateTime bookingDate = DateTime.now();

      final booking = BookingEntity(
        id: '', 
        experienceId: widget.experienceId,
        experienceTitle: widget.experienceTitle,
        experienceCoverImage: widget.experienceCoverImage,
        userId: user.uid,
        hostId: widget.hostId,
        date: bookingDate,
        startTime: formState.time,
        guests: formState.guests,
        totalPrice: widget.totalPrice,
        status: 'pending',
        paymentStatus: 'paid',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        seekerName: _fullNameController.text.trim().isNotEmpty 
            ? _fullNameController.text.trim() 
            : (user.displayName.isNotEmpty ? user.displayName : 'Seeker'),
        seekerPhotoUrl: user.photoUrl,
      );

      final createBooking = ref.read(createBookingUseCaseProvider);
      await createBooking(booking);

      formNotifier.setLoading(false);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking completed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      formNotifier.setLoading(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ─────────────────────────── WIDGETS ───────────────────────────

  Widget _buildFormFields() {
    final formState = ref.watch(bookingFormProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Guest Information'),
        const SizedBox(height: AppSpacing.lg),
        
        ZeyloTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: _fullNameController,
          errorText: _fullNameError,
          onChanged: (value) {
            ref.read(bookingFormProvider.notifier).updateFullName(value);
            if (_fullNameError != null) {
              setState(() => _fullNameError = Validators.validateName(value));
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        ZeyloTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          onChanged: (value) {
            ref.read(bookingFormProvider.notifier).updateEmail(value);
            if (_emailError != null) {
              setState(() => _emailError = Validators.validateEmail(value));
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        PhoneInputField(
          label: 'Phone Number',
          controller: _phoneController,
          errorText: _phoneError,
          onChanged: (value) {
            ref.read(bookingFormProvider.notifier).updatePhoneNumber(value);
            if (_phoneError != null) {
              setState(() => _phoneError = Validators.validatePhone(value));
            }
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        GuestSelector(
          label: 'Number of Guests',
          selectedGuests: formState.guests,
          onChanged: (value) => ref.read(bookingFormProvider.notifier).updateGuests(value),
        ),
        const SizedBox(height: AppSpacing.xl),

        _buildSectionHeader('Select Date & Time'),
        const SizedBox(height: AppSpacing.lg),

        DatePicker(
          label: 'Date',
          selectedDate: formState.date,
          onChanged: (value) {
            ref.read(bookingFormProvider.notifier).updateDate(value);
            if (_dateError != null) {
              setState(() => _dateError = value.isEmpty ? 'Date is required' : null);
            }
          },
        ),
        if (_dateError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(_dateError!, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
        ],
        const SizedBox(height: AppSpacing.lg),

        TimePicker(
          label: 'Time',
          selectedTime: formState.time,
          onChanged: (value) => ref.read(bookingFormProvider.notifier).updateTime(value),
        ),
        const SizedBox(height: AppSpacing.xl),

        _buildSectionHeader('Payment Information'),
        const SizedBox(height: AppSpacing.lg),

        PaymentCardInput(
          cardNumber: formState.cardNumber,
          expiry: formState.expiry,
          cvc: formState.cvc,
          cardholderName: formState.cardholderName,
          onCardNumberChanged: (value) {
            ref.read(bookingFormProvider.notifier).updateCardNumber(value);
            if (_cardNumberError != null) {
              setState(() => _cardNumberError = Validators.validateCardNumber(value));
            }
          },
          onExpiryChanged: (value) {
            ref.read(bookingFormProvider.notifier).updateExpiry(value);
            if (_expiryError != null) {
              setState(() => _expiryError = Validators.validateExpiry(value));
            }
          },
          onCVCChanged: (value) {
            ref.read(bookingFormProvider.notifier).updateCVC(value);
            if (_cvcError != null) {
              setState(() => _cvcError = Validators.validateCVC(value));
            }
          },
          onCardholderNameChanged: (value) {
            ref.read(bookingFormProvider.notifier).updateCardholderName(value);
            if (_cardholderError != null) {
              setState(() => _cardholderError = Validators.validateRequired(value));
            }
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildSummaryPanel(bool isDesktop) {
    final formState = ref.watch(bookingFormProvider);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: isDesktop ? [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Summary',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),
              _summaryRow('Experience', widget.experienceTitle),
              const SizedBox(height: AppSpacing.md),
              _summaryRow('Guests', '${formState.guests} ${formState.guests == 1 ? 'guest' : 'guests'}'),
              const SizedBox(height: AppSpacing.md),
              _summaryRow('Date', formState.date.isEmpty ? 'Select a date' : formState.date),
              const SizedBox(height: AppSpacing.md),
              _summaryRow('Time', formState.time),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Divider(color: AppColors.divider, height: 1),
              ),
              _summaryRow(
                'Total Price',
                'Rs. ${widget.totalPrice.toStringAsFixed(0)}',
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ZeyloButton(
          onPressed: _validateForm,
          label: 'Complete Booking',
          variant: ButtonVariant.filled,
          isLoading: formState.isLoading,
          height: 56,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: isBold
                ? AppTypography.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)
                : AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(AppSpacing.sm),
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.textInverse, size: 24),
          ),
        ),
        title: Text(
          'Complete Your Booking',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? AppSpacing.xxxl * 2 : AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: isDesktop 
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _buildFormFields()),
                const SizedBox(width: AppSpacing.xxxl),
                Expanded(flex: 4, child: _buildSummaryPanel(true)),
              ],
            )
          : Column(
              children: [
                _buildFormFields(),
                _buildSummaryPanel(false),
              ],
            ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/host_verification_flow_provider.dart';
import 'steps/intro_step.dart';
import 'steps/details_step.dart';
import 'steps/documents_step.dart';
import 'steps/pending_step.dart';

class HostVerificationScreen extends ConsumerWidget {
  const HostVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hostVerificationFlowProvider);

    if (state.isSuccess) {
      return const HostVerificationPendingScreen();
    }

    return IndexedStack(
      index: state.currentStep,
      children: const [
        HostVerificationIntroScreen(),
        HostVerificationDetailsScreen(),
        HostVerificationDocumentsScreen(),
      ],
    );
  }
}

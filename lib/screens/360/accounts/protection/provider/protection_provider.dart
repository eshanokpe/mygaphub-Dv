import 'package:GapHub/provider/providers.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../controller/protection_controller.dart';

final lifeInsuranceFormProvider =
    StateNotifierProvider.autoDispose<
      LifeInsuranceFormNotifier,
      LifeInsuranceFormState
    >((ref) {
      // Access the legacy Provider-based Providers class via the BuildContext
      // stored in the Riverpod container — use a workaround via a global key
      // or pass it from the screen instead (recommended)
      throw UnimplementedError('Use lifeInsuranceFormProviderFamily instead');
    });

// Use this family provider instead — pass Providers from the screen
final lifeInsuranceFormProviderFamily = StateNotifierProvider.autoDispose
    .family<LifeInsuranceFormNotifier, LifeInsuranceFormState, Providers>(
      (ref, providers) => LifeInsuranceFormNotifier(providers),
    );

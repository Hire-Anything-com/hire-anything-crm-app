import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_task_state.dart';
import '../../domain/usecases/get_my_services_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/cubit/dashboard_cubit.dart';

class AddTaskCubit extends Cubit<AddTaskState> {
  final GetMyServicesUseCase getMyServicesUseCase;
  final CreateTaskUseCase createTaskUseCase;

  AddTaskCubit({
    required this.getMyServicesUseCase,
    required this.createTaskUseCase,
  }) : super(const AddTaskState()) {
    clientNameController.addListener(_onFieldChanged);
    phoneController.addListener(_onFieldChanged);
    emailController.addListener(_onFieldChanged);
    subtotalController.addListener(_onMoneyChanged);
    taxController.addListener(_onMoneyChanged);
    currencyController.addListener(_onFieldChanged);
    dateController.addListener(_onFieldChanged);
    durationController.addListener(_onFieldChanged);
    // initialize money fields with state defaults
    subtotalController.text = state.subtotal;
    taxController.text = state.tax;
    currencyController.text = state.currency;
    // fetch services from domain usecase
    fetchServices();
  }

  final formKey = GlobalKey<FormState>();
  final clientNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final postcodeController = TextEditingController();
  final dateController = TextEditingController();
  final durationController = TextEditingController();
  final currencyController = TextEditingController();
  final subtotalController = TextEditingController();
  final taxController = TextEditingController();

  void _onFieldChanged() {
    final isValid = _computeIsFormValid();
    emit(state.copyWith(isFormValid: isValid));
  }

  bool _computeIsFormValid({List<String>? selectedIds}) {
    final name = clientNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    final services = selectedIds ?? state.selectedServiceIds;

    final subtotalRaw = subtotalController.text.trim();
    final subtotalVal = double.tryParse(subtotalRaw.replaceAll(',', '')) ?? 0.0;

    final currency = currencyController.text.trim();
    final date = dateController.text.trim();
    final durationRaw = durationController.text.trim();
    final durationVal = int.tryParse(durationRaw) ?? 0;

    final subtotalOk = subtotalRaw.isNotEmpty && subtotalVal > 0;
    final durationOk = durationRaw.isNotEmpty && durationVal > 0;

    return name.isNotEmpty &&
        phone.isNotEmpty &&
        email.isNotEmpty &&
        emailRegex.hasMatch(email) &&
        services.isNotEmpty &&
        subtotalOk &&
        currency.isNotEmpty &&
        date.isNotEmpty &&
        durationOk;
  }

  void _onMoneyChanged() {
    final rawSubtotal = subtotalController.text.trim();
    final rawTax = taxController.text.trim();
    final s = double.tryParse(rawSubtotal.replaceAll(',', '')) ?? 0.0;
    final t = double.tryParse(rawTax.replaceAll(',', '')) ?? 0.0;
    final total = s + t;
    final subtotalStr = s.toStringAsFixed(2);
    final taxStr = t.toStringAsFixed(2);
    final totalStr = total.toStringAsFixed(2);
    final isValid = _computeIsFormValid();
    emit(
      state.copyWith(
        subtotal: subtotalStr,
        tax: taxStr,
        total: totalStr,
        isFormValid: isValid,
      ),
    );
  }

  Future<void> fetchServices() async {
    try {
      final services = await getMyServicesUseCase();
      emit(state.copyWith(services: services));
    } catch (e) {
      if (kDebugMode) debugPrint('fetchServices error: $e');
      emit(state.copyWith(services: []));
    }
  }

  void toggleService(String id) {
    final current = List<String>.from(state.selectedServiceIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    final isValid = _computeIsFormValid(selectedIds: current);
    emit(state.copyWith(selectedServiceIds: current, isFormValid: isValid));
  }

  void toggleOtpRequired() {
    emit(state.copyWith(isOtpRequired: !state.isOtpRequired));
  }

  void toggleProofRequired() {
    emit(state.copyWith(isProofRequired: !state.isProofRequired));
  }

  void setBookingChannel(String value) {
    emit(state.copyWith(bookingChannelSelected: value));
  }

  void setPaymentStrategy(String value) {
    emit(state.copyWith(paymentStrategySelected: value));
  }

  void setCurrency(String value) {
    emit(state.copyWith(currency: value));
    currencyController.text = value;
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    emit(state.copyWith(isLoading: true));
    try {
      final name = clientNameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final services = state.selectedServiceIds;
      final totalPrice = double.tryParse(state.total) ?? 0.0;
      final estimateMinutes = int.tryParse(durationController.text.trim()) ?? 0;
      // booking type mapping
      String bookingType = state.bookingChannelSelected
          .toUpperCase()
          .replaceAll(' ', '_');
      bookingType = bookingType.replaceAll(RegExp(r'[^A-Z0-9_]'), '_');
      // payment mode mapping: detect ONLINE keyword
      final paymentMode =
          state.paymentStrategySelected.toUpperCase().contains('ONLINE')
          ? 'ONLINE'
          : 'OFFLINE';

      // parse scheduledFor from dd/MM/yyyy HH:mm -> epoch seconds
      int scheduledFor = 0;
      final rawDate = dateController.text.trim();
      if (rawDate.isNotEmpty) {
        try {
          final parts = rawDate.split(' ');
          final datePart = parts[0];
          final timePart = parts.length > 1 ? parts[1] : '00:00';
          final dateParts = datePart.split('/');
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);
          final timeParts = timePart.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final dt = DateTime(year, month, day, hour, minute);
          scheduledFor = dt.millisecondsSinceEpoch ~/ 1000;
        } catch (_) {
          scheduledFor = 0;
        }
      }

      final requireOtp = state.isOtpRequired;
      final requirePhotos = state.isProofRequired;
      final customerInfo = {
        'fullAddress': addressController.text.trim(),
        'postCode': postcodeController.text.trim(),
      };

      final s = double.tryParse(state.subtotal) ?? 0.0;
      final t = double.tryParse(state.tax) ?? 0.0;
      final taxRate = s > 0 ? (t / s) : 0.0;

      final payload = {
        'customerName': name,
        'customerPhone': phone,
        'customerEmail': email,
        'services': services,
        'totalPrice': totalPrice,
        'estimateMinutes': estimateMinutes,
        'bookingType': bookingType,
        'paymentMode': paymentMode,
        'scheduledFor': scheduledFor,
        'requireOtp': requireOtp,
        'requirePhotos': requirePhotos,
        'customerInfo': customerInfo,
        'tax': taxRate,
      };

      await createTaskUseCase.call(payload);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully')),
        );

        // reset form state and clear controllers so validation messages disappear
        formKey.currentState?.reset();

        clientNameController.clear();
        phoneController.clear();
        emailController.clear();
        addressController.clear();
        postcodeController.clear();
        dateController.clear();
        durationController.clear();
        currencyController.text = state.currency;
        subtotalController.clear();
        taxController.clear();

        // mark not loading, clear selected services and bump formResetKey so fields rebuild without errors
        emit(
          state.copyWith(
            isLoading: false,
            isFormValid: false,
            formResetKey: state.formResetKey + 1,
            selectedServiceIds: [],
          ),
        );

        // refresh task list and navigate to Tasks tab to show the created task
        try {
          final tc = context.read<TaskCubit>();
          await tc.fetchMyAssignments();
        } catch (_) {}

        try {
          context.read<DashboardCubit>().changeTab(0);
        } catch (_) {}
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
      }
      emit(state.copyWith(isLoading: false));
    }
  }

  @override
  Future<void> close() {
    clientNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    postcodeController.dispose();
    dateController.dispose();
    durationController.dispose();
    currencyController.dispose();
    subtotalController.dispose();
    taxController.dispose();
    return super.close();
  }
}

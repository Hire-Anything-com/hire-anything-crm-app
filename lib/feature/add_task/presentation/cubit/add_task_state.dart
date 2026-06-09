import 'package:equatable/equatable.dart';
import 'package:hireanythingbooking/feature/add_task/domain/entities/entities.dart';

class AddTaskState extends Equatable {
  const AddTaskState({
    this.isLoading = false,
    this.isFormValid = false,
    this.isOtpRequired = false,
    this.isProofRequired = false,
    this.bookingChannelSelected = 'Call',
    this.paymentStrategySelected = 'Offline Settlement',
    this.currency = 'USD',
    this.subtotal = '0',
    this.tax = '0',
    this.total = '0.00',
    this.services = const [],
    this.selectedServiceIds = const [],
    this.formResetKey = 0,
  });
  final bool isLoading;
  final bool isFormValid;
  final bool isOtpRequired;
  final bool isProofRequired;
  final String bookingChannelSelected;
  final String paymentStrategySelected;
  final String currency;
  final String subtotal;
  final String tax;
  final String total;
  final List<ServiceItem> services;
  final List<String> selectedServiceIds;
  final int formResetKey;

  AddTaskState copyWith({
    bool? isLoading,
    bool? isFormValid,
    bool? isOtpRequired,
    bool? isProofRequired,
    String? bookingChannelSelected,
    String? paymentStrategySelected,
    String? currency,
    String? subtotal,
    String? tax,
    String? total,
    List<ServiceItem>? services,
    List<String>? selectedServiceIds,
    int? formResetKey,
  }) {
    return AddTaskState(
      isLoading: isLoading ?? this.isLoading,
      isFormValid: isFormValid ?? this.isFormValid,
      isOtpRequired: isOtpRequired ?? this.isOtpRequired,
      isProofRequired: isProofRequired ?? this.isProofRequired,
      bookingChannelSelected:
          bookingChannelSelected ?? this.bookingChannelSelected,
      paymentStrategySelected:
          paymentStrategySelected ?? this.paymentStrategySelected,
      currency: currency ?? this.currency,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      services: services ?? this.services,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      formResetKey: formResetKey ?? this.formResetKey,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isFormValid,
    isOtpRequired,
    isProofRequired,
    bookingChannelSelected,
    paymentStrategySelected,
    currency,
    subtotal,
    tax,
    total,
    services,
    selectedServiceIds,
    formResetKey,
  ];
}

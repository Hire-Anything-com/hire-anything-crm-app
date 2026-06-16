import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/data/postal_codes.dart';
import 'package:hireanythingbooking/feature/add_task/presentation/cubit/cubit.dart';

class AddTaskPage extends StatelessWidget {
  const AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddTaskCubit, AddTaskState>(
      builder: (context, state) {
        final cubit = context.read<AddTaskCubit>();
        return CustomScrollView(
          slivers: [
            const AppSliverAppBar(
              title: AppStrings.addTask,
              actions: [LogoutAction()],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        title: 'Client Detail',
                        child: Column(
                          children: [
                            AppTextField(
                              key: ValueKey('clientName-${state.formResetKey}'),
                              controller: cubit.clientNameController,
                              labelText: 'Client name',
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Customer name is required'
                                  : null,
                            ),
                            AppSpacing.h12,
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    key: ValueKey(
                                      'phone-${state.formResetKey}',
                                    ),
                                    controller: cubit.phoneController,
                                    labelText: 'Phone number',
                                    keyboardType: TextInputType.phone,
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                        ? 'Customer phone is required'
                                        : null,
                                  ),
                                ),
                                AppSpacing.w8,
                                Expanded(
                                  child: AppTextField(
                                    key: ValueKey(
                                      'email-${state.formResetKey}',
                                    ),
                                    controller: cubit.emailController,
                                    labelText: 'Email address',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Customer email is required';
                                      }
                                      final email = v.trim();
                                      final emailRegex = RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      );
                                      if (!emailRegex.hasMatch(email)) {
                                        return 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.h16,
                      _sectionCard(
                        title: 'Service & Location Detail',
                        child: Column(
                          children: [
                            AppTextField(
                              key: ValueKey('address-${state.formResetKey}'),
                              controller: cubit.addressController,
                              labelText: 'Site address',
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Full address is required'
                                  : null,
                            ),
                            AppSpacing.h12,
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    key: ValueKey(
                                      'postcode-${state.formResetKey}',
                                    ),
                                    controller: cubit.postcodeController,
                                    labelText: 'POSTCODE',
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                        ? 'Post code is required'
                                        : null,
                                    suffixIcon: const Icon(Icons.search),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    suggestionsCallback: getPostalSuggestions,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.h12,
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'SELECT SERVICES',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.grey600,
                                ),
                              ),
                            ),
                            AppSpacing.h8,
                            Builder(
                              builder: (ctx) {
                                final sState = ctx.read<AddTaskCubit>().state;
                                final services = sState.services;
                                if (services.isEmpty) {
                                  return const SizedBox();
                                }
                                return FormField<void>(
                                  validator: (_) =>
                                      ctx
                                          .read<AddTaskCubit>()
                                          .state
                                          .selectedServiceIds
                                          .isEmpty
                                      ? 'Select at least one service'
                                      : null,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  builder: (field) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 8,
                                          children: services.map((svc) {
                                            final selected = sState
                                                .selectedServiceIds
                                                .contains(svc.id);
                                            return GestureDetector(
                                              onTap: () {
                                                cubit.toggleService(svc.id);
                                                // trigger validation update
                                                field.validate();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: selected
                                                      ? AppColors.primaryDark
                                                      : AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: selected
                                                        ? AppColors.primaryDark
                                                        : AppColors.grey300,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 18,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        color: AppColors.white,
                                                        border: Border.all(
                                                          color: selected
                                                              ? AppColors.white
                                                              : AppColors
                                                                    .grey300,
                                                        ),
                                                      ),
                                                      child: selected
                                                          ? const Icon(
                                                              Icons.check,
                                                              size: 14,
                                                              color: AppColors
                                                                  .primaryDark,
                                                            )
                                                          : null,
                                                    ),
                                                    AppSpacing.w8,
                                                    Text(
                                                      svc.name,
                                                      style: AppTypography
                                                          .bodyMedium
                                                          .copyWith(
                                                            color: selected
                                                                ? AppColors
                                                                      .white
                                                                : AppColors
                                                                      .grey800,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        if (field.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 4,
                                              top: 8,
                                            ),
                                            child: Text(
                                              field.errorText ?? '',
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                    color: AppColors.error,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.h16,
                      _sectionCard(
                        title: 'Operational Verification',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('Require OTP Verification'),
                                const Spacer(),
                                Switch(
                                  value: state.isOtpRequired,
                                  onChanged: (_) => cubit.toggleOtpRequired(),
                                ),
                              ],
                            ),
                            AppSpacing.h12,
                            Row(
                              children: [
                                const Text('Proof of Work Photos'),
                                const Spacer(),
                                Switch(
                                  value: state.isProofRequired,
                                  onChanged: (_) => cubit.toggleProofRequired(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.h16,
                      _summaryCard(context, state),

                      AppSpacing.h16,
                      _paymentCard(context, state),

                      AppSpacing.h24,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isFormValid && !state.isLoading
                              ? () => cubit.submit(context)
                              : null,
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Create task'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.h12,
            child,
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context, AddTaskState state) {
    final cubit = context.read<AddTaskCubit>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.h12,
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  key: ValueKey('subtotal-${state.formResetKey}'),
                  controller: cubit.subtotalController,
                  labelText: 'Subtotal',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Subtotal is required';
                    final val = double.tryParse(v.replaceAll(',', ''));
                    if (val == null || val <= 0)
                      return 'Enter a valid subtotal';
                    return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                  ],
                  prefixIcon: Text(
                    state.currency,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ),
              AppSpacing.w8,
              SizedBox(
                width: 120,
                child: AppTextField(
                  key: ValueKey('tax-${state.formResetKey}'),
                  controller: cubit.taxController,
                  labelText: 'Tax',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                  ],
                  prefixIcon: Text(
                    state.currency,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      state.currency + ' ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      state.total,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(BuildContext context, AddTaskState state) {
    final cubit = context.read<AddTaskCubit>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.h12,
          Text(
            'BOOKING CHANNEL',
            style: AppTypography.labelSmall.copyWith(color: AppColors.grey600),
          ),
          AppSpacing.h8,
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () => cubit.setBookingChannel('Call'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: state.bookingChannelSelected == 'Call'
                        ? AppColors.primaryDark
                        : AppColors.white,
                    foregroundColor: state.bookingChannelSelected == 'Call'
                        ? AppColors.white
                        : AppColors.grey700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Call'),
                ),
              ),
              SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: () => cubit.setBookingChannel('In-store'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(100, 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    foregroundColor: state.bookingChannelSelected == 'In-store'
                        ? AppColors.primaryDark
                        : AppColors.grey700,
                    side: BorderSide(
                      color: state.bookingChannelSelected == 'In-store'
                          ? AppColors.primaryDark
                          : AppColors.grey300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('In-store'),
                ),
              ),
            ],
          ),

          AppSpacing.h12,
          Text(
            'PAYMENT STRATEGY',
            style: AppTypography.labelSmall.copyWith(color: AppColors.grey600),
          ),
          AppSpacing.h8,
          Row(
            spacing: 4,
            children: [
              SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: () => cubit.setPaymentStrategy('Online Link'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    foregroundColor:
                        state.paymentStrategySelected == 'Online Link'
                        ? AppColors.primaryDark
                        : AppColors.grey700,
                    side: BorderSide(
                      color: state.paymentStrategySelected == 'Online Link'
                          ? AppColors.primaryDark
                          : AppColors.grey300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Online Link'),
                ),
              ),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () =>
                      cubit.setPaymentStrategy('Offline Settlement'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 38),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor:
                        state.paymentStrategySelected == 'Offline Settlement'
                        ? AppColors.primaryDark
                        : AppColors.white,
                    foregroundColor:
                        state.paymentStrategySelected == 'Offline Settlement'
                        ? AppColors.white
                        : AppColors.grey700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Offline Settlement'),
                ),
              ),
            ],
          ),

          AppSpacing.h12,
          AppTextField(
            key: ValueKey('currency-${state.formResetKey}'),
            controller: cubit.currencyController,
            labelText: 'CURRENCY',
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Currency is required' : null,
          ),
          AppSpacing.h12,
          AppTextField(
            key: ValueKey('date-${state.formResetKey}'),
            controller: cubit.dateController,
            labelText: 'SCHEDULE DATE AND TIME',
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Schedule date and time is required'
                : null,
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_today),
            onSuffixTap: () async {
              // open date then time picker when suffix tapped
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate == null) return;
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime == null) return;
              final combined = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              final formatted =
                  '${combined.day.toString().padLeft(2, '0')}/${combined.month.toString().padLeft(2, '0')}/${combined.year} ${combined.hour.toString().padLeft(2, '0')}:${combined.minute.toString().padLeft(2, '0')}';
              cubit.dateController.text = formatted;
            },
            onTap: () async {
              // also open pickers when the field itself is tapped
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate == null) return;
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime == null) return;
              final combined = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              final formatted =
                  '${combined.day.toString().padLeft(2, '0')}/${combined.month.toString().padLeft(2, '0')}/${combined.year} ${combined.hour.toString().padLeft(2, '0')}:${combined.minute.toString().padLeft(2, '0')}';
              cubit.dateController.text = formatted;
            },
          ),
          AppSpacing.h12,
          AppTextField(
            key: ValueKey('duration-${state.formResetKey}'),
            controller: cubit.durationController,
            labelText: 'DURATION (MINS)',
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Duration is required';
              final val = int.tryParse(v.trim());
              if (val == null || val <= 0) return 'Enter a valid duration';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

import 'package:cryptoplease/bl/amount.dart';
import 'package:cryptoplease/bl/swap_tokens/selector/swap_selector_bloc.dart';
import 'package:cryptoplease/l10n/device_locale.dart';
import 'package:cryptoplease/l10n/l10n.dart';
import 'package:cryptoplease/presentation/components/number_formatter.dart';
import 'package:cryptoplease/presentation/components/token_fiat_input_widget/enter_amount_keypad.dart';
import 'package:cryptoplease/presentation/dialogs.dart';
import 'package:cryptoplease/presentation/format_amount.dart';
import 'package:cryptoplease/presentation/screens/authenticated/swap_tokens/components/slippage_dropdown.dart';
import 'package:cryptoplease/presentation/screens/authenticated/swap_tokens/components/swap_header_widget.dart';
import 'package:cryptoplease/presentation/screens/authenticated/swap_tokens/swap_token_router.dart';
import 'package:cryptoplease_ui/cryptoplease_ui.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwapTokenOrderScreen extends StatefulWidget {
  const SwapTokenOrderScreen({Key? key}) : super(key: key);

  @override
  _SwapTokenOrderScreenState createState() => _SwapTokenOrderScreenState();
}

class _SwapTokenOrderScreenState extends State<SwapTokenOrderScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  late final SwapSelectorBloc swapTokenBloc;

  @override
  void initState() {
    super.initState();
    swapTokenBloc = context.read<SwapSelectorBloc>();
    _inputController.addListener(_onAmountUpdate);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _insufficientTokenDialog({
    required Amount balance,
    required Amount currentAmount,
  }) =>
      showWarningDialog(
        context,
        title: context.l10n.insufficientFundsTitle,
        message: context.l10n.insufficientFundsMessage(
          currentAmount.format(DeviceLocale.localeOf(context)),
          balance.format(DeviceLocale.localeOf(context)),
        ),
      );

  void _insufficientFeeDialog(Amount fee) {
    showWarningDialog(
      context,
      title: context.l10n.insufficientFundsForFeeTitle,
      message: context.l10n.insufficientFundsForFeeMessage(
        fee.format(DeviceLocale.localeOf(context)),
      ),
    );
  }

  Decimal get inputControllerAmount => _inputController.text.toDecimalOrZero(
        DeviceLocale.localeOf(context),
      );

  void _onAmountUpdate() {
    if (swapTokenBloc.state.selectedInput == null) return;
    swapTokenBloc.add(
      SwapSelectorEvent.amountUpdated(inputControllerAmount),
    );
  }

  void _onConfirm() {
    swapTokenBloc.validate().fold(
          (error) => error.map(
            insufficientFunds: (e) => _insufficientTokenDialog(
              balance: e.balance,
              currentAmount: e.currentAmount,
            ),
            insufficientFee: (e) => _insufficientFeeDialog(e.requiredFee),
          ),
          (_) => context.read<SwapTokenRouter>().onConfirm(),
        );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<SwapSelectorBloc, SwapSelectorState>(
        bloc: swapTokenBloc,
        listener: (context, state) {
          if (state.amount.decimal != inputControllerAmount) {
            _inputController.text = state.amount.format(
              DeviceLocale.localeOf(context),
              skipSymbol: true,
            );
          }
          final formattedOut = state.convertedAmount?.format(
            DeviceLocale.localeOf(context),
            skipSymbol: true,
          );
          _outputController.text = formattedOut ?? '';
        },
        builder: (context, state) => CpTheme.dark(
          child: CpLoader(
            isLoading: state.tokenProcessingState.maybeMap(
              processing: (_) => state.inputTokens.isEmpty,
              orElse: () => false,
            ),
            child: Scaffold(
              appBar: CpAppBar(
                leading: BackButton(
                  onPressed: () => context.read<SwapTokenRouter>().closeFlow(),
                ),
                title: Text(context.l10n.swapTokens),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    SwapHeaderWidget(
                      inputController: _inputController,
                      outputController: _outputController,
                      onSelectInput: () =>
                          context.read<SwapTokenRouter>().onSelectInputToken(),
                      onSelectOutput: () =>
                          context.read<SwapTokenRouter>().onSelectOutputToken(),
                    ),
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      child: SlippageDropdown(
                        currentSlippage: state.slippage,
                        onSlippageChanged: (slippage) => swapTokenBloc.add(
                          SwapSelectorEvent.slippageUpdated(slippage),
                        ),
                      ),
                    ),
                    Flexible(
                      child: EnterAmountKeypad(
                        controller: _inputController,
                        maxDecimals: state.selectedInput?.decimals ?? 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        right: 24,
                        left: 24,
                      ),
                      child: CpButton(
                        text: context.l10n.reviewOrder,
                        width: double.infinity,
                        onPressed: state.canSwap ? _onConfirm : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
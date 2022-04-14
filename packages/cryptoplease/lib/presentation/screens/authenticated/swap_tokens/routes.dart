import 'package:auto_route/auto_route.dart';
import 'package:cryptoplease/presentation/screens/authenticated/swap_tokens/selector/swap_token_selector_screen.dart';
import 'package:cryptoplease/presentation/screens/authenticated/swap_tokens/swap_token_router.dart';

const swapTokenRoutes = AutoRoute<void>(
  page: SwapTokenFlowScreen,
  children: [
    AutoRoute<void>(path: '', page: SwapTokenSelectorScreen),
  ],
);

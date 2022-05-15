import 'package:cryptoplease/bl/tokens/token.dart';
import 'package:cryptoplease/l10n/l10n.dart';
import 'package:cryptoplease/presentation/components/token_fiat_input_widget/token_list_dialog/token_item.dart';
import 'package:cryptoplease/presentation/screens/authenticated/swap_tokens/components/text_search_field.dart';
import 'package:cryptoplease_ui/cryptoplease_ui.dart';
import 'package:flutter/material.dart';

class SwapTokenSelectorScreen extends StatefulWidget {
  const SwapTokenSelectorScreen({
    Key? key,
    required this.availableTokens,
  }) : super(key: key);

  final Iterable<Token> availableTokens;

  @override
  State<SwapTokenSelectorScreen> createState() => _SelectorState();
}

class _SelectorState extends State<SwapTokenSelectorScreen> {
  late Iterable<Token> _tokenList;

  @override
  void initState() {
    super.initState();
    _tokenList = widget.availableTokens;
  }

  void _onClear() => setState(() => _tokenList = widget.availableTokens);

  void _onSearch(String text) {
    final query = text.toLowerCase();
    final filtered = widget.availableTokens.where(
      (token) => token.name.toLowerCase().contains(query),
    );
    setState(() => _tokenList = filtered);
  }

  @override
  Widget build(BuildContext context) => CpTheme.dark(
        child: Scaffold(
          backgroundColor: CpColors.darkBackground,
          appBar: CpAppBar(
            title: Text(context.l10n.selectToken),
            leading: const CloseButton(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                    child: TextSearchFieldWidget(
                      onClear: _onClear,
                      onSearch: _onSearch,
                    ),
                  ),
                ),
              ],
              body: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _tokenList.length,
                itemBuilder: (context, index) => Card(
                  color: CpColors.accentDarkBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TokenItem(
                      token: _tokenList.elementAt(index),
                      onSelected: (token) => Navigator.of(context).pop(token),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

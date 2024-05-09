import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sample of the MoneyMaskedTextController using brazilian currency
class MoneyMaskedTextSample extends StatelessWidget {
  final _moneyMaskedTextController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
  );

  MoneyMaskedTextSample({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Money Masked Text Sample'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _moneyMaskedTextController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                ],
                onChanged: (_) {
                  print(_moneyMaskedTextController.value);
                  print(_moneyMaskedTextController.unmasked);
                },
              ),
            ],
          ),
        ),
      );
}

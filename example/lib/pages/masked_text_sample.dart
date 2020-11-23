import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MaskedTextSample extends StatelessWidget {
  final _maskedTextController = MaskedTextController(
    mask: '000.000.000-00',
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Masked Text Sample'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _maskedTextController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                ],
                onChanged: (_) {
                  print(_maskedTextController.value);
                  print(_maskedTextController.value.selection);
                },
              ),
            ],
          ),
        ),
      );
}

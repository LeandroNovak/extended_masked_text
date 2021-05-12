import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sample of the MoneyMaskedTextController
class MaskedTextSample extends StatefulWidget {
  @override
  _MaskedTextSampleState createState() => _MaskedTextSampleState();
}

class _MaskedTextSampleState extends State<MaskedTextSample> {
  final _maskedTextController = MaskedTextController(
    // CPF mask
    mask: '000.000.000-00',
  );

  final _phoneMaskedTextController = MaskedTextController(
    // Phone mask
    mask: '0000-0000',
  );

  @override
  void initState() {
    _phoneMaskedTextController.beforeChange = (previous, next) {
      final unmasked = next.replaceAll(RegExp(r'[^0-9]'), '');
      if (unmasked.length <= 8) {
        _phoneMaskedTextController.updateMask('0000-0000',
            shouldMoveCursorToEnd: false);
      } else if (unmasked.length <= 9) {
        _phoneMaskedTextController.updateMask('00000-0000',
            shouldMoveCursorToEnd: false);
      } else if (unmasked.length <= 10) {
        _phoneMaskedTextController.updateMask('(00) 0000-0000',
            shouldMoveCursorToEnd: false);
      } else if (unmasked.length <= 11) {
        _phoneMaskedTextController.updateMask('(00) 00000-0000',
            shouldMoveCursorToEnd: false);
      } else {
        return false;
      }
      return true;
    };
    super.initState();
  }

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
                  FilteringTextInputFormatter.allow(RegExp('[0-9a-z]')),
                ],
                onChanged: (_) {
                  print(_maskedTextController.value);
                },
                decoration: const InputDecoration(hintText: 'CPF'),
              ),
              TextField(
                controller: _phoneMaskedTextController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                ],
                onChanged: (_) {
                  print(_phoneMaskedTextController.value);
                },
                decoration: const InputDecoration(hintText: 'Phone'),
              ),
            ],
          ),
        ),
      );
}

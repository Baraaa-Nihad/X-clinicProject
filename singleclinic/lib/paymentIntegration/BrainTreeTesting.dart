import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';

class BrainTreeIntegration extends StatefulWidget {
  @override
  _BrainTreeIntegrationState createState() => _BrainTreeIntegrationState();
}

class _BrainTreeIntegrationState extends State<BrainTreeIntegration> {

  void showNonce(BraintreePaymentMethodNonce nonce) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payment method nonce:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Nonce: ${nonce.nonce}'),
            SizedBox(height: 16),
            Text('Type label: ${nonce.typeLabel}'),
            SizedBox(height: 16),
            Text('Description: ${nonce.description}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Braintree example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {

              },
              child: Text('LAUNCH NATIVE DROP-IN'),
            ),
          ],
        ),
      ),
    );
  }
}
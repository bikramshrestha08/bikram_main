import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:linkeat/service/request.dart';
import 'package:linkeat/states/cart.dart';
import 'package:provider/provider.dart';
import 'package:linkeat/l10n/localizations.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../states/app.dart';


class MembershipSection extends StatefulWidget {
  final String transactionId;

  MembershipSection({Key? key, required this.transactionId}) : super(key: key);

  @override
  _MembershipSectionState createState() => _MembershipSectionState();
}



class _MembershipSectionState extends State<MembershipSection> {
  final _phoneNumberController = TextEditingController(text: '04'); // Default Australian number prefix

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> validateMember() async {
    final app = Provider.of<CartModel>(context, listen: false);
    try {
      final dynamic validationResult =
      await Services.asyncRequest('GET', '/store/v2/${app.storeDetail!.uuid}/member/mobile', context,
          params: {
            'mobile': '+61${_phoneNumberController.text}',
            'storeId': '${app.storeDetail!.uuid}',
          });

      String memberId = '';
      String firstName = '';
      String lastName = '';
      if (json.decode(validationResult.toString())['member'] != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Membership Status'),
              content: Text('Member ID: $memberId\nName: $firstName'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        memberId = json.decode(validationResult.toString())['member']['memberId'];
        firstName = json.decode(validationResult.toString())['member']['firstName'];
        lastName = json.decode(validationResult.toString())['member']['lastName'];
      }

      final int balance = json.decode(validationResult.toString())['balance'] ?? -1;

      if (memberId.isNotEmpty) {
        // Navigator.pop(context);
        // await showDialog<String>(
        //   context: context,
        //   builder: (context) => MemberRedeemDialog(transactionId: transactionId, memberId: memberId, memberBalance: balance, firstName: firstName, lastName: lastName,),
        // );
      } else {
        showDialog<String>(
          context: context,
          builder: (context) => ErrorRetryDialog(errorMessage: AppLocalizations.of(context)!.noData!),
        );
      }
    } catch (e) {
      showDialog<String>(
        context: context,
        builder: (context) => ErrorRetryDialog(errorMessage: AppLocalizations.of(context)!.noData!),
      );
      throw e;
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Membership',
            style: textTheme.headline6,
          ),
          SizedBox(height: 10),
          Text(
            'This is the Membership section.',
            style: textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixText: '+61 ',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: validateMember,
            child: Text('Validate Member'),
          ),
        ],
      ),
    );
  }
}


class ErrorRetryDialog extends StatelessWidget {
  final String errorMessage;

  ErrorRetryDialog({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Error'),
      content: Text(errorMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}



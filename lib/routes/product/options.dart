import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import 'package:linkeat/states/cart.dart';

class OptionValueView extends StatelessWidget {
  final OptionValueState optionValueState;
  final Function changeOptionValueQuantity;
  final bool reachMaxLimit;
  final int optionIdx;
  final int optionValueIdx;

  OptionValueView({
    Key? key,
    required this.optionValueState,
    required this.changeOptionValueQuantity,
    required this.reachMaxLimit,
    required this.optionIdx,
    required this.optionValueIdx,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(optionValueState.optionValue!.name!),
        ),
        SizedBox(
          width: 10.0,
        ),
        IconButton(
          icon: Icon(
            EvaIcons.minusCircleOutline,
            size: 28.0,
          ),
          disabledColor: Colors.grey[300],
          onPressed: optionValueState.quantity! > 0
              ? () {
                  changeOptionValueQuantity(
                    optionIdx: optionIdx,
                    optionValueIdx: optionValueIdx,
                    quantity: optionValueState.quantity! - 1,
                  );
                }
              : null,
        ),
        SizedBox(
          width: 5.0,
        ),
        Text(optionValueState.quantity.toString()),
        SizedBox(
          width: 5.0,
        ),
        IconButton(
          icon: Icon(
            EvaIcons.plusCircleOutline,
            size: 28.0,
          ),
          disabledColor: Colors.grey[300],
          onPressed: (!reachMaxLimit &&
                  (optionValueState.quantity! <
                          optionValueState.optionValue!.max! ||
                      optionValueState.optionValue!.max == 0))
              ? () {
                  changeOptionValueQuantity(
                    optionIdx: optionIdx,
                    optionValueIdx: optionValueIdx,
                    quantity: optionValueState.quantity! + 1,
                  );
                }
              : null,
        ),
      ],
    );
  }
}

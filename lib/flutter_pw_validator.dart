library flutter_pw_validator;

import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/Utilities/ConditionsHelper.dart';
import 'package:flutter_pw_validator/Utilities/Validator.dart';
import 'Components/ValidationBarWidget.dart';
import 'Components/ValidationTextWidget.dart';
import 'Utilities/SizeConfig.dart';
import 'Resource/Strings.dart';
import 'Resource/MyColors.dart';

class FlutterPwValidator extends StatefulWidget {
  final int minLength, uppercaseCharCount, numericCharCount, specialCharCount, lowercaseCharCount, lang;
  final Color defaultColor, successColor, failureColor;
  final double width, height;
  final Function onSuccess;
  TextEditingController controller;

  FlutterPwValidator(
      {required this.width,
      required this.height,
      required this.minLength,
      required this.onSuccess,
      required this.controller,
      this.lang = 0,
      this.uppercaseCharCount = 0,
      this.lowercaseCharCount = 0,
      this.numericCharCount = 0,
      this.specialCharCount = 0,
      this.defaultColor = MyColors.gray,
      this.successColor = MyColors.green,
      this.failureColor = MyColors.red}) {
    //Initial entered size for global use
    SizeConfig.width = width;
    SizeConfig.height = height;
  }

  @override
  State<StatefulWidget> createState() => new _FlutterPwValidatorState();
}

class _FlutterPwValidatorState extends State<FlutterPwValidator> {
  //estimate that this the first run or not
  late bool isFirstRun;

  //Variables that hold current condition states
  dynamic hasMinLength, hasMinUppercaseChar, hasMinNumericChar, hasMinSpecialChar, hasMinLowercaseChar;

  //Initial instances of ConditionHelper and Validator class
  ConditionsHelper conditionsHelper = new ConditionsHelper();
  Validator validator = new Validator();

  //Get called each time that user entered a character in EditText
  void validate() {
    //For each condition we called validators and get their new state

    hasMinLength =
        conditionsHelper.checkCondition(widget.minLength, validator.hasMinLength, widget.controller, widget.lang == 0 ? Strings.AT_LEAST : Strings.AT_LEAST_EN, hasMinLength);

    hasMinUppercaseChar = conditionsHelper.checkCondition(
        widget.uppercaseCharCount, validator.hasMinUppercase, widget.controller, widget.lang == 0 ? Strings.UPPERCASE_LETTER : Strings.UPPERCASE_LETTER_EN, hasMinUppercaseChar);

    hasMinLowercaseChar = conditionsHelper.checkCondition(
        widget.lowercaseCharCount, validator.hasMinLowercase, widget.controller, widget.lang == 0 ? Strings.LOWERCASE_LETTER : Strings.LOWERCASE_LETTER_EN, hasMinLowercaseChar);

    hasMinNumericChar = conditionsHelper.checkCondition(
        widget.numericCharCount, validator.hasMinNumericChar, widget.controller, widget.lang == 0 ? Strings.NUMERIC_CHARACTER : Strings.NUMERIC_CHARACTER_EN, hasMinNumericChar);

    hasMinSpecialChar = conditionsHelper.checkCondition(
        widget.specialCharCount, validator.hasMinSpecialChar, widget.controller, widget.lang == 0 ? Strings.SPECIAL_CHARACTER : Strings.SPECIAL_CHARACTER_EN, hasMinSpecialChar);

    //Checks if all condition are true then call the user callback
    int conditionsCount = conditionsHelper.getter()!.length;
    int trueCondition = 0;
    for (bool value in conditionsHelper.getter()!.values) {
      if (value == true) trueCondition += 1;
    }
    if (conditionsCount == trueCondition) widget.onSuccess();

    //Rebuild the UI
    setState(() => null);
    trueCondition = 0;
  }

  @override
  void initState() {
    super.initState();
    isFirstRun = true;

    //sets user entered value for each condition
    conditionsHelper.setSelectedCondition(widget.minLength, widget.uppercaseCharCount, widget.numericCharCount, widget.specialCharCount, widget.lowercaseCharCount, widget.lang);

    //Adds a listener callback on TextField to run after input get changed
    widget.controller.addListener(() {
      isFirstRun = false;
      validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: SizeConfig.width,
      height: widget.height,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Flexible(
            flex: 2,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Iterate through the conditions map values to check if there is any true values then create green ValidationBarComponent.
                for (bool value in conditionsHelper.getter()!.values)
                  if (value == true) new ValidationBarComponent(color: widget.successColor),

                // Iterate through the conditions map values to check if there is any false values then create red ValidationBarComponent.
                for (bool value in conditionsHelper.getter()!.values)
                  if (value == false) new ValidationBarComponent(color: widget.defaultColor)
              ],
            ),
          ),
          new Flexible(
            flex: 7,
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                //Iterate through the condition map entries and generate new ValidationTextWidget for each item in Green or Red Color
                children: conditionsHelper.getter()!.entries.map((entry) {
                  int? value;
                  if (entry.key == Strings.AT_LEAST && widget.lang == 0) value = widget.minLength;
                  if (entry.key == Strings.AT_LEAST_EN && widget.lang != 0) value = widget.minLength;
                  if (entry.key == Strings.UPPERCASE_LETTER && widget.lang == 0) value = widget.uppercaseCharCount;
                  if (entry.key == Strings.UPPERCASE_LETTER_EN && widget.lang != 0) value = widget.uppercaseCharCount;
                  if (entry.key == Strings.LOWERCASE_LETTER && widget.lang == 0) value = widget.lowercaseCharCount;
                  if (entry.key == Strings.LOWERCASE_LETTER_EN && widget.lang != 0) value = widget.lowercaseCharCount;
                  if (entry.key == Strings.NUMERIC_CHARACTER && widget.lang == 0) value = widget.numericCharCount;
                  if (entry.key == Strings.NUMERIC_CHARACTER_EN && widget.lang != 0) value = widget.numericCharCount;
                  if (entry.key == Strings.SPECIAL_CHARACTER && widget.lang == 0) value = widget.specialCharCount;
                  if (entry.key == Strings.SPECIAL_CHARACTER_EN && widget.lang != 0) value = widget.specialCharCount;

                  return new ValidationTextWidget(
                    color: isFirstRun
                        ? widget.defaultColor
                        : entry.value
                            ? widget.successColor
                            : widget.failureColor,
                    text: entry.key,
                    value: value,
                  );
                }).toList()),
          )
        ],
      ),
    );
  }

  //Dispose the TextField controller
  // @override
  // void dispose() {
  //   widget.controller.dispose();
  //   super.dispose();
  // }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const dateFormatYyyyMMDd = "yyyy-MM-dd";
const dateTimeFormatYyyyMMDdHhMm = "yyyy-MM-dd kk:mm";
const dateFormatMMDdYyyy = "MM/dd/yyyy";
const dateFormatMMMMDdDyyy = "MMMM dd, yyyy";
const dateTimeFormatDdMMMMYyyyHhMm = "dd MMMM yyyy | hh:mm a";

void showToast(String text, {bool isError = false, bool isLong = false}) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: isError ? Colors.red : Get.theme.primaryColorDark,
    textColor: Colors.white,
    //fontSize: 16.0
  );
}

void showLoadingDialog({bool isDismissible = false}) {
  if (Get.isDialogOpen == null || !Get.isDialogOpen!) {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: isDismissible);
  }
}

void hideLoadingDialog() {
  if (Get.isDialogOpen != null && Get.isDialogOpen!) {
    Get.back();
  }
}

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}

String formatDate(DateTime? dateTime, {String format = dateFormatYyyyMMDd}) {
  if (dateTime != null) {
    String formatStr = DateFormat(format).format(dateTime);
    return formatStr;
  } else {
    return "";
  }
}

DateTime? stringToDate(String date) {
  try {
    DateTime tempDate = DateFormat("MM/dd/yyyy").parse(date);
    return tempDate;
  } catch (e) {
    return null;
  }
}

String formatDateForInbox(DateTime? dateTime) {
  if (dateTime != null) {
    String formatStr = "";
    DateTime now = DateTime.now();
    var diffDt = now.difference(dateTime);
    if (diffDt.inDays > 0) {
      formatStr = formatDate(dateTime, format: dateTimeFormatDdMMMMYyyyHhMm);
    } else if (diffDt.inHours > 0) {
      formatStr = "${diffDt.inHours}" " Hours ago".tr;
    } else if (diffDt.inMinutes > 0) {
      formatStr = "${diffDt.inMinutes}" " Minutes ago".tr;
    } else {
      formatStr = "Just now".tr;
    }
    return formatStr;
  }
  return "";
}

String getVerboseDateTimeRepresentation(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateTime justNow = now.subtract(const Duration(minutes: 1));
  DateTime localDateTime = dateTime.toLocal();

  if (!localDateTime.difference(justNow).isNegative) {
    return 'Just Now';
  }

  String roughTimeString = DateFormat('jm').format(dateTime);
  if (localDateTime.day == now.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return 'Today, $roughTimeString';
  }

  DateTime yesterday = now.subtract(const Duration(days: 1));

  if (localDateTime.day == yesterday.day &&
      localDateTime.month == now.month &&
      localDateTime.year == now.year) {
    return 'Yesterday, $roughTimeString';
  }

  if (now.difference(localDateTime).inDays < 4) {
    String weekday = DateFormat('EEEE').format(localDateTime);

    return '$weekday, $roughTimeString';
  }

  return '${DateFormat('yMd').format(dateTime)}, $roughTimeString';
}

String stringNullCheck(String? value) {
  return value ?? "";
}

void editTextFocusDisable(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

String getEnumString(dynamic enumValue) {
  String string = enumValue.toString();
  try {
    string = string.split(".").last;
    return string;
  } catch (_) {}
  return "";
}

String amountFormat(dynamic amount) {
  String amountStr = "00.0";
  if (amount != null) {
    double amaDo = makeDouble(amount);
    amountStr = amaDo.toStringAsFixed(2);
  }
  return "$amountStr €";
}

String distanceFormat(dynamic distance) {
  String distanceStr = "0";
  if (distance != null) {
    var kmDis = makeDouble(distance);
    distanceStr = kmDis < 1 ? "1" : kmDis.toStringAsFixed(2);
  }
  return "$distanceStr KM";
}

double makeDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }
  if (value is String && value.isNotEmpty) {
    return double.parse(value);
  } else if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  }
  return 0.0;
}

DateTime? makesDate(Map<String, dynamic> json, String key,
    {bool isDefault = false}) {
  if (json.containsKey(key)) {
    var value = json[key];
    if (value is String && value.isNotEmpty) {
      if (!value.contains("z") && !value.contains("Z")) {
        value = value + "Z";
      }
      return DateTime.parse(value);
    }
  }
  if (isDefault) {
    return DateTime.now();
  }
  return null;
}

int makeInt(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return int.parse(value);
  } else if (value is double) {
    return value.toInt();
  } else if (value is int) {
    return value;
  }
  return 0;
}



void copyToClipboard(String string) {
  Clipboard.setData(ClipboardData(text: string)).then((_) {
    showToast("Text copied to clipboard".tr);
  });
}


bool isValidPassword(String value) {
  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~.]).{6,}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

Future<String> htmlString(String path) async {
  String fileText = await rootBundle.loadString(path);
  String htmlStr = Uri.dataFromString(fileText,
          mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
      .toString();
  return htmlStr;
}

/// *** APP CUSTOM VIEWS ***///

// String getUserName(User? user) {
//   String name = "";
//   String firstName = stringNullCheck(user?.firstName);
//   String latsName = stringNullCheck(user?.lastName);
//   if (firstName.isNotEmpty) {
//     name = firstName;
//   }
//   if (latsName.isNotEmpty) {
//     name = name + " " + latsName;
//   }
//   return name;
// }

String getName(String? firstName, String? lastName) {
  String name = "";
  String fName = stringNullCheck(firstName);
  String lName = stringNullCheck(lastName);
  if (fName.isNotEmpty) {
    name = fName;
  }
  if (lName.isNotEmpty) {
    name = name + " " + lName;
  }
  return name;
}

String getVerificationStatus(int? isVerified) {
  String status = "Inactive".tr;
  if (isVerified == 1) {
    status = "Active".tr;
  }
  return status;
}

String getUserRole(int? role) {
  String status = "";
  if (role == 1) {
    status = "Admin".tr;
  } else if (role == 2) {
    status = "User".tr;
  }
  return status;
}

double getContentHeight() {
  return Get.height - kToolbarHeight;
}

// flutter_datetime_picker: ^1.5.1
// void showDateTimePicker(BuildContext context, Function(DateTime value) onDateSelect){
//   DatePicker.showDateTimePicker(context,
//     showTitleActions: true,
//     minTime: DateTime.now(),
//     maxTime:  DateTime.now().add(Duration(minutes: generalSettingsG.scheduleEndBookingMinute)),
//     onConfirm: (date) {
//       onDateSelect(date);
//     },
//   );
// }

// country_code_picker: ^2.0.2
// Widget showCountryCodePicker({double? width, Function(String? dialCode)? onChanged}) {
//   return Container(
//     decoration: boxDecorationRoundBorder(color: Get.theme.primaryColorDark.withOpacity(0.5)),
//     height: 50,
//     child: CountryCodePicker(
//       dialogBackgroundColor: Get.theme.primaryColorDark,
//       showFlag: false,
//       dialogSize: Size(Get.width / 1.5, Get.height - 100),
//       initialSelection: 'USA',
//       textStyle: Get.textTheme.bodyText1,
//       closeIcon: Icon(Icons.close, color: Get.theme.primaryColor),
//       padding: EdgeInsets.zero,
//       showDropDownButton: true,
//       hideSearch: true,
//       //showCountryOnly: true,
//       //showOnlyCountryWhenClosed: true,
//       onInit: (value) {},
//       onChanged: (value) {
//         if (onChanged != null) {
//           onChanged(value.dialCode);
//         }
//       },
//     ),
//   );
// }

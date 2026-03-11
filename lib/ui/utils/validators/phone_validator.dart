String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return "שדה חובה";
  }

  final phone = value.replaceAll(RegExp(r'\D'), '');

  // if (!RegExp(r'^05\d{8}$').hasMatch(phone)) {
  //   return "מספר פלאפון לא תקין";
  // }

  // אם אנחנו רוצות גם נייח אז זה התנאי
  if (!RegExp(r'^(05\d{8}|0[23489]\d{7}|07[2-9]\d{7})$').hasMatch(phone)) {
    return "מספר לא תקין";
  }

  return null;
}
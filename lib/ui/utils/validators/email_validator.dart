String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "שדה חובה";
  }

  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return "כתובת מייל לא תקינה";
  }

  return null;
}

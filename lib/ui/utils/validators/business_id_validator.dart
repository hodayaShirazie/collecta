String? validatecrn(String? value) {
  if (value == null || value.isEmpty) {
    return "שדה חובה";
  }

  final id = value.replaceAll(RegExp(r'\D'), '');

  if (id.length != 9) {
    return "ח\"פ חייב להכיל 9 ספרות";
  }

  int sum = 0;

  for (int i = 0; i < 8; i++) {
    int digit = int.parse(id[i]);
    int step = digit * ((i % 2) + 1);

    if (step > 9) {
      step = (step ~/ 10) + (step % 10);
    }

    sum += step;
  }

  int checkDigit = (10 - (sum % 10)) % 10;

  if (checkDigit != int.parse(id[8])) {
    return "ח\"פ לא תקין";
  }

  return null;
}
// Bosnian calendar labels and formatters

String bsMonthName(int month) {
  const months = [
    'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Juni', 'Juli', 'Avgust', 'Septembar', 'Oktobar', 'Novembar', 'Decembar'
  ];
  return months[(month - 1).clamp(0, 11)];
}

String bsMonthShort(int month) {
  const months = [
    'jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'avg', 'sep', 'okt', 'nov', 'dec'
  ];
  return months[(month - 1).clamp(0, 11)];
}

String bsWeekdayShort(int weekday) {
  // Monday=1 ... Sunday=7
  const days = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];
  return days[(weekday - 1).clamp(0, 6)];
}

String formatBsMonthYear(DateTime d) {
  return "${bsMonthName(d.month)} ${d.year}";
}

String formatBsMediumDate(DateTime d) {
  // Example: "Čet, 11. sep"
  return "${bsWeekdayShort(d.weekday)}, ${d.day}. ${bsMonthShort(d.month)}";
}

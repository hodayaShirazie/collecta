import 'package:excel/excel.dart';
import '../data/models/donation_model.dart';
import '../data/models/driver_model.dart';
import 'export_helper_stub.dart'
    if (dart.library.html) 'export_helper_web.dart';

class ExportService {
  static const _statusMap = {
    'pending': 'ממתין',
    'collected': 'נאסף',
    'cancelled': 'בוטל',
  };

  static const _headers = [
    '#',
    'תאריך יצירה',
    'שם עסק',
    'ח.פ / מ.ר',
    'כתובת איסוף',
    'טלפון עסק',
    'שם איש קשר',
    'טלפון איש קשר',
    'סטטוס',
    'מוצרים',
    'זמני איסוף',
    'שם נהג',
    'קבלה',
    'סיבת ביטול',
  ];

  Future<void> exportDonationsToExcel(
    List<DonationModel> donations,
    List<DriverProfile> drivers,
  ) async {
    final driverNameById = {
      for (final d in drivers) d.user.id: d.user.name,
    };

    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'תרומות');
    final sheet = excel['תרומות'];

    final headerStyle = CellStyle(bold: true);
    sheet.appendRow(_headers.map((h) => TextCellValue(h)).toList());
    for (int i = 0; i < _headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .cellStyle = headerStyle;
    }

    for (int index = 0; index < donations.length; index++) {
      final donation = donations[index];
      final products = donation.products.map((p) {
        final name = p.type.name;
        final desc = p.type.description;
        final label = (name == 'אחר' && desc != null && desc.isNotEmpty)
            ? 'אחר: $desc'
            : name;
        return '$label (${p.quantity})';
      }).join(', ');
      final pickupTimes =
          donation.pickupTimes.map((t) => '${t.from}-${t.to}').join(', ');
      final dateStr =
          '${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}';
      final driverName = driverNameById[donation.driverId] ?? '';

      sheet.appendRow([
        IntCellValue(index + 1),
        TextCellValue(dateStr),
        TextCellValue(donation.businessName),
        TextCellValue(donation.crn),
        TextCellValue(donation.businessAddress.name),
        TextCellValue(donation.businessPhone),
        TextCellValue(donation.contactName),
        TextCellValue(donation.contactPhone),
        TextCellValue(_statusMap[donation.status] ?? donation.status),
        TextCellValue(products),
        TextCellValue(pickupTimes),
        TextCellValue(driverName),
        TextCellValue(donation.receipt),
        TextCellValue(donation.cancelingReason),
      ]);
    }

    final bytes = excel.encode()!;
    final now = DateTime.now();
    final fileName = 'donations_${now.day}_${now.month}_${now.year}.xlsx';
    await saveAndShareExcel(bytes, fileName);
  }
}

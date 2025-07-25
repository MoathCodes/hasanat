import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hasanat/core/locale/locale_extension.dart';
import 'package:hasanat/core/utils/prayer_extensions.dart';
import 'package:hasanat/core/utils/rtl_swapper.dart';
import 'package:hasanat/feature/prayer/domain/models/prayer_images.dart';
import 'package:hasanat/feature/prayer/domain/models/prayer_table_model.dart';
import 'package:hasanat/feature/prayer/presentation/provider/prayer_table/prayer_table_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PrayerTable extends ConsumerStatefulWidget {
  const PrayerTable({super.key});

  @override
  ConsumerState<PrayerTable> createState() => _PrayerTableState();
}

class _PrayerTableState extends ConsumerState<PrayerTable> {
  static const double _defaultRowHeight = 60;
  // static const _timeColumnWidth = 140.0;
  // static const _statusColumnWidth = 80.0;
  static const _nextPrayerAlpha = 40;
  static const _currentPrayerAlpha = 80;
  static const _borderWidth = 3.0;
  static const _ringBorderWidth = 1.0;
  static const _cellPadding = 8.0;
  static const _imageSize = 64.0;
  static const _imageBorderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prayerTableStream = ref.watch(prayerTableProvider(context.l10n));
    return OutlinedContainer(
        backgroundColor: theme.colorScheme.secondary,
        borderColor:
            theme.colorScheme.secondaryForeground.withAlpha(_nextPrayerAlpha),
        child: switch (prayerTableStream) {
          AsyncError(:final error) => Center(
              child: Text(error.toString()).muted().semiBold(),
            ),
          AsyncLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          AsyncValue(:final value) => Builder(builder: (context) {
              return Table(
                defaultRowHeight: FixedTableSize(_defaultRowHeight.h),
                columnWidths: ref.rtlSwap({
                  0: const FlexTableSize(flex: 2),
                  1: const FlexTableSize(),
                  2: const FlexTableSize(),
                  // 3: const FixedTableSize(_statusColumnWidth),
                }, {
                  0: const FlexTableSize(),
                  1: const FlexTableSize(),
                  2: const FlexTableSize(flex: 2),
                }),
                rows: [
                  buildHeaders(theme.colorScheme),
                  ...value!.map((row) => buildPrayerRow(row, theme)),
                ],
              );
            }),
        });
  }

  TableRow buildHeaders(ColorScheme colorScheme) {
    return ref.rtlSwap(
      TableRow(cells: [
        _buildHeaderCell(text: context.l10n.prayer, colorScheme: colorScheme),
        _buildHeaderCell(text: context.l10n.adhan, colorScheme: colorScheme),
        _buildHeaderCell(text: context.l10n.iqamah, colorScheme: colorScheme),
        // _buildHeaderCell(text: context.l10n.status),
      ]),
      TableRow(cells: [
        // _buildHeaderCell(text: context.l10n.status, alignRight: true),
        _buildHeaderCell(text: context.l10n.iqamah, alignRight: true, colorScheme: colorScheme),
        _buildHeaderCell(text: context.l10n.adhan, alignRight: true, colorScheme: colorScheme),
        _buildHeaderCell(text: context.l10n.prayer, alignRight: true, colorScheme: colorScheme),
      ]),
    );
  }

  TableRow buildPrayerRow(PrayerTableRow row, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final ltrCells = [
      _buildPrayerCell(
          title: row.prayer.getLocaleName(context.l10n),
          theme: theme,
          alignRight: false,
          alignment: row.prayer.alignment,
          imagePath: row.prayer.imagePath),
      _buildCell(title: row.adhan.title, subtitle: row.adhan.subtitle),
      _buildCell(title: row.iqamah.title, subtitle: row.iqamah.subtitle),
      // _buildCheckCell(checked: row.isChecked),
    ];
    final rtlCells = [
      // _buildCheckCell(checked: row.isChecked),
      _buildCell(
          title: row.iqamah.title,
          subtitle: row.iqamah.subtitle,
          alignRight: true),
      _buildCell(
          title: row.adhan.title,
          subtitle: row.adhan.subtitle,
          alignRight: true),
      _buildPrayerCell(
          title: row.prayer.getLocaleName(context.l10n),
          theme: theme,
          alignRight: true,
          // subtitle: row.prayer.getLocaleName(context.l10n),
          alignment: row.prayer.alignment,
          imagePath: row.prayer.imagePath),
    ];
    final cellTheme = row.isCurrentPrayer
        ? TableCellTheme(
            backgroundColor: WidgetStatePropertyAll(
              colorScheme.primary.withAlpha(_currentPrayerAlpha),
            ),
            border: WidgetStatePropertyAll(Border(
                top: BorderSide(
                    color: colorScheme.ring, width: _ringBorderWidth),
                bottom: BorderSide(
                    color: colorScheme.ring, width: _ringBorderWidth))),
          )
        : row.isNextPrayer
            ? TableCellTheme(
                backgroundColor: WidgetStatePropertyAll(
                  colorScheme.primary.withAlpha(_nextPrayerAlpha),
                ),
                border: WidgetStatePropertyAll(Border(
                    top: BorderSide(
                        color: colorScheme.primary, width: _ringBorderWidth),
                    bottom: BorderSide(
                        color: colorScheme.primary, width: _ringBorderWidth))),
              )
            : null;
    return ref.rtlSwap(TableRow(cells: ltrCells, cellTheme: cellTheme),
        TableRow(cells: rtlCells, cellTheme: cellTheme));
  }

  TableCell _buildCell({
    required String title,
    String? subtitle,
    bool alignRight = false,
  }) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(_cellPadding),
        child: BasicLayout(
          title: Text(title),
          titleAlignment:
              alignRight ? Alignment.centerRight : Alignment.centerLeft,
          subtitle: subtitle != null ? Text(subtitle).muted().small : null,
          subtitleAlignment:
              alignRight ? Alignment.centerRight : Alignment.centerLeft,
        ),
      ),
    );
  }

  // TableCell _buildCheckCell({required bool checked}) {
  //   return TableCell(
  //     child: Padding(
  //       padding: const EdgeInsets.all(_cellPadding),
  //       child: Icon(
  //         checked ? Icons.check : Icons.close,
  //       ),
  //     ),
  //   );
  // }

  TableCell _buildHeaderCell({
    required String text,
    bool alignRight = false,
    required ColorScheme colorScheme,
  }) {
    return TableCell(
      theme: TableCellTheme(
        border: WidgetStatePropertyAll(Border(
            bottom:
                BorderSide(color: colorScheme.primary, width: _borderWidth))),
      ),
      child: Container(
        padding: const EdgeInsets.all(_cellPadding),
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(text).muted().semiBold(),
      ),
    );
  }

  TableCell _buildPrayerCell({
    required String title,
    String? subtitle,
    required String imagePath,
    required Alignment alignment,
    required ThemeData theme,
    required bool alignRight,
  }) {
    return TableCell(
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.all(_cellPadding),
          child: BasicLayout(
            leading: Container(
              width: _imageSize.w,
              height: _imageSize.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                borderRadius: BorderRadius.circular(_imageBorderRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_imageBorderRadius),
                child: Image.asset(
                  imagePath,
                  width: _imageSize.w,
                  height: _imageSize.h,
                  fit: BoxFit.cover,
                  cacheWidth: _imageSize.w.toInt(),
                  cacheHeight: _imageSize.h.toInt(),
                  alignment: alignment,
                ),
              ),
            ),
            titleAlignment:
                alignRight ? Alignment.centerRight : Alignment.centerLeft,
            title: Text(title),
            subtitle: subtitle != null ? Text(subtitle).muted() : null,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/enums.dart';
import '../../data/providers/preferences_controller.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/mc_button.dart';
import '../../ui/components/mc_chip.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'ZAR'];
  static const _regions = [
    'United States',
    'Eurozone',
    'United Kingdom',
    'South Africa',
    'Global',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final controller = ref.read(preferencesProvider.notifier);

    void confirm(String msg) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
    }

    return PageScaffold(
      maxWidth: 900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Preferences',
            title: 'Settings',
            accent: AppColors.accentTeal,
          ),
          AppSpacing.vGapLg,
          _Group(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              _ChipSetting(
                label: 'Theme',
                options: [
                  for (final m in AppThemeMode.values)
                    (m.name[0].toUpperCase() + m.name.substring(1), m == prefs.themeMode, () {
                      controller.setThemeMode(m);
                      confirm('Theme updated');
                    }),
                ],
              ),
              _ChipSetting(
                label: 'Data density',
                options: [
                  for (final d in DataDensity.values)
                    (d.label, d == prefs.density, () {
                      controller.setDensity(d);
                      confirm('Density updated');
                    }),
                ],
              ),
            ],
          ),
          AppSpacing.vGapLg,
          _Group(
            title: 'Markets & data',
            icon: Icons.tune_rounded,
            children: [
              _ChipSetting(
                label: 'Display currency',
                options: [
                  for (final c in _currencies)
                    (c, c == prefs.currency, () {
                      controller.setCurrency(c);
                      confirm('Currency set to $c');
                    }),
                ],
              ),
              _ChipSetting(
                label: 'Default chart range',
                options: [
                  for (final r in TimeRange.values)
                    (r.label, r == prefs.defaultRange, () {
                      controller.setDefaultRange(r);
                      confirm('Default range set to ${r.label}');
                    }),
                ],
              ),
              _ChipSetting(
                label: 'Macro region',
                options: [
                  for (final region in _regions)
                    (region, region == prefs.macroRegion, () {
                      controller.setMacroRegion(region);
                      confirm('Macro region set to $region');
                    }),
                ],
              ),
            ],
          ),
          AppSpacing.vGapLg,
          GlassContainer(
            child: Row(
              children: [
                const Expanded(
                  child: Text('Reset all preferences to their defaults.'),
                ),
                MCSecondaryButton(
                  label: 'Reset',
                  icon: Icons.restart_alt_rounded,
                  accent: AppColors.negative,
                  size: MCButtonSize.small,
                  onPressed: () {
                    controller.reset();
                    confirm('Preferences reset');
                  },
                ),
              ],
            ),
          ),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accentTeal),
              AppSpacing.hGapSm,
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          AppSpacing.vGapLg,
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const Divider(height: AppSpacing.xl),
          ],
        ],
      ),
    );
  }
}

class _ChipSetting extends StatelessWidget {
  const _ChipSetting({required this.label, required this.options});
  final String label;
  final List<(String, bool, VoidCallback)> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        AppSpacing.vGapSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (text, selected, onTap) in options)
              MCChip(
                label: text,
                accent: AppColors.accentTeal,
                selected: selected,
                onTap: onTap,
              ),
          ],
        ),
      ],
    );
  }
}

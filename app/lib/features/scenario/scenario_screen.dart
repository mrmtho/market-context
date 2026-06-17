import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock/mock_market_data.dart';
import '../../data/models/scenario.dart';
import '../../data/providers/preferences_controller.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/mc_button.dart';
import '../../ui/components/mc_chip.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/section_header.dart';
import '../../ui/components/status_views.dart';

final _scenarioInputProvider =
    StateProvider.family<ScenarioInput, String>((ref, id) {
  return MockMarketData.instance.baseScenarioInput(id);
});

class ScenarioScreen extends ConsumerWidget {
  const ScenarioScreen({super.key, required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = MockMarketData.instance;
    final asset = data.assetById(symbol);
    if (asset == null) {
      return PageScaffold(
        child: ErrorStateView(title: 'Unknown asset', message: symbol),
      );
    }

    final input = ref.watch(_scenarioInputProvider(symbol));
    final result = data.runScenario(symbol, input);
    final currency = ref.watch(preferencesProvider.select((p) => p.currency));
    final presets = data.scenarioPresets(symbol);
    final isEquity = asset.assetType.isEquityLike || asset.sector != null;

    void update(ScenarioInput next) {
      ref.read(_scenarioInputProvider(symbol).notifier).state = next;
    }

    ref.read(analyticsProvider).log(AnalyticsEvents.scenarioOpened, {'ticker': symbol});

    final controls = GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Assumptions',
            title: 'Tune the inputs',
            accent: AppColors.accentViolet,
          ),
          AppSpacing.vGapLg,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in presets)
                MCChip(
                  label: p.name,
                  accent: AppColors.accentViolet,
                  selected: _matches(input, p.input),
                  onTap: () => update(p.input),
                ),
            ],
          ),
          AppSpacing.vGapXl,
          _Slider(
            label: 'Revenue growth',
            value: input.revenueGrowth,
            min: -10,
            max: 60,
            unit: '%/yr',
            onChanged: (v) => update(input.copyWith(revenueGrowth: v)),
          ),
          if (isEquity)
            _Slider(
              label: 'Net margin',
              value: input.netMargin,
              min: 0,
              max: 60,
              unit: '%',
              onChanged: (v) => update(input.copyWith(netMargin: v)),
            ),
          _Slider(
            label: isEquity ? 'Exit P/E multiple' : 'Exit multiple',
            value: input.exitMultiple,
            min: 4,
            max: 70,
            unit: '×',
            onChanged: (v) => update(input.copyWith(exitMultiple: v)),
          ),
          _Slider(
            label: 'Discount rate',
            value: input.discountRate,
            min: 4,
            max: 20,
            unit: '%',
            onChanged: (v) => update(input.copyWith(discountRate: v)),
          ),
          _Slider(
            label: 'Horizon',
            value: input.years.toDouble(),
            min: 1,
            max: 10,
            unit: 'yrs',
            divisions: 9,
            onChanged: (v) => update(input.copyWith(years: v.round())),
          ),
          AppSpacing.vGapMd,
          Align(
            alignment: Alignment.centerLeft,
            child: MCSecondaryButton(
              label: 'Reset to base case',
              icon: Icons.restart_alt_rounded,
              size: MCButtonSize.small,
              onPressed: () => update(data.baseScenarioInput(symbol)),
            ),
          ),
        ],
      ),
    );

    final output = Column(
      children: [
        _ResultCard(result: result, currency: currency),
        AppSpacing.vGapLg,
        _SensitivityCard(symbol: symbol, input: input, currency: currency),
        AppSpacing.vGapLg,
        _AssumptionsSummary(input: input, isEquity: isEquity),
      ],
    );

    final isDesktop = context.isDesktopOrWider;

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Breadcrumb(symbol: symbol),
          AppSpacing.vGapLg,
          if (isDesktop)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: controls),
                  AppSpacing.hGapLg,
                  Expanded(flex: 6, child: output),
                ],
              ),
            )
          else
            Column(children: [controls, AppSpacing.vGapLg, output]),
          AppSpacing.vGapLg,
          const _Disclaimer(),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }

  bool _matches(ScenarioInput a, ScenarioInput b) {
    bool eq(double x, double y) => (x - y).abs() < 0.01;
    return eq(a.revenueGrowth, b.revenueGrowth) &&
        eq(a.netMargin, b.netMargin) &&
        eq(a.exitMultiple, b.exitMultiple) &&
        eq(a.discountRate, b.discountRate) &&
        a.years == b.years;
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MCSecondaryButton(
          label: symbol,
          icon: Icons.arrow_back_rounded,
          size: MCButtonSize.small,
          onPressed: () => context.go('/asset/$symbol'),
        ),
        AppSpacing.hGapMd,
        Text('Scenario & assumption explorer',
            style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
              Text('${value.toStringAsFixed(unit == 'yrs' ? 0 : 1)}$unit',
                  style: AppTypography.mono(
                      size: 14, weight: FontWeight.w700, color: AppColors.accentCyan)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accentCyan,
              inactiveTrackColor: AppColors.glassFillStrong,
              thumbColor: AppColors.accentCyan,
              overlayColor: AppColors.cyanGlow,
              trackHeight: 4,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.currency});
  final ScenarioResult result;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final upside = result.upsidePercent;
    final color = AppColors.forChange(upside);
    return GlassContainer(
      glow: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IMPLIED VALUE', style: AppTypography.eyebrow(color: color)),
          AppSpacing.vGapSm,
          Text(Fmt.priceExact(result.impliedPrice, currency: currency),
              style: AppTypography.mono(size: 40, weight: FontWeight.w700, color: color)),
          AppSpacing.vGapSm,
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _stat(context, 'Current price',
                  Fmt.priceExact(result.currentPrice, currency: currency)),
              _stat(context, 'Implied upside', Fmt.percent(upside), color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppTypography.eyebrow()),
        const SizedBox(height: 3),
        Text(value, style: AppTypography.mono(size: 16, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _SensitivityCard extends StatelessWidget {
  const _SensitivityCard({required this.symbol, required this.input, required this.currency});
  final String symbol;
  final ScenarioInput input;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final data = MockMarketData.instance;
    final growths = [input.revenueGrowth - 5, input.revenueGrowth, input.revenueGrowth + 5];
    final multiples = [input.exitMultiple * 0.8, input.exitMultiple, input.exitMultiple * 1.2];

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Sensitivity',
            title: 'Growth × exit multiple',
            accent: AppColors.accentTeal,
          ),
          AppSpacing.vGapLg,
          Row(
            children: [
              const SizedBox(width: 64),
              for (final m in multiples)
                Expanded(
                  child: Text('${m.toStringAsFixed(0)}×',
                      textAlign: TextAlign.center,
                      style: AppTypography.eyebrow()),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (final g in growths)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text('${g.toStringAsFixed(0)}%',
                        style: AppTypography.eyebrow()),
                  ),
                  for (final m in multiples)
                    Expanded(
                      child: Builder(builder: (context) {
                        final r = data.runScenario(
                            symbol,
                            input.copyWith(revenueGrowth: g, exitMultiple: m));
                        final color = AppColors.forChange(r.upsidePercent);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: AppRadii.brSm,
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            Fmt.compactCurrency(r.impliedPrice, currency: currency),
                            textAlign: TextAlign.center,
                            style: AppTypography.mono(size: 12, weight: FontWeight.w600, color: color),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AssumptionsSummary extends StatelessWidget {
  const _AssumptionsSummary({required this.input, required this.isEquity});
  final ScenarioInput input;
  final bool isEquity;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Revenue growth', '${input.revenueGrowth.toStringAsFixed(1)}% / yr'),
      if (isEquity) ('Net margin', '${input.netMargin.toStringAsFixed(1)}%'),
      ('Exit multiple', '${input.exitMultiple.toStringAsFixed(1)}×'),
      ('Discount rate', '${input.discountRate.toStringAsFixed(1)}%'),
      ('Horizon', '${input.years} years'),
    ];
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ASSUMPTIONS IN PLAY', style: AppTypography.eyebrow()),
          AppSpacing.vGapMd,
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: Text(r.$1, style: Theme.of(context).textTheme.bodyMedium)),
                  Text(r.$2, style: AppTypography.mono(size: 13, weight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_outlined, size: 16, color: AppColors.warning),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              'This explorer is an educational toy model, not financial advice or '
              'a valuation. It uses a simplified earnings-times-multiple framework '
              'on mock data to build intuition about which assumptions matter most.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

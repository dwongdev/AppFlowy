import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/mobile/presentation/home/tab/mobile_space_tab.dart';
import 'package:appflowy/workspace/application/command_palette/command_palette_bloc.dart';
import 'package:appflowy_backend/protobuf/flowy-search/result.pb.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'mobile_search_summary_cell.dart';

class MobileSearchAskAiEntrance extends StatelessWidget {
  const MobileSearchAskAiEntrance({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CommandPaletteBloc?>(), state = bloc?.state;
    if (bloc == null || state == null) return _AskAIFor();

    final generatingAIOverview = state.generatingAIOverview;
    if (generatingAIOverview) return _AISearching();

    final hasMockSummary = _mockSummary?.isNotEmpty ?? false,
        hasSummaries = state.resultSummaries.isNotEmpty;
    if (hasMockSummary || hasSummaries) return _AIOverview();

    return _AskAIFor();
  }
}

class _AskAIFor extends StatelessWidget {
  const _AskAIFor();

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context),
        spaceM = theme.spacing.m,
        spaceL = theme.spacing.l;
    return GestureDetector(
      onTap: () {
        context
            .read<CommandPaletteBloc?>()
            ?.add(CommandPaletteEvent.goingToAskAI());
        mobileCreateNewAIChatNotifier.value =
            mobileCreateNewAIChatNotifier.value + 1;
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(top: spaceM),
        padding: EdgeInsets.all(spaceL),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 24,
              child: Center(
                child: FlowySvg(
                  FlowySvgs.m_home_ai_chat_icon_m,
                  size: Size.square(20),
                  blendMode: null,
                ),
              ),
            ),
            HSpace(8),
            buildText(context),
          ],
        ),
      ),
    );
  }

  Widget buildText(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    final bloc = context.read<CommandPaletteBloc?>();
    final queryText = bloc?.state.query ?? '';
    if (queryText.isEmpty) {
      return Text(
        LocaleKeys.search_askAIAnything.tr(),
        style: theme.textStyle.heading4
            .standard(color: theme.textColorScheme.primary),
      );
    }
    return Flexible(
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: LocaleKeys.search_askAIFor.tr(),
              style: theme.textStyle.heading4
                  .standard(color: theme.textColorScheme.primary),
            ),
            TextSpan(
              text: ' "$queryText"',
              style: theme.textStyle.heading4
                  .enhanced(color: theme.textColorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AISearching extends StatelessWidget {
  const _AISearching();

  @override
  Widget build(BuildContext context) {
    final theme = AppFlowyTheme.of(context),
        spaceM = theme.spacing.m,
        spaceL = theme.spacing.l;
    return Container(
      margin: EdgeInsets.only(top: spaceM),
      padding: EdgeInsets.all(spaceL),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            SizedBox.square(
              dimension: 24,
              child: Center(
                child: FlowySvg(
                  FlowySvgs.m_home_ai_chat_icon_m,
                  size: Size.square(20),
                  blendMode: null,
                ),
              ),
            ),
            HSpace(8),
            Text(
              LocaleKeys.search_searching.tr(),
              style: theme.textStyle.heading4
                  .standard(color: theme.textColorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIOverview extends StatelessWidget {
  const _AIOverview();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CommandPaletteBloc?>(), state = bloc?.state;
    final summaries = _mockSummary ?? state?.resultSummaries ?? [];
    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = AppFlowyTheme.of(context),
        spaceM = theme.spacing.m,
        spaceL = theme.spacing.l;
    return Container(
      margin: EdgeInsets.only(top: spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VSpace(spaceM),
          buildHeader(context),
          VSpace(spaceL),
          LayoutBuilder(
            builder: (context, constrains) {
              final summary = summaries.first;
              return MobileSearchSummaryCell(
                key: ValueKey(summary.content.trim()),
                summary: summary,
                maxWidth: constrains.maxWidth,
                theme: AppFlowyTheme.of(context),
                textStyle: theme.textStyle.heading4
                    .standard(color: theme.textColorScheme.primary)
                    .copyWith(height: 22 / 16),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    final theme = AppFlowyTheme.of(context);
    return Row(
      children: [
        FlowySvg(
          FlowySvgs.ai_searching_icon_m,
          size: Size.square(20),
          blendMode: null,
        ),
        HSpace(8),
        Text(
          LocaleKeys.commandPalette_aiOverview.tr(),
          style: theme.textStyle.heading4
              .enhanced(color: theme.textColorScheme.primary),
        ),
      ],
    );
  }
}

List<SearchSummaryPB>? _mockSummary;

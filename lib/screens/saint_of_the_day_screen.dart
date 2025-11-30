import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sober_paper/core/constants/app_spacing.dart';
import 'package:sober_paper/widgets/paper_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/saint_of_the_day_model.dart';
import '../providers/saint_of_the_day_providers.dart';

class SaintOfTheDayScreen extends ConsumerStatefulWidget {
  const SaintOfTheDayScreen({super.key});

  @override
  ConsumerState<SaintOfTheDayScreen> createState() => _SaintOfTheDayScreenState();
}

class _SaintOfTheDayScreenState extends ConsumerState<SaintOfTheDayScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedSaintDateProvider);
    final saintAsync = ref.watch(todaySaintProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Saint of the Day',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: () {
              ref.read(selectedSaintDateProvider.notifier).setToday();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background church image
          Positioned.fill(
            child: Image.asset(
              'assets/images/church_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1a4d6d),
                      Color(0xFF2d5a7b),
                      Color(0xFF1e3a4f),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(selectedDateSaintProvider);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: _buildDateSelector(selectedDate),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    sliver: saintAsync.when(
                      data: (saint) => saint != null
                          ? _buildSaintContent(saint)
                          : _buildNoSaintState(),
                      loading: () => _buildLoadingState(),
                      error: (error, stack) => _buildErrorState(error.toString()),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(height: AppSpacing.lg),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(DateTime selectedDate) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xs,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      child: PaperCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                final newDate = selectedDate.subtract(const Duration(days: 1));
                ref.read(selectedSaintDateProvider.notifier).setDate(newDate);
              },
            ),
            Expanded(
              child: InkWell(
                onTap: () => _showDatePicker(context, selectedDate),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                final newDate = selectedDate.add(const Duration(days: 1));
                ref.read(selectedSaintDateProvider.notifier).setDate(newDate);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaintContent(SaintOfTheDay saint) {

    print("reflection ${saint.toString()}");

    return SliverList(
      delegate: SliverChildListDelegate([
        // Saint Image with Name Overlay
        _buildSaintImageHeader(saint),
        const SizedBox(height: AppSpacing.lg),

        // Feast Type Badge
        if (saint.hasFeastType) ...[
          _buildFeastTypeBadge(saint.feastType!),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Summary Card
        if (saint.hasSummary) ...[
          _buildSummaryCard(saint.summary!),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Saint's Story
        if (saint.hasFullReflection) ...[
          ..._buildStoryAndReflection(saint.fullReflection!),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Bible Verse
        if (saint.hasBibleVerse) ...[
          _buildBibleVerseCard(saint.bibleVerse!, saint.verseReference),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Prayer Section
        if (saint.hasPrayer) ...[
          ..._buildPrayerSection(saint.prayer!),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Source Attribution
        _buildSourceAttribution(saint),
        const SizedBox(height: AppSpacing.xl),
      ]),
    );
  }

  Widget _buildSaintImageHeader(SaintOfTheDay saint) {
    return PaperCard(
      
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with gradient overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: saint.imageUrl.isNotEmpty
                    ? Image.network(
                        saint.imageUrl,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Saint name overlay
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saint.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(saint.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 280,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.church,
          size: 80,
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildFeastTypeBadge(String feastType) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.15),
              Theme.of(context).primaryColor.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              feastType,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String summary) {
    return PaperCard(
      elevation: 3,
      useLiturgicalColors: true,
      child: Text(
        summary,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          fontStyle: FontStyle.italic,
          color: Color(0xFF2C2C2C),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  List<Widget> _buildStoryAndReflection(String fullReflection) {
    final sections = <Widget>[];

    // Parse sections - handle both with and without separator
    final storyMatch = RegExp(
      r"SAINT'S STORY\s*\n\n([\s\S]+?)(?=\n\n---\n\n|\n\nREFLECTION|$)",
      multiLine: true,
    ).firstMatch(fullReflection);

    final reflectionMatch = RegExp(
      r'REFLECTION\s*\n\n([\s\S]+?)(?=\n\n---\n\n|$)',
      multiLine: true,
    ).firstMatch(fullReflection);

    // Saint's Story Section
    if (storyMatch != null) {
      final storyContent = storyMatch.group(1)?.trim();
      if (storyContent != null && storyContent.isNotEmpty) {
        sections.add(
          PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_stories,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Saint\'s Story',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  storyContent,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Color(0xFF2C2C2C),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        );
        sections.add(const SizedBox(height: AppSpacing.lg));
      }
    }

    // Reflection Section
    if (reflectionMatch != null) {
      final reflectionContent = reflectionMatch.group(1)?.trim();
      if (reflectionContent != null && reflectionContent.isNotEmpty) {
        sections.add(
          PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Reflection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  reflectionContent,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF2C2C2C),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        );
      }
    }

    return sections;
  }

  Widget _buildBibleVerseCard(String verse, String? reference) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: Colors.amber.shade800,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (reference != null)
                Expanded(
                  child: Text(
                    reference,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.shade300.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '"$verse"',
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                fontStyle: FontStyle.italic,
                color: Color(0xFF2C2C2C),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPrayerSection(String prayerContent) {
    final sections = <Widget>[];

    // Parse patron saint info
    final parts = prayerContent.split('\n\n---\n\n');
    final hasPatronInfo = parts.length > 1 && parts[0].startsWith('PATRON SAINT OF');

    String? patronSaint;
    String prayer;

    if (hasPatronInfo) {
      patronSaint = parts[0].replaceFirst('PATRON SAINT OF\n\n', '').trim();
      prayer = parts.last.trim();
    } else {
      prayer = prayerContent.trim();
    }

    // Patron Saint Card
    if (patronSaint != null && patronSaint.isNotEmpty) {
      sections.add(
        PaperCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shield,
                      color: Colors.purple.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Patron Saint Of',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                patronSaint,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ),
      );
      sections.add(const SizedBox(height: AppSpacing.lg));
    }

    // Prayer Card
    sections.add(
      PaperCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.church,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Prayer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              prayer,
              style: const TextStyle(
                fontSize: 15,
                height: 1.7,
                fontStyle: FontStyle.italic,
                color: Color(0xFF2C2C2C),
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );

    return sections;
  }

  Widget _buildSourceAttribution(SaintOfTheDay saint) {
    return PaperCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).primaryColor.withOpacity(0.6),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Source: Franciscan Media',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: () => _launchURL(saint.reflectionUrl),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read Full',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Loading saint...',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: PaperCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Unable to load saint',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(selectedDateSaintProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoSaintState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: PaperCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.church_outlined,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'No saint found for this date',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Try selecting a different date',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      ref.read(selectedSaintDateProvider.notifier).setDate(picked);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
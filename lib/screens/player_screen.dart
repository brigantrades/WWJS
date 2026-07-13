import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/app_theme.dart';
import '../core/audio_source_candidates.dart';
import '../core/formatters.dart';
import '../models/prayer_content.dart';
import '../state/app_controller.dart';
import '../widgets/dawn_artwork.dart';
import '../widgets/reminder_prompt_modal.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.controller,
    required this.prayer,
    this.onHome,
  });

  final AppController controller;
  final PrayerContent prayer;
  final VoidCallback? onHome;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  static const bool _readAlongEnabled = false;

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 2);
  bool _playing = false;
  bool _loading = true;
  bool _didComplete = false;
  bool _completionInProgress = false;
  bool _showReadAlong = false;
  String? _error;
  int _lastSavedSecond = -1;

  @override
  void initState() {
    super.initState();
    _position = widget.controller.positions[widget.prayer.day] ?? Duration.zero;
    _duration = widget.prayer.estimatedDuration;
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final mediaItem = MediaItem(
        id: 'prayer-${widget.prayer.day}',
        album: 'WWJS: What Would Jesus Say?',
        title: 'Day ${widget.prayer.day}: ${widget.prayer.title}',
        displaySubtitle: widget.prayer.scriptureReference,
      );
      Duration? duration;
      Object? lastError;
      StackTrace? lastStackTrace;
      var loaded = false;

      for (final uri in audioSourceCandidates(widget.prayer.audioUrl)) {
        try {
          duration = await _player.setAudioSource(
            AudioSource.uri(uri, tag: mediaItem),
          );
          loaded = true;
          break;
        } catch (error, stackTrace) {
          lastError = error;
          lastStackTrace = stackTrace;
        }
      }

      if (!loaded) {
        Error.throwWithStackTrace(lastError!, lastStackTrace!);
      }
      if (_position > Duration.zero) await _player.seek(_position);
      _duration = duration ?? widget.prayer.estimatedDuration;
      _positionSubscription = _player.positionStream.listen((position) {
        if (!mounted) return;
        setState(() => _position = position);
        if (position.inSeconds != _lastSavedSecond &&
            position.inSeconds % 5 == 0) {
          _lastSavedSecond = position.inSeconds;
          unawaited(
            widget.controller.savePosition(widget.prayer.day, position),
          );
        }
      });
      _durationSubscription = _player.durationStream.listen((duration) {
        if (mounted && duration != null) setState(() => _duration = duration);
      });
      _stateSubscription = _player.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() => _playing = state.playing);
        if (state.processingState == ProcessingState.completed) _complete();
      });
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'The audio could not be opened.';
        });
      }
    }
  }

  Future<void> _togglePlayback() async {
    _playing ? await _player.pause() : await _player.play();
  }

  Future<void> _seek(Duration position) async {
    final safe = position < Duration.zero
        ? Duration.zero
        : (position > _duration ? _duration : position);
    await _player.seek(safe);
  }

  Future<void> _complete() async {
    if (_didComplete || _completionInProgress) return;
    _completionInProgress = true;
    final wasAlreadyCompleted = widget.controller.completed.contains(
      widget.prayer.day,
    );
    try {
      await _player.pause();
      if (mounted) {
        setState(() {
          _playing = false;
          _didComplete = true;
        });
      }
      await widget.controller.markCompleted(widget.prayer.day);
      if (!mounted) return;
      if (shouldOfferDailyReminder(
        completedDay: widget.prayer.day,
        wasAlreadyCompleted: wasAlreadyCompleted,
        reminderEnabled: widget.controller.reminderEnabled,
      )) {
        await showReminderPromptModal(context, controller: widget.controller);
      }
    } finally {
      _completionInProgress = false;
    }
  }

  Future<void> _leave() async {
    await widget.controller.savePosition(
      widget.prayer.day,
      _didComplete ? Duration.zero : _position,
    );
    if (!mounted) return;
    widget.onHome?.call();
    Navigator.of(context).pop();
  }

  Future<void> _prayAgain() async {
    await _player.seek(Duration.zero);
    if (!mounted) return;
    setState(() {
      _position = Duration.zero;
      _didComplete = false;
      _error = null;
    });
    await _player.play();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    unawaited(
      widget.controller.savePosition(
        widget.prayer.day,
        _didComplete ? Duration.zero : _position,
      ),
    );
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playbackSection = widget.prayer.sectionAt(_position);
    final scriptureSection = widget.prayer.sections.firstWhere(
      (candidate) => candidate.type == PrayerSectionType.scripture,
    );
    final favorite = widget.controller.favorites.contains(widget.prayer.day);
    final totalMs = _duration.inMilliseconds <= 0
        ? 1
        : _duration.inMilliseconds;
    final value = _position.inMilliseconds.clamp(0, totalMs).toDouble();
    final sectionIndex = widget.prayer.sections.indexOf(playbackSection);
    final sectionEnd = sectionIndex + 1 < widget.prayer.sections.length
        ? widget.prayer.sections[sectionIndex + 1].startsAt
        : _duration;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DawnArtwork(height: 320, compact: true),
                    Positioned(
                      top: 4,
                      left: 10,
                      right: 10,
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Return home',
                            onPressed: _leave,
                            icon: const Icon(Icons.home_rounded, size: 28),
                          ),
                          const Spacer(),
                          IconButton.filledTonal(
                            tooltip: favorite
                                ? 'Remove from favorites'
                                : 'Add to favorites',
                            onPressed: () => widget.controller.toggleFavorite(
                              widget.prayer.day,
                            ),
                            icon: Icon(
                              favorite ? Icons.favorite : Icons.favorite_border,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_didComplete)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: AppColors.sage.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 44,
                              color: AppColors.sage,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'DAY ${widget.prayer.day} COMPLETE',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.sage,
                                  letterSpacing: 1.6,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Go in peace',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Carry this moment with you today. Jesus is with you in whatever comes next.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        Text(
                          scriptureSection.text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.prayer.scriptureReference,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.sage),
                        ),
                        if (_readAlongEnabled)
                          AnimatedSize(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 250),
                            child: _showReadAlong
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: _ReadAlongText(
                                      text: widget.prayer.transcriptFor(
                                        playbackSection.type,
                                      ),
                                      position: _position,
                                      startsAt: playbackSection.startsAt,
                                      endsAt: sectionEnd,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(_error!, textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),
                ),
              if (_didComplete)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  child: Column(
                    children: [
                      FilledButton(
                        onPressed: _leave,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: AppColors.forest,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Return home'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _prayAgain,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: const Text('Pray again'),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
                  child: Column(
                    children: [
                      Slider(
                        value: value,
                        max: totalMs.toDouble(),
                        onChanged: _loading
                            ? null
                            : (next) =>
                                  _seek(Duration(milliseconds: next.round())),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatDuration(_position)),
                          Text(formatDuration(_duration)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'Back 15 seconds',
                            onPressed: () =>
                                _seek(_position - const Duration(seconds: 15)),
                            icon: _skipIcon(forward: false),
                          ),
                          const SizedBox(width: 26),
                          IconButton.filled(
                            tooltip: _playing ? 'Pause' : 'Play',
                            onPressed: _loading || _error != null
                                ? null
                                : _togglePlayback,
                            icon: _loading
                                ? CircularProgressIndicator(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.forest
                                        : Colors.white,
                                  )
                                : Icon(
                                    _playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 28,
                                  ),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(68, 68),
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.warmWhite
                                  : AppColors.forest,
                              foregroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.forest
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 26),
                          IconButton(
                            tooltip: 'Forward 15 seconds',
                            onPressed: () =>
                                _seek(_position + const Duration(seconds: 15)),
                            icon: _skipIcon(forward: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_readAlongEnabled)
                        Semantics(
                          container: true,
                          label: 'Read along',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 20),
                              const SizedBox(width: 8),
                              const Text('Read along'),
                              const SizedBox(width: 8),
                              Switch.adaptive(
                                value: _showReadAlong,
                                onChanged: (value) =>
                                    setState(() => _showReadAlong = value),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skipIcon({required bool forward}) {
    final color =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: 44,
      height: 40,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SkipArrowPainter(forward: forward, color: color),
            ),
          ),
          Positioned(
            bottom: 1,
            left: forward ? null : 5,
            right: forward ? 5 : null,
            child: Text(
              '15',
              style: TextStyle(
                color: color,
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkipArrowPainter extends CustomPainter {
  const _SkipArrowPainter({required this.forward, required this.color});

  final bool forward;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (forward) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final arrow = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final curve = Path()
      ..moveTo(14, 8)
      ..lineTo(21, 8)
      ..cubicTo(34, 8, 40, 17, 37, 29)
      ..cubicTo(36, 32, 34, 34, 31, 35);
    canvas.drawPath(curve, stroke);

    final arrowHead = Path()
      ..moveTo(10, 8)
      ..lineTo(18, 2.5)
      ..lineTo(18, 13.5)
      ..close();
    canvas.drawPath(arrowHead, arrow);
  }

  @override
  bool shouldRepaint(covariant _SkipArrowPainter oldDelegate) =>
      forward != oldDelegate.forward || color != oldDelegate.color;
}

class _ReadAlongText extends StatelessWidget {
  const _ReadAlongText({
    required this.text,
    required this.position,
    required this.startsAt,
    required this.endsAt,
  });

  final String text;
  final Duration position;
  final Duration startsAt;
  final Duration endsAt;

  @override
  Widget build(BuildContext context) {
    final words = text.split(RegExp(r'\s+'));
    final sectionDuration = endsAt - startsAt;
    final elapsed = position - startsAt;
    final progress = sectionDuration.inMilliseconds <= 0
        ? 0.0
        : elapsed.inMilliseconds / sectionDuration.inMilliseconds;
    final activeWord = (progress.clamp(0.0, 0.999999) * words.length).floor();
    final baseStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      height: 1.6,
      color: AppColors.forest.withValues(alpha: 0.38),
    );

    return Semantics(
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              for (var index = 0; index < words.length; index++)
                TextSpan(
                  text:
                      '${words[index]}${index == words.length - 1 ? '' : ' '}',
                  style: index == activeWord
                      ? baseStyle?.copyWith(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w700,
                          backgroundColor: AppColors.sage.withValues(
                            alpha: 0.18,
                          ),
                        )
                      : baseStyle,
                ),
            ],
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

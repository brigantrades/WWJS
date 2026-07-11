import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../models/prayer_content.dart';
import '../state/app_controller.dart';
import '../widgets/dawn_artwork.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.controller,
    required this.prayer,
  });

  final AppController controller;
  final PrayerContent prayer;

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
      final duration = await _player.setAudioSource(
        AudioSource.asset(
          widget.prayer.audioAsset,
          tag: MediaItem(
            id: 'prayer-${widget.prayer.day}',
            album: 'WWJS — Pray with Jesus',
            title: 'Day ${widget.prayer.day}: ${widget.prayer.title}',
            displaySubtitle: widget.prayer.scriptureReference,
          ),
        ),
      );
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
    await _player.pause();
    if (mounted) {
      setState(() {
        _playing = false;
        _didComplete = true;
      });
    }
    await widget.controller.markCompleted(widget.prayer.day);
  }

  Future<void> _leave() async {
    await widget.controller.savePosition(
      widget.prayer.day,
      _didComplete ? Duration.zero : _position,
    );
    if (mounted) Navigator.of(context).pop();
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
    var section = playbackSection;
    if (section.type == PrayerSectionType.preparation) {
      section = widget.prayer.sections.firstWhere(
        (candidate) => candidate.type == PrayerSectionType.scripture,
      );
    }
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
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Leave prayer',
                      onPressed: _leave,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 34,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: favorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      onPressed: () =>
                          widget.controller.toggleFavorite(widget.prayer.day),
                      icon: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border,
                      ),
                    ),
                  ],
                ),
              ),
              if (_didComplete)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height - 280,
                      ),
                      child: Column(
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
                        const SizedBox.square(
                          dimension: 116,
                          child: ClipOval(
                            child: DawnArtwork(height: 116, compact: true),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          section.label.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.sage,
                                letterSpacing: 1.8,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(width: 28, height: 2, color: AppColors.sage),
                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 350),
                          child: Text(
                            section.text,
                            key: ValueKey(section.type),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        if (section.type == PrayerSectionType.scripture) ...[
                          const SizedBox(height: 14),
                          Text(
                            widget.prayer.scriptureReference,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.sage),
                          ),
                        ],
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
                        child: const Text('Continue my day'),
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
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Icon(
                                    _playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(82, 82),
                              backgroundColor: AppColors.forest,
                              foregroundColor: Colors.white,
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
                      Card(
                        child: ListTile(
                          minTileHeight: 66,
                          onTap: _leave,
                          leading: const Icon(
                            Icons.cloud_outlined,
                            color: AppColors.sage,
                          ),
                          title: const Text('Leave for now'),
                          subtitle: const Text('Your progress is saved'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                      ),
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
    return SizedBox.square(
      dimension: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.flip(
            flipX: forward,
            child: const Icon(Icons.replay_rounded, size: 40),
          ),
          const Text(
            '15',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
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

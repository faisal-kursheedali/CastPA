import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:castpa/data/services/media_file_service.dart';

/// Full-size media renderer for preview — image, animated GIF, or auto-playing video.
class MediaItemWidget extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const MediaItemWidget({super.key, required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final ext = path.split('.').last.toLowerCase();
    if (ext == 'gif') {
      return Image.file(File(path), fit: fit, width: double.infinity, gaplessPlayback: true);
    }
    if (MediaFileService.isImage(path)) {
      return Image.file(File(path), fit: fit, width: double.infinity,
          errorBuilder: (_, e, s) => _broken());
    }
    if (MediaFileService.isVideo(path)) {
      return _VideoWidget(path: path, fit: fit);
    }
    return _broken();
  }

  Widget _broken() => Container(
        color: Colors.black,
        child: const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 40)),
      );
}

/// Lightweight thumbnail for grids — image/GIF shown directly, video shows first frame + play icon.
class MediaThumbWidget extends StatefulWidget {
  final String path;
  final double size;

  const MediaThumbWidget({super.key, required this.path, this.size = 72});

  @override
  State<MediaThumbWidget> createState() => _MediaThumbWidgetState();
}

class _MediaThumbWidgetState extends State<MediaThumbWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    if (MediaFileService.isVideo(widget.path)) {
      _initThumb();
    }
  }

  Future<void> _initThumb() async {
    final controller = VideoPlayerController.file(File(widget.path));
    try {
      await controller.initialize();
      final mid = controller.value.duration ~/ 2;
      await controller.seekTo(mid);
      if (mounted) {
        setState(() { _controller = controller; _initialized = true; });
      } else {
        controller.dispose();
      }
    } catch (_) {
      controller.dispose();
      if (mounted) setState(() => _initFailed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = widget.path.split('.').last.toLowerCase();

    if (ext == 'gif') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(File(widget.path),
            width: widget.size, height: widget.size, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }

    if (MediaFileService.isImage(widget.path)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(File(widget.path),
            width: widget.size, height: widget.size, fit: BoxFit.cover,
            errorBuilder: (_, e, s) => _placeholder(isVideo: false)),
      );
    }

    if (MediaFileService.isVideo(widget.path)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              if (_initialized && _controller != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                )
              else if (_initFailed)
                _placeholder(isVideo: true)
              else
                _placeholder(isVideo: true, loading: true),
              Container(
                decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      );
    }

    return _placeholder(isVideo: false);
  }

  Widget _placeholder({required bool isVideo, bool loading = false}) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(6),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
            : Icon(isVideo ? Icons.videocam_outlined : Icons.image_outlined,
                color: Colors.grey.shade400),
      );
}

class _VideoWidget extends StatefulWidget {
  final String path;
  final BoxFit fit;
  const _VideoWidget({required this.path, required this.fit});

  @override
  State<_VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<_VideoWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path));
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() => _initialized = true);
        _controller.setLooping(true);
        _controller.play();
      }
    }).catchError((_) {
      if (mounted) setState(() => _initFailed = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initFailed) {
      return Container(
        color: Colors.black,
        child: const Center(child: Icon(Icons.videocam_outlined, color: Colors.white54, size: 40)),
      );
    }
    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white54)),
      );
    }
    return GestureDetector(
      onTap: () => setState(() {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      }),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context2, value, child) => AnimatedOpacity(
              opacity: value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

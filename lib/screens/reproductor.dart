import 'package:flutter/material.dart';
import '../models/movie.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  const PlayerScreen({super.key, required this.movie});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _playing = false;
  double _progress = 0.0;
  double _volume = 0.8;
  String _quality = 'HD';
  String _subtitle = 'Ninguno';

  final List<String> _qualities = ['4K', 'HD', 'SD'];
  final List<String> _subtitles = ['Ninguno', 'Español', 'Inglés', 'Portugués'];

  String _fmtTime(double p) {
    const total = 120;
    final cur = (total * p).toInt();
    final h = cur ~/ 60;
    final m = (cur % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:00' : '0:$m:00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.movie.title,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: () => setState(() => _playing = !_playing),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    widget.movie.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, e, __) => Container(
                      color: const Color(0xFF111111),
                      child: const Icon(Icons.movie, color: Colors.white12, size: 80),
                    ),
                  ),
                  Container(color: Colors.black54),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _playing
                        ? const Icon(Icons.pause_circle_filled,
                            key: ValueKey('pause'), color: Colors.white70, size: 64)
                        : const Icon(Icons.play_circle_filled,
                            key: ValueKey('play'), color: Colors.white, size: 64),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(_quality, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF7C3AED),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: const Color(0xFFEC4899),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    ),
                    child: Slider(value: _progress, onChanged: (v) => setState(() => _progress = v)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmtTime(_progress),
                            style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        Text(widget.movie.duration,
                            style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white, size: 34),
                        onPressed: () =>
                            setState(() => _progress = (_progress - 0.05).clamp(0.0, 1.0)),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () => setState(() => _playing = !_playing),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7C3AED),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.white, size: 34),
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white, size: 34),
                        onPressed: () =>
                            setState(() => _progress = (_progress + 0.05).clamp(0.0, 1.0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        _volume == 0 ? Icons.volume_off : _volume < 0.5 ? Icons.volume_down : Icons.volume_up,
                        color: Colors.white54,
                        size: 22,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white70,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(value: _volume, onChanged: (v) => setState(() => _volume = v)),
                        ),
                      ),
                      Text('${(_volume * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 28),
                  _OptionRow(
                    icon: Icons.hd_outlined,
                    label: 'Calidad',
                    value: _quality,
                    options: _qualities,
                    onChanged: (v) => setState(() => _quality = v),
                  ),
                  const SizedBox(height: 8),
                  _OptionRow(
                    icon: Icons.subtitles_outlined,
                    label: 'Subtítulos',
                    value: _subtitle,
                    options: _subtitles,
                    onChanged: (v) => setState(() => _subtitle = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final void Function(String) onChanged;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white38, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          ],
        ),
        DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1E1E2E),
          underline: const SizedBox(),
          icon: const Icon(Icons.expand_more, color: Colors.white38, size: 20),
          style: const TextStyle(color: Colors.white),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}

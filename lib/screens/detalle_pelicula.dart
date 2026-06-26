import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie.dart';
import 'reproductor.dart';
import 'trailer.dart';


const _purple = Color(0xFF7C3AED);
const _bg = Color(0xFF0F0F1A);
const _cardBg = Color(0xFF1E1E2E);
const _editBg = Color(0xFF2A2A3E);

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final int userAge;
  const MovieDetailScreen({super.key, required this.movie, required this.userAge});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final _commentCtrl = TextEditingController();
  final _editCtrl = TextEditingController();
  List<Map<String, dynamic>> _comentarios = [];
  bool _loadingComentarios = false;
  bool _enviando = false;
  String? _editandoId;

  @override
  void initState() {
    super.initState();
    _cargarComentarios();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  SupabaseClient get _sb => Supabase.instance.client;

  Future<void> _cargarComentarios() async {
    setState(() => _loadingComentarios = true);
    try {
      final res = await _sb
          .from('comentarios')
          .select()
          .eq('movie_id', widget.movie.id)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));
      if (mounted) setState(() => _comentarios = List<Map<String, dynamic>>.from(res));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingComentarios = false);
    }
  }

  Future<void> _enviarComentario() async {
    final texto = _commentCtrl.text.trim();
    final user = _sb.auth.currentUser;
    if (texto.isEmpty || user == null) return;

    final nick = (user.userMetadata?['nick'] as String?) ??
        user.email?.split('@').first ??
        'Usuario';

    setState(() => _enviando = true);
    try {
      await _sb.from('comentarios').insert({
        'movie_id': widget.movie.id,
        'user_id': user.id,
        'nick': nick,
        'texto': texto,
      }).timeout(const Duration(seconds: 10));
      _commentCtrl.clear();
      await _cargarComentarios();
    } catch (e) {
      _showSnack('Error al enviar: $e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _borrarComentario(String id) async {
    try {
      await _sb.from('comentarios').delete().eq('id', id).timeout(const Duration(seconds: 10));
      await _cargarComentarios();
    } catch (_) {}
  }

  Future<void> _guardarEdicion(String id) async {
    final texto = _editCtrl.text.trim();
    if (texto.isEmpty) return;
    try {
      await _sb.from('comentarios').update({'texto': texto}).eq('id', id)
          .timeout(const Duration(seconds: 10));
      _cancelarEdicion();
      await _cargarComentarios();
    } catch (e) {
      _showSnack('Error al editar: $e');
    }
  }

  void _iniciarEdicion(Map<String, dynamic> c) =>
      setState(() { _editandoId = c['id']; _editCtrl.text = c['texto']; });

  void _cancelarEdicion() =>
      setState(() { _editandoId = null; _editCtrl.clear(); });

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _sb.auth.currentUser?.id;
    final m = widget.movie;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(m),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _MetaBadge(label: '${m.year}', icon: Icons.calendar_today),
                      _MetaBadge(label: m.duration, icon: Icons.access_time),
                      _MetaBadge(label: m.category, icon: Icons.category_outlined),
                      _AgeChip(label: m.ageLabel, color: m.ageLabelColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StarRating(rating: m.rating),
                  const SizedBox(height: 20),
                  _sectionTitle('Descripción'),
                  const SizedBox(height: 8),
                  Text(m.description,
                      style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 32),
                  _ActionButton(
                    label: 'Ver Tráiler',
                    icon: Icons.smart_display_outlined,
                    color: const Color(0xFFFF0000),
                    textColor: Colors.white,
                    iconColor: Colors.white,
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => TrailerScreen(movie: m))),
                  ),
                  const SizedBox(height: 14),
                  _ActionButton(
                    label: 'Ver Película',
                    icon: Icons.play_arrow_rounded,
                    color: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PlayerScreen(movie: m))),
                  ),
                  const SizedBox(height: 32),
                  _sectionTitle('Comentarios'),
                  const SizedBox(height: 12),
                  _CommentInput(
                    controller: _commentCtrl,
                    sending: _enviando,
                    onSend: _enviarComentario,
                  ),
                  const SizedBox(height: 16),
                  _buildComentarios(currentUserId),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(Movie m) => SliverAppBar(
        expandedHeight: 280,
        pinned: true,
        backgroundColor: _bg,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.black54,
            child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                m.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: _cardBg,
                  child: Icon(Icons.movie, color: Colors.white12, size: 80),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD0F0F1A)],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildComentarios(String? currentUserId) {
    if (_loadingComentarios) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: _purple),
        ),
      );
    }
    if (_comentarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Sé el primero en comentar.',
            style: TextStyle(color: Colors.white38, fontSize: 14)),
      );
    }
    return Column(
      children: _comentarios.map((c) {
        final esMio = c['user_id'] == currentUserId;
        final editando = _editandoId == c['id'];
        return _CommentCard(
          comentario: c,
          esMio: esMio,
          editando: editando,
          editCtrl: _editCtrl,
          onEdit: () => _iniciarEdicion(c),
          onDelete: () => _borrarComentario(c['id']),
          onSave: () => _guardarEdicion(c['id']),
          onCancel: _cancelarEdicion,
        );
      }).toList(),
    );
  }

  static Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      );
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating / 2;
    return Row(
      children: [
        ...List.generate(5, (i) => Icon(
              i < full.floor() ? Icons.star : (i < full ? Icons.star_half : Icons.star_border),
              color: Colors.amber,
              size: 20,
            )),
        const SizedBox(width: 8),
        Text('$rating / 10', style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, textColor, iconColor;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.label, required this.icon, required this.color,
    required this.textColor, required this.iconColor, required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor),
          label: Text(label,
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  const _CommentInput({required this.controller, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: _cardBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _purple, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          sending
              ? const SizedBox(
                  width: 44, height: 44,
                  child: CircularProgressIndicator(color: _purple, strokeWidth: 2))
              : IconButton(
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded, color: _purple, size: 28)),
        ],
      );
}

class _CommentCard extends StatelessWidget {
  final Map<String, dynamic> comentario;
  final bool esMio, editando;
  final TextEditingController editCtrl;
  final VoidCallback onEdit, onDelete, onSave, onCancel;
  const _CommentCard({
    required this.comentario, required this.esMio, required this.editando,
    required this.editCtrl, required this.onEdit, required this.onDelete,
    required this.onSave, required this.onCancel,
  });

  static InputDecoration _editDeco() => InputDecoration(
        filled: true,
        fillColor: _editBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _purple, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      );

  @override
  Widget build(BuildContext context) {
    final nick = comentario['nick'] as String? ?? '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
        border: esMio ? Border.all(color: _purple, width: 1) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _purple,
            child: Text(nick[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(nick,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  if (esMio) ...[
                    const SizedBox(width: 6),
                    const Text('(tú)', style: TextStyle(color: _purple, fontSize: 11)),
                  ],
                ]),
                const SizedBox(height: 4),
                if (editando) ...[
                  TextField(
                    controller: editCtrl,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: null,
                    decoration: _editDeco(),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    _EditBtn(label: 'Guardar', filled: true, onPressed: onSave),
                    const SizedBox(width: 8),
                    _EditBtn(label: 'Cancelar', filled: false, onPressed: onCancel),
                  ]),
                ] else
                  Text(comentario['texto'] ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          if (esMio && !editando)
            Row(mainAxisSize: MainAxisSize.min, children: [
              _IconBtn(icon: Icons.edit_outlined, color: _purple, onPressed: onEdit),
              const SizedBox(width: 8),
              _IconBtn(icon: Icons.delete_outline, color: Colors.white38, onPressed: onDelete),
            ]),
        ],
      ),
    );
  }
}

class _EditBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onPressed;
  const _EditBtn({required this.label, required this.filled, required this.onPressed});

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          backgroundColor: filled ? _purple : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label,
            style: TextStyle(
                color: filled ? Colors.white : Colors.white54, fontSize: 12)),
      );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _IconBtn({required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _MetaBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white54, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      );
}

class _AgeChip extends StatelessWidget {
  final String label;
  final Color color;
  const _AgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      );
}

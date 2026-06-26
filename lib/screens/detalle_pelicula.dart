import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/movie.dart';
import 'reproductor.dart';
import 'trailer.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final int userAge;
  const MovieDetailScreen({super.key, required this.movie, required this.userAge});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final _commentCtrl = TextEditingController();
  List<Map<String, dynamic>> _comentarios = [];
  bool _loadingComentarios = false;
  bool _enviando = false;

  // Para edición
  String? _editandoId;
  final _editCtrl = TextEditingController();

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

  Future<void> _cargarComentarios() async {
    setState(() => _loadingComentarios = true);
    try {
      final res = await Supabase.instance.client
          .from('comentarios')
          .select()
          .eq('movie_id', widget.movie.id)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 10));
      if (mounted) setState(() => _comentarios = List<Map<String, dynamic>>.from(res));
    } catch (_) {
      // Si falla la carga simplemente queda vacío
    } finally {
      if (mounted) setState(() => _loadingComentarios = false);
    }
  }

  Future<void> _enviarComentario() async {
    final texto = _commentCtrl.text.trim();
    if (texto.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final nick = (user.userMetadata?['nick'] as String?) ??
        user.email?.split('@').first ??
        'Usuario';

    setState(() => _enviando = true);
    try {
      await Supabase.instance.client.from('comentarios').insert({
        'movie_id': widget.movie.id,
        'user_id': user.id,
        'nick': nick,
        'texto': texto,
      }).timeout(const Duration(seconds: 10));
      _commentCtrl.clear();
      await _cargarComentarios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _borrarComentario(String comentarioId) async {
    try {
      await Supabase.instance.client
          .from('comentarios')
          .delete()
          .eq('id', comentarioId)
          .timeout(const Duration(seconds: 10));
      await _cargarComentarios();
    } catch (_) {}
  }

  void _iniciarEdicion(Map<String, dynamic> comentario) {
    setState(() {
      _editandoId = comentario['id'];
      _editCtrl.text = comentario['texto'];
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _editandoId = null;
      _editCtrl.clear();
    });
  }

  Future<void> _guardarEdicion(String comentarioId) async {
    final texto = _editCtrl.text.trim();
    if (texto.isEmpty) return;
    try {
      await Supabase.instance.client
          .from('comentarios')
          .update({'texto': texto})
          .eq('id', comentarioId)
          .timeout(const Duration(seconds: 10));
      _cancelarEdicion();
      await _cargarComentarios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al editar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F1A),
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
                    widget.movie.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, _) => Container(
                      color: const Color(0xFF1E1E2E),
                      child: const Icon(Icons.movie, color: Colors.white12, size: 80),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _MetaBadge(label: '${widget.movie.year}', icon: Icons.calendar_today),
                      _MetaBadge(label: widget.movie.duration, icon: Icons.access_time),
                      _MetaBadge(label: widget.movie.category, icon: Icons.category_outlined),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.movie.ageLabelColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(widget.movie.ageLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final full = widget.movie.rating / 2;
                        return Icon(
                          i < full.floor()
                              ? Icons.star
                              : (i < full ? Icons.star_half : Icons.star_border),
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text('${widget.movie.rating} / 10',
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Descripción',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.movie.description,
                      style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TrailerScreen(movie: widget.movie)),
                      ),
                      icon: const Icon(Icons.smart_display_outlined, color: Colors.white),
                      label: const Text('Ver Tráiler',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlayerScreen(movie: widget.movie)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                      label: const Text('Ver Película',
                          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Sección de comentarios ──
                  const Text('Comentarios',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Campo para escribir comentario
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          style: const TextStyle(color: Colors.white),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Escribe un comentario...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF1E1E2E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _enviando
                          ? const SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                  color: Color(0xFF7C3AED), strokeWidth: 2),
                            )
                          : IconButton(
                              onPressed: _enviarComentario,
                              icon: const Icon(Icons.send_rounded, color: Color(0xFF7C3AED), size: 28),
                            ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lista de comentarios
                  _loadingComentarios
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                          ),
                        )
                      : _comentarios.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('Sé el primero en comentar.',
                                  style: TextStyle(color: Colors.white38, fontSize: 14)),
                            )
                          : Column(
                              children: _comentarios.map((c) {
                                final esMio = c['user_id'] == currentUserId;
                                final estaEditando = _editandoId == c['id'];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E2E),
                                    borderRadius: BorderRadius.circular(10),
                                    border: esMio
                                        ? Border.all(color: const Color(0xFF7C3AED), width: 1)
                                        : null,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: const Color(0xFF7C3AED),
                                        child: Text(
                                          (c['nick'] as String? ?? '?')[0].toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  c['nick'] ?? 'Usuario',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13),
                                                ),
                                                if (esMio) ...[
                                                  const SizedBox(width: 6),
                                                  const Text('(tú)',
                                                      style: TextStyle(
                                                          color: Color(0xFF7C3AED),
                                                          fontSize: 11)),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            // Modo edición o modo lectura
                                            if (estaEditando) ...[
                                              TextField(
                                                controller: _editCtrl,
                                                autofocus: true,
                                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: const Color(0xFF2A2A3E),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: const BorderSide(
                                                        color: Color(0xFF7C3AED), width: 1.5),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 10, vertical: 8),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () => _guardarEdicion(c['id']),
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 12, vertical: 4),
                                                      backgroundColor: const Color(0xFF7C3AED),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(6)),
                                                    ),
                                                    child: const Text('Guardar',
                                                        style: TextStyle(
                                                            color: Colors.white, fontSize: 12)),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TextButton(
                                                    onPressed: _cancelarEdicion,
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 12, vertical: 4),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(6)),
                                                    ),
                                                    child: const Text('Cancelar',
                                                        style: TextStyle(
                                                            color: Colors.white54, fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                            ] else
                                              Text(c['texto'] ?? '',
                                                  style: const TextStyle(
                                                      color: Colors.white70, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      if (esMio && !estaEditando)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined,
                                                  color: Color(0xFF7C3AED), size: 18),
                                              onPressed: () => _iniciarEdicion(c),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline,
                                                  color: Colors.white38, size: 18),
                                              onPressed: () => _borrarComentario(c['id']),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _MetaBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

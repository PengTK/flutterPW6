// lib/screens/movie_form_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/models/movie.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie;

  const MovieFormScreen({super.key, this.movie});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _yearController;
  late final TextEditingController _genreController;
  late final TextEditingController _imageController;

  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.movie != null;
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _yearController = TextEditingController(text: widget.movie?.year.toString() ?? '');
    _genreController = TextEditingController(text: widget.movie?.genre ?? '');
    _imageController = TextEditingController(text: widget.movie?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveMovie() {
    final title = _titleController.text.trim();
    final yearStr = _yearController.text.trim();
    final genre = _genreController.text.trim();
    final imageUrl = _imageController.text.trim();

    if (title.isEmpty || yearStr.isEmpty || genre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    int year;
    try {
      year = int.parse(yearStr);
      if (year < 1890 || year > DateTime.now().year + 5) {
        throw FormatException();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Год должен быть числом (1890–2030)')),
      );
      return;
    }

    final box = Hive.box<Movie>('movies');

    if (_isEditing) {
      widget.movie!.title = title;
      widget.movie!.year = year;
      widget.movie!.genre = genre;
      widget.movie!.imageUrl = imageUrl;
      widget.movie!.save();
    } else {
      box.add(Movie(
        title: title,
        year: year,
        genre: genre,
        imageUrl: imageUrl,
      ));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать фильм' : 'Добавить фильм'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Год выпуска'),
            ),
            TextField(
              controller: _genreController,
              decoration: const InputDecoration(labelText: 'Жанр'),
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'URL изображения'),
            ),
            const SizedBox(height: 20),
            if (_imageController.text.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageController.text,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('Ошибка загрузки изображения'),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMovie,
              child: Text(_isEditing ? 'Сохранить' : 'Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
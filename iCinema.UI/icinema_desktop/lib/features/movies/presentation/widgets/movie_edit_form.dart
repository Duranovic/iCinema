import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../domain/movie.dart';

class MovieEditForm extends StatefulWidget {
  final Movie? movie; // null if adding
  final List<dynamic> genres;
  final List<dynamic> ageRatings; // [{code,label}]
  final VoidCallback onClose;
  final void Function(Movie, String?, String?) onSave;

  const MovieEditForm({
    super.key,
    required this.movie,
    required this.onClose,
    required this.onSave,
    required this.genres,
    required this.ageRatings,
  });

  @override
  State<MovieEditForm> createState() => _MovieEditFormState();
}

class _MovieEditFormState extends State<MovieEditForm> {
  final _formKey = GlobalKey<FormState>();
  late Set<String> selectedIds;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _dateReleaseCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _durationCtrl;
  String? _posterPath;
  String? _posterMime;
  bool _isDragOver = false;
  String? _ageRating;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.movie?.title ?? '');
    _dateReleaseCtrl = TextEditingController(
        text: widget.movie?.releaseDate?.toIso8601String().split('T').first ??
            '');
    _descriptionCtrl =
        TextEditingController(text: widget.movie?.description.toString() ?? '');
    _durationCtrl =
        TextEditingController(text: widget.movie?.duration?.toString() ?? '');
    _ageRating = widget.movie?.ageRating;
    // Ensure selected ageRating exists in provided options
    final allowedCodes = widget.ageRatings
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .where((e) => e['code'] is String)
        .map((e) => e['code'] as String)
        .toSet();
    if (_ageRating != null && !allowedCodes.contains(_ageRating)) {
      _ageRating = null;
    }
    // Initialize a mutable set of selected genre IDs; prefill when editing.
    // Normalize any stored names to their IDs using provided widget.genres.
    final provided = widget.genres
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    final idByName = <String, String>{
      for (final g in provided)
        if (g['name'] is String && g['id'] is String)
          (g['name'] as String): (g['id'] as String)
    };
    final idsSet = <String>{
      for (final g in provided)
        if (g['id'] is String) g['id'] as String
    };

    final initial = <String>{...?(widget.movie?.genres)};
    selectedIds = initial.map((g) {
      // If it's already an ID we recognize, keep it; otherwise try map from name -> id.
      if (idsSet.contains(g)) return g;
      return idByName[g] ?? g; // fallback to original to avoid losing user data
    }).toSet();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateReleaseCtrl.dispose();
    _descriptionCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final dateText = _dateReleaseCtrl.text.trim();
      DateTime? parsedDate;
      if (dateText.isNotEmpty) {
        try {
          parsedDate = DateTime.parse(dateText);
        } catch (_) {
          parsedDate = null; // Leave null if parsing fails
        }
      }
      widget.onSave(
        Movie(
          id: widget.movie?.id,
          title: _titleCtrl.text.trim(),
          releaseDate: parsedDate,
          description: _descriptionCtrl.text.trim(),
          duration: int.tryParse(_durationCtrl.text) ?? 0,
          genres: selectedIds.toList(),
          ageRating: _ageRating,
        ),
        _posterPath,
        _posterMime,
      );
    }
  }

  void _handleDroppedFiles(List<String> paths) {
    if (paths.isEmpty) return;
    
    final path = paths.first;
    final mime = lookupMimeType(path);
    const allowed = {'image/jpeg', 'image/png', 'image/webp'};
    
    if (mime == null || !allowed.contains(mime)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepodržan format slike. Dozvoljeno: JPG, PNG, WEBP.')),
        );
      }
      return;
    }
    
    setState(() {
      _posterPath = path;
      _posterMime = mime;
    });
    
    if (mounted) {
      final fileName = path.split('/').last;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Odabrano: $fileName')),
      );
    }
  }

  Future<void> _pickPosterClick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        dialogTitle: 'Odaberite poster',
      );
      
      if (result == null || result.files.isEmpty) return;
      
      final file = result.files.first;
      final path = file.path;
      
      if (path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Greška: Putanja do datoteke nije dostupna')),
          );
        }
        return;
      }

      final mime = lookupMimeType(path);
      const allowed = {'image/jpeg', 'image/png', 'image/webp'};
      
      if (mime == null || !allowed.contains(mime)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nepodržan format slike. Dozvoljeno: JPG, PNG, WEBP.')),
          );
        }
        return;
      }
      
      setState(() {
        _posterPath = path;
        _posterMime = mime;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Odabrano: ${file.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri otvaranju dijaloga: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDate: DateTime.now());

    if (picked != null) {
      setState(() {
        _dateReleaseCtrl.text = picked.toString().split(" ")[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movie != null;

    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit ? 'Uredi film' : 'Dodaj film',
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                          tooltip: 'Zatvori',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Naziv filma',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Unesite naziv filma.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          // Age Rating dropdown
                          DropdownButtonFormField<String>(
                            value: _ageRating,
                            items: widget.ageRatings
                                .whereType<Map>()
                                .map((e) => e.cast<String, dynamic>())
                                .where((e) => e['code'] is String && e['label'] is String)
                                .map((e) => DropdownMenuItem<String>(
                                      value: e['code'] as String,
                                      child: Text(e['label'] as String, overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _ageRating = val),
                            decoration: const InputDecoration(
                              labelText: 'Dobna preporuka',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Odaberite dobnu preporuku.' : null,
                          ),
                          const SizedBox(height: 12),

                          // use TextFormField for consistency
                          TextFormField(
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            controller: _descriptionCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Opis filma',
                              hintText: 'Unesite opis filma...',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Unesite opis filma.'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _durationCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Trajanje filma (min)',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    final n = int.tryParse(v ?? '');
                                    if (n != null && n <= 0) {
                                      return 'Unesite broj veći od 0.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _dateReleaseCtrl,
                                  onTap: _selectDate,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Datum',
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
                                    filled: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Poster drag-and-drop UI
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Poster (opcionalno)',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(height: 8),
                                DropTarget(
                                  onDragDone: (details) {
                                    _handleDroppedFiles(details.files.map((f) => f.path).toList());
                                  },
                                  onDragEntered: (details) {
                                    setState(() {
                                      _isDragOver = true;
                                    });
                                  },
                                  onDragExited: (details) {
                                    setState(() {
                                      _isDragOver = false;
                                    });
                                  },
                                  child: GestureDetector(
                                    onTap: _pickPosterClick,
                                    child: Container(
                                      width: double.infinity,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _isDragOver 
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.outline,
                                          width: _isDragOver ? 2 : 1,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: _isDragOver 
                                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                            : Theme.of(context).colorScheme.surface,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _posterPath != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                                            size: 32,
                                            color: _posterPath != null 
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _posterPath != null
                                                ? _posterPath!.split('/').last
                                                : 'Povucite sliku ovdje ili kliknite',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: _posterPath != null 
                                                  ? Theme.of(context).colorScheme.primary
                                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Dozvoljeni formati: JPG, PNG, WEBP',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Theme.of(context).hintColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Žanrovi (odabir više)',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(height: 8),
                                FormField<bool>(
                                  validator: (_) => selectedIds.isEmpty
                                      ? 'Odaberite barem jedan žanr.'
                                      : null,
                                  builder: (state) => Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 4,
                                        children: widget.genres
                                            .whereType<Map>()
                                            .map((g) => g.cast<String, dynamic>())
                                            .where((g) => g['id'] is String && g['name'] is String)
                                            .map((genre) {
                                          final String id = genre['id'] as String;
                                          final String name = genre['name'] as String;
                                          return IntrinsicWidth(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 180),
                                              child: CheckboxListTile(
                                                dense: true,
                                                visualDensity: VisualDensity.compact,
                                                contentPadding: EdgeInsets.zero,
                                                controlAffinity: ListTileControlAffinity.leading,
                                                title: Text(
                                                  name,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                value: selectedIds.contains(id),
                                                onChanged: (bool? checked) {
                                                  setState(() {
                                                    if (checked == true) {
                                                      selectedIds.add(id);
                                                    } else {
                                                      selectedIds.remove(id);
                                                    }
                                                  });
                                                  state.validate();
                                                },
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      if (state.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            state.errorText!,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    // actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onClose,
                            child: const Text('Poništi'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _onSave,
                            child: Text(isEdit ? 'Spasi' : 'Dodaj'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

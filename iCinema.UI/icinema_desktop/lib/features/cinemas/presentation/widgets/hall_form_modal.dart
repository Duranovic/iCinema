import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projections/domain/hall.dart';
import '../bloc/cinemas_bloc.dart';
import '../bloc/cinemas_event.dart';

class HallFormModal extends StatefulWidget {
  final String cinemaId;
  final Hall? hall; // null for create, non-null for edit
  final String cinemaName;

  const HallFormModal({
    super.key,
    required this.cinemaId,
    this.hall,
    required this.cinemaName,
  });

  @override
  State<HallFormModal> createState() => _HallFormModalState();
}

class _HallFormModalState extends State<HallFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rowsController = TextEditingController();
  final _seatsPerRowController = TextEditingController();
  
  bool _isDolbyAtmos = false;
  int _calculatedCapacity = 0;
  String? _selectedHallType;
  String? _selectedScreenSize;

  // Predefined options
  final List<String> _hallTypes = [
    'Standard',
    'VIP',
    'IMAX',
    'Premium',
    'Luxury',
    '4DX',
    'ScreenX',
  ];

  final List<String> _screenSizes = [
    'Mali (do 10m)',
    'Srednji (10-15m)',
    'Veliki (15-20m)',
    'IMAX (20m+)',
    'Premium Large',
  ];

  @override
  void initState() {
    super.initState();
    
    // Pre-populate fields if editing
    if (widget.hall != null) {
      final hall = widget.hall!;
      _nameController.text = hall.name;
      _rowsController.text = hall.rowsCount.toString();
      _seatsPerRowController.text = hall.seatsPerRow.toString();
      _selectedHallType = _hallTypes.contains(hall.hallType) ? hall.hallType : null;
      _selectedScreenSize = _screenSizes.contains(hall.screenSize) ? hall.screenSize : null;
      _isDolbyAtmos = hall.isDolbyAtmos;
      _calculateCapacity();
    }
    
    // Add listeners for capacity calculation
    _rowsController.addListener(_calculateCapacity);
    _seatsPerRowController.addListener(_calculateCapacity);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rowsController.dispose();
    _seatsPerRowController.dispose();
    super.dispose();
  }

  void _calculateCapacity() {
    final rows = int.tryParse(_rowsController.text) ?? 0;
    final seatsPerRow = int.tryParse(_seatsPerRowController.text) ?? 0;
    setState(() {
      _calculatedCapacity = rows * seatsPerRow;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.hall != null;
    
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Uredi salu' : 'Dodaj novu salu',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.cinemaName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hall name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Naziv sale *',
                          hintText: 'npr. Sala 1, VIP Sala, IMAX',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.meeting_room),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Naziv sale je obavezan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Capacity section
                      Text(
                        'Kapacitet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rowsController,
                              decoration: const InputDecoration(
                                labelText: 'Broj redova *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.table_rows),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                final num = int.tryParse(value ?? '');
                                if (num == null || num <= 0) {
                                  return 'Unesite valjan broj redova';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _seatsPerRowController,
                              decoration: const InputDecoration(
                                labelText: 'Sjedišta po redu *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event_seat),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                final num = int.tryParse(value ?? '');
                                if (num == null || num <= 0) {
                                  return 'Unesite valjan broj sjedišta';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Capacity display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calculate,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ukupan kapacitet: $_calculatedCapacity mjesta',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Technical specifications
                      Text(
                        'Tehničke specifikacije',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedHallType,
                        decoration: const InputDecoration(
                          labelText: 'Tip sale',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        hint: const Text('Odaberite tip sale'),
                        items: _hallTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedHallType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedScreenSize,
                        decoration: const InputDecoration(
                          labelText: 'Veličina ekrana',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.aspect_ratio),
                        ),
                        hint: const Text('Odaberite veličinu ekrana'),
                        items: _screenSizes.map((size) {
                          return DropdownMenuItem<String>(
                            value: size,
                            child: Text(size),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedScreenSize = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Dolby Atmos checkbox
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isDolbyAtmos,
                              onChanged: (value) {
                                setState(() {
                                  _isDolbyAtmos = value ?? false;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dolby Atmos',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Sala podržava Dolby Atmos zvučni sistem',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Otkaži'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(isEditing ? 'Ažuriraj' : 'Kreiraj'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final rows = int.parse(_rowsController.text);
      final seatsPerRow = int.parse(_seatsPerRowController.text);
      
      if (widget.hall != null) {
        // Update existing hall
        context.read<CinemasBloc>().add(UpdateHall(
          cinemaId: widget.cinemaId,
          hallId: widget.hall!.id!,
          name: _nameController.text.trim(),
          rowsCount: rows,
          seatsPerRow: seatsPerRow,
          hallType: _selectedHallType ?? '',
          screenSize: _selectedScreenSize ?? '',
          isDolbyAtmos: _isDolbyAtmos,
        ));
      } else {
        // Create new hall
        context.read<CinemasBloc>().add(CreateHall(
          cinemaId: widget.cinemaId,
          name: _nameController.text.trim(),
          rowsCount: rows,
          seatsPerRow: seatsPerRow,
          hallType: _selectedHallType ?? '',
          screenSize: _selectedScreenSize ?? '',
          isDolbyAtmos: _isDolbyAtmos,
        ));
      }
      
      Navigator.of(context).pop();
    }
  }
}

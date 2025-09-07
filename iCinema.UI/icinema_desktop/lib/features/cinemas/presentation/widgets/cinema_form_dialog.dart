import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../projections/domain/cinema.dart';
import '../../domain/city.dart';
import '../bloc/cinemas_bloc.dart';
import '../bloc/cinemas_event.dart';
import '../bloc/cinemas_state.dart';

class CinemaFormDialog extends StatefulWidget {
  final Cinema? cinema; // null for create, non-null for edit

  const CinemaFormDialog({
    super.key,
    this.cinema,
  });

  @override
  State<CinemaFormDialog> createState() => _CinemaFormDialogState();
}

class _CinemaFormDialogState extends State<CinemaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    
    // Pre-populate fields if editing
    if (widget.cinema != null) {
      final cinema = widget.cinema!;
      _nameController.text = cinema.name;
      _addressController.text = cinema.address;
      _emailController.text = cinema.email ?? '';
      _phoneController.text = cinema.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cinema != null;
    
    return BlocBuilder<CinemasBloc, CinemasState>(
      builder: (context, state) {
        final cities = <City>[];
        if (state is CinemasLoaded) {
          cities.addAll(state.cities);
        } else if (state is CinemaSelected) {
          cities.addAll(state.cities);
          
          // Set selected city for editing if not already set
          if (isEditing && _selectedCity == null && widget.cinema!.cityId != null) {
            _selectedCity = cities.where((city) => city.id == widget.cinema!.cityId).firstOrNull;
          }
        }

        return AlertDialog(
          title: Text(isEditing ? 'Uredi kino' : 'Kreiraj novo kino'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Required fields first
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Naziv kina *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_movies),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Naziv kina je obavezan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Adresa *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Adresa je obavezna';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // City selection dropdown - required field
                  DropdownButtonFormField<City>(
                    value: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'Grad *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    hint: const Text('Odaberite grad'),
                    items: cities.map((city) {
                      return DropdownMenuItem<City>(
                        value: city,
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (City? city) {
                      setState(() {
                        _selectedCity = city;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Odabir grada je obavezan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Optional fields
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  if (cities.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_outlined,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Gradovi se učitavaju...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (isEditing) {
                    // Update existing cinema
                    context.read<CinemasBloc>().add(UpdateCinema(
                      cinemaId: widget.cinema!.id!,
                      name: _nameController.text.trim(),
                      address: _addressController.text.trim(),
                      email: _emailController.text.trim().isEmpty 
                          ? null 
                          : _emailController.text.trim(),
                      phoneNumber: _phoneController.text.trim().isEmpty 
                          ? null 
                          : _phoneController.text.trim(),
                      cityId: _selectedCity!.id,
                    ));
                  } else {
                    // Create new cinema
                    context.read<CinemasBloc>().add(CreateCinema(
                      name: _nameController.text.trim(),
                      address: _addressController.text.trim(),
                      email: _emailController.text.trim().isEmpty 
                          ? null 
                          : _emailController.text.trim(),
                      phoneNumber: _phoneController.text.trim().isEmpty 
                          ? null 
                          : _phoneController.text.trim(),
                      cityId: _selectedCity!.id,
                    ));
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? 'Ažuriraj' : 'Kreiraj'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../models/POI.dart';
import 'package:myapp/database_helper.dart';
import 'map_screen.dart';

class EditPOIScreen extends StatefulWidget {
  final PointOfInterest poi;

  const EditPOIScreen({Key? key, required this.poi}) : super(key: key);

  @override
  _EditPOIScreenState createState() => _EditPOIScreenState();
}

class _EditPOIScreenState extends State<EditPOIScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _latitude;
  late double _longitude;

  @override
  void initState() {
    super.initState();
    _name = widget.poi.name;
    _description = widget.poi.description;
    _latitude = widget.poi.latitude;
    _longitude = widget.poi.longitude;
  }

  void _savePOI() async {
    if (_formKey.currentState!.validate()) {
      // Simpan perubahan ke database
      await DatabaseHelper().updatePOI(widget.poi.id, _name, _description, _latitude, _longitude);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit POI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nama POI'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
                onChanged: (value) => _name = value,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Deskripsi POI'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
                onChanged: (value) => _description = value,
              ),
              // Tambahkan input untuk latitude dan longitude jika diperlukan
              ElevatedButton(
                onPressed: _savePOI,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
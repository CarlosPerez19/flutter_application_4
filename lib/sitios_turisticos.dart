import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TurismoPage extends StatefulWidget {
  const TurismoPage({super.key});

  @override
  State<TurismoPage> createState() => _TurismoPageState();
}

class _TurismoPageState extends State<TurismoPage> {
  final CollectionReference turismoRef =
      FirebaseFirestore.instance.collection('turismo');

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();

  void _agregarEntrada() async {
    if (_formKey.currentState!.validate()) {
      await turismoRef.add({
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'foto': _fotoController.text.trim(),
        'ubicacion': GeoPoint(
          double.parse(_latitudController.text),
          double.parse(_longitudController.text),
        ),
        'fecha': FieldValue.serverTimestamp(),
        'autor': _autorController.text.trim(),
      });

      _nombreController.clear();
      _descripcionController.clear();
      _fotoController.clear();
      _latitudController.clear();
      _longitudController.clear();
      _autorController.clear();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada de turismo agregada')),
      );
    }
  }

  String _horaMinutos(Timestamp? timestamp) {
    if (timestamp == null) return 'Sin hora';
    final hora = timestamp.toDate().toLocal();
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog de Turismo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese el nombre' : null,
                  ),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese la descripción' : null,
                  ),
                  TextFormField(
                    controller: _fotoController,
                    decoration: const InputDecoration(labelText: 'URL de la Foto'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese la URL de la foto' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudController,
                          decoration: const InputDecoration(labelText: 'Latitud'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || double.tryParse(value) == null
                                  ? 'Latitud inválida'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudController,
                          decoration: const InputDecoration(labelText: 'Longitud'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || double.tryParse(value) == null
                                  ? 'Longitud inválida'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _autorController,
                    decoration: const InputDecoration(labelText: 'Autor'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese el autor' : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _agregarEntrada,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Entrada'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: turismoRef.orderBy('fecha', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No hay entradas de turismo.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final hora = _horaMinutos(data['fecha']);

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: data['foto'] != null && data['foto'].toString().isNotEmpty
                            ? Image.network(data['foto'], width: 60, height: 60, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                        title: Text(data['nombre']),
                        subtitle: Text(
                          '${data['descripcion']}\nAutor: ${data['autor']}\nHora: $hora\nLat: ${data['ubicacion']?.latitude}, Lng: ${data['ubicacion']?.longitude}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
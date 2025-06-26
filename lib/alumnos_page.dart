import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlumnosPage extends StatefulWidget {
  const AlumnosPage({super.key});

  @override
  _AlumnosPageState createState() => _AlumnosPageState();
}

class _AlumnosPageState extends State<AlumnosPage> {
  final CollectionReference alumnosRef =
      FirebaseFirestore.instance.collection('alumnos');

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pasatiempoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();

  void _agregarAlumno() async {
    if (_formKey.currentState!.validate()) {
      await alumnosRef.add({
        'nombre': _nombreController.text,
        'edad': int.tryParse(_edadController.text),
        'pasatiempo': _pasatiempoController.text,
        'mensaje': _mensajeController.text,
        'hora': FieldValue.serverTimestamp(),
      });

      _nombreController.clear();
      _edadController.clear();
      _pasatiempoController.clear();
      _mensajeController.clear();

      Navigator.of(context).pop(); // Cierra el modal

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alumno agregado')),
      );
    }
  }

  void _mostrarFormulario() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrar Alumno'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                ),
                TextFormField(
                  controller: _edadController,
                  decoration: InputDecoration(labelText: 'Edad'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || int.tryParse(value) == null
                          ? 'Ingrese una edad válida'
                          : null,
                ),
                TextFormField(
                  controller: _pasatiempoController,
                  decoration: InputDecoration(labelText: 'Pasatiempo'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese un pasatiempo' : null,
                ),
                TextFormField(
                  controller: _mensajeController,
                  decoration: InputDecoration(labelText: 'Mensaje'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese un mensaje' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _agregarAlumno,
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  String _formatearHora(dynamic timestamp) {
    if (timestamp == null) return 'Sin hora';
    DateTime? date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return 'Sin hora';
    }
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Alumnos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.person_add),
                label: Text('Registrar Alumno'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                onPressed: _mostrarFormulario,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: alumnosRef.orderBy('hora', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(child: Text('No hay alumnos registrados.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final docData = docs[index].data();
                      if (docData is! Map<String, dynamic>) {
                        return ListTile(title: Text('Datos no válidos'));
                      }

                      final data = docData;
                      final nombre = data['nombre'] ?? 'Sin nombre';
                      final edad = data['edad']?.toString() ?? '?';
                      final pasatiempo = data['pasatiempo'] ?? 'Ninguno';
                      final mensaje = data['mensaje'] ?? 'Sin mensaje';
                      final hora = _formatearHora(data['hora']);

                      return ListTile(
                        leading: CircleAvatar(child: Text(edad)),
                        title: Text(nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pasatiempo: $pasatiempo'),
                            Text('Mensaje: $mensaje'),
                            Text('Hora: $hora'),
                          ],
                        ),
                      );
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

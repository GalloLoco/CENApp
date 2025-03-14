import 'package:flutter/material.dart';

class BuscarServidorScreen extends StatelessWidget {
  const BuscarServidorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        // 🔹 Envuelve todo en un scroll para evitar que lo tape el teclado
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Buscar Formato',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text('Búsqueda por ID o nombre del inmueble:'),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text('Fecha de creación:'),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text('Fecha de modificación:'),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text('Ubicación geográfica:'),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      items: [],
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        labelText: 'Colonia',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Calle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('Búsqueda por usuario creador:'),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF80C0ED), // Color azul personalizado
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    
                  ),
                  child: Text(
                    'Buscar',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Nombre del inmueble')),
                    DataColumn(label: Text('Fecha Creación')),
                    DataColumn(label: Text('Fecha Modificación')),
                    DataColumn(label: Text('Ubicación')),
                    DataColumn(label: Text('Usuario Creador')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('01')),
                      DataCell(Text('Instituto Tecnologico')),
                      DataCell(Text('08/02/2025')),
                      DataCell(Text('10/02/2025')),
                      DataCell(Text('Santa Fe')),
                      DataCell(Text('Mario Alejandro')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('02')),
                      DataCell(Text('Muebles Dico')),
                      DataCell(Text('10/02/2025')),
                      DataCell(Text('10/02/2025')),
                      DataCell(Text('Camino Real')),
                      DataCell(Text('Noelia Cano')),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

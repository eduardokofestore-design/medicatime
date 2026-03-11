import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Medicações'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add_medication');
        },
        label: Text('Adicionar Medicação'),
        icon: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Medication>>(
        stream: medicationProvider.getMedications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final medications = snapshot.data!;
            return ListView.builder(
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final med = medications[index];
                return ListTile(
                  title: Text(med.name),
                  subtitle: Text('${med.dosage} - ${med.isDaily ? 'Diário' : 'Semanal'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/add_medication',
                              arguments: med);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await medicationProvider.deleteMedication(med.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Show details or mark as taken
                    _showMedicationDetails(context, med, medicationProvider);
                  },
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showMedicationDetails(BuildContext context, Medication med,
      MedicationProvider medicationProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(med.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dosagem: ${med.dosage}'),
            Text('Horários: ${med.times.join(', ')}'),
            Text('Notas: ${med.notes}'),
            SizedBox(height: 10),
            ...med.times.map((time) => Row(
                  children: [
                    Text('$time: '),
                    ElevatedButton(
                      onPressed: () async {
                        await medicationProvider.markAsTaken(med.id, time);
                        Navigator.of(context).pop();
                      },
                      child: Text('Tomado'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await medicationProvider.markAsSkipped(med.id, time);
                        Navigator.of(context).pop();
                      },
                      child: Text('Ignorado'),
                    ),
                  ],
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
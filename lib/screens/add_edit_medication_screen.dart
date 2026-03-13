import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../models/medication.dart';

class AddEditMedicationScreen extends StatefulWidget {
  const AddEditMedicationScreen({super.key});

  @override
  State<AddEditMedicationScreen> createState() =>
      _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isDaily = true;
  List<String> _times = [];
  List<int> _days = [];

  String _mealOption = "Nenhum";
  IconData _selectedIcon = Icons.medication;
  String _medicationType = "Comprimido"; // Novo campo para armazenar o tipo como string

  Medication? _medication;

  final Map<String, IconData> _medIcons = {
    "Comprimido": Icons.medication,
    "Cápsula": Icons.medication_liquid,
    "Injeção": Icons.vaccines,
    "Xarope": Icons.local_drink,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Medication) {
      _medication = args;

      _nameController.text = _medication!.name;
      _dosageController.text = _medication!.dosage;
      _notesController.text = _medication!.notes;

      _isDaily = _medication!.isDaily;
      _times = List.from(_medication!.times);
      _days = _medication!.days ?? [];

      // Inicializar os novos campos
      _mealOption = _medication!.mealOption;
      _medicationType = _medication!.type;
      _selectedIcon = _medIcons[_medicationType] ?? Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _medication == null
              ? "Adicionar Medicação"
              : "Editar Medicação",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              /// Tipo de medicamento
              const Text(
                "Tipo de medicamento",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: _medIcons.entries.map((entry) {
                  return ChoiceChip(
                    label: Text(entry.key),
                    avatar: Icon(entry.value),
                    selected: _selectedIcon == entry.value,
                    onSelected: (_) {
                      setState(() {
                        _selectedIcon = entry.value;
                        _medicationType = entry.key; // Atualizar o tipo como string
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome do medicamento",
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Campo obrigatório"
                        : null,
              ),

              const SizedBox(height: 10),

              /// Dosagem
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: "Dosagem",
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Campo obrigatório"
                        : null,
              ),

              const SizedBox(height: 10),

              /// Refeição
              DropdownButtonFormField(
                initialValue: _mealOption,
                items: const [
                  DropdownMenuItem(value: "Nenhum", child: Text("Sem relação com refeição")),
                  DropdownMenuItem(value: "Antes", child: Text("Antes da refeição")),
                  DropdownMenuItem(value: "Depois", child: Text("Depois da refeição")),
                ],
                onChanged: (value) {
                  setState(() {
                    _mealOption = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Tomar",
                  prefixIcon: Icon(Icons.restaurant),
                ),
              ),

              const SizedBox(height: 20),

              /// Diário
              SwitchListTile(
                title: const Text("Tomar todos os dias"),
                value: _isDaily,
                onChanged: (value) {
                  setState(() {
                    _isDaily = value;
                  });
                },
              ),

              /// Dias da semana
              if (!_isDaily) ...[
                const SizedBox(height: 10),
                const Text(
                  "Dias da semana",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 5,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    return FilterChip(
                      label: Text(_getDayName(day)),
                      selected: _days.contains(day),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _days.add(day);
                          } else {
                            _days.remove(day);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],

              const SizedBox(height: 20),

              /// Horários
              const Text(
                "Horários",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              ..._times.map(
                (time) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(time),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _times.remove(time);
                        });
                      },
                    ),
                  ),
                ),
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.add_alarm),
                label: const Text("Adicionar horário"),
                onPressed: _addTime,
              ),

              const SizedBox(height: 20),

              /// Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: "Observações",
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                child: const Text("Salvar"),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  if (_times.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Adicione pelo menos um horário"),
                      ),
                    );
                    return;
                  }

                  final med = Medication(
                    id: _medication?.id ?? "",
                    name: _nameController.text,
                    dosage: _dosageController.text,
                    isDaily: _isDaily,
                    times: _times,
                    days: _isDaily ? null : _days,
                    notes: _notesController.text,
                    type: _medicationType,
                    mealOption: _mealOption,
                  );

                  if (_medication == null) {
                    await provider.addMedication(med);
                    // Após adicionar, navegar para a tela de lista de medicações
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/medications',
                        (route) => route.settings.name == '/',
                      );
                    }
                  } else {
                    await provider.updateMedication(med);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      final formatted =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

      if (_times.contains(formatted)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Horário já adicionado")),
        );
        return;
      }

      setState(() {
        _times.add(formatted);
      });
    }
  }

  String _getDayName(int day) {
    const days = [
      "Seg",
      "Ter",
      "Qua",
      "Qui",
      "Sex",
      "Sáb",
      "Dom"
    ];

    return days[day - 1];
  }
}
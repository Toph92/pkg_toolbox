import 'package:flutter/material.dart';
import 'package:pkg_toolbox/toolbox.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Calendar Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const FlightCalendarExample(),
    );
  }
}

class FlightCalendarExample extends StatefulWidget {
  const FlightCalendarExample({super.key});

  @override
  State<FlightCalendarExample> createState() => _FlightCalendarExampleState();
}

class _FlightCalendarExampleState extends State<FlightCalendarExample> {
  late FlightDates flightDates;

  @override
  void initState() {
    super.initState();
    // Créer des données d'exemple
    flightDates = FlightDates([
      FlightDay(2025, 9, 15, nbFlights: 2),
      FlightDay(2025, 9, 16, nbFlights: 1),
      FlightDay(2025, 9, 20, nbFlights: 3),
      FlightDay(2025, 9, 25, nbFlights: 1),
      FlightDay(2025, 9, 26, nbFlights: 1),
      FlightDay(2025, 10, 1, nbFlights: 2),
      FlightDay(2025, 10, 5, nbFlights: 1),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Calendar Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Sélectionnez une date de vol :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Material(
                elevation: 4,
                child: FlightCalendarWidget(flightDates: flightDates),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final date25 = flightDates.flightDays.firstWhere(
                  (day) => day.day == 25 && day.month == 9 && day.year == 2025,
                  orElse: () => flightDates.flightDays[0],
                );
                flightDates.selectedDate = date25;
              },
              child: const Text('Sélectionner le 25 septembre'),
            ),
            const SizedBox(height: 20),
            if (flightDates.selectedDate != null)
              Text(
                'Date sélectionnée : ${flightDates.selectedDate!.day}/${flightDates.selectedDate!.month}/${flightDates.selectedDate!.year} - ${flightDates.selectedDate!.nbFlights} vol(s)',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

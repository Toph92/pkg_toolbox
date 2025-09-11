import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Classe représentant un jour avec un nombre de vols
class FlightDay extends DateTime {
  FlightDay(super.year, super.month, super.day, {this.nbFlights});
  FlightDay.fromDateTime(DateTime date, {this.nbFlights})
    : super(date.year, date.month, date.day);
  int? nbFlights;
}

/// Liste de dates et date sélectionnée
class FlightDates with ChangeNotifier {
  final List<FlightDay> flightDays;
  FlightDay? _selectedDate;

  FlightDay? get selectedDate => _selectedDate;

  set selectedDate(FlightDay? value) {
    if (value != null && !flightDays.contains(value)) {
      throw ArgumentError('Selected date must be in flightDays');
    }
    if (value == _selectedDate) return;
    _selectedDate = value;
    notifyListeners();
  }

  FlightDates(this.flightDays) {
    flightDays.sort((a, b) => a.compareTo(b));
  }
}

class FlightCalendarWidget extends StatefulWidget {
  final FlightDates flightDates;
  //final Function(FlightDay) onDaySelected;

  const FlightCalendarWidget({
    super.key,
    required this.flightDates,
    //required this.onDaySelected,
  });

  @override
  State<FlightCalendarWidget> createState() => _FlightCalendarWidgetState();
}

class _FlightCalendarWidgetState extends State<FlightCalendarWidget> {
  @override
  void initState() {
    super.initState();
    widget.flightDates.addListener(_onFlightDatesChanged);
  }

  @override
  void dispose() {
    widget.flightDates.removeListener(_onFlightDatesChanged);
    super.dispose();
  }

  void _onFlightDatesChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Grouper les jours par année
    Map<int, List<FlightDay>> daysByYear = {};
    for (var day in widget.flightDates.flightDays) {
      if (!daysByYear.containsKey(day.year)) {
        daysByYear[day.year] = [];
      }
      daysByYear[day.year]!.add(day);
    }

    return Column(
      children: daysByYear.entries
          .map(
            (entry) => _flightYearWidget(
              year: entry.key,
              days: entry.value,
              // onDaySelected: widget.onDaySelected,
              onDaySelected: (value) {
                widget.flightDates.selectedDate = value;
              },
              selectedDate: widget.flightDates.selectedDate,
            ),
          )
          .toList(),
    );
  }

  Widget _flightDayWidget({
    required FlightDay flightDay,
    required Function(FlightDay) onDaySelected,
    bool isSelected = false,
  }) {
    DateTime date = DateTime(flightDay.year, flightDay.month, flightDay.day);
    bool isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    String dayAbbrev = DateFormat.EEEE(
      'fr_FR',
    ).format(date).substring(0, 3).toUpperCase();
    return InkWell(
      hoverColor: Colors.yellow,
      onTap: () {
        onDaySelected(flightDay);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Date sélectionnée : ${flightDay.year}-${flightDay.month}-${flightDay.day}',
            ),
          ),
        );
      },
      child: Tooltip(
        message: flightDay.nbFlights != null
            ? '${flightDay.nbFlights} vols'
            : '',
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Text(
                '${flightDay.day}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey.shade700,
                ),
              ),
            ),
            Positioned(
              top: 25,
              left: 11,
              child: Text(
                dayAbbrev,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: isSelected
                  ? Colors.red
                  : isWeekend
                  ? Colors.blueGrey.shade600
                  : Colors.grey,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _flightYearWidget({
    required int year,
    required List<FlightDay> days,
    required Function(FlightDay) onDaySelected,
    FlightDay? selectedDate,
  }) {
    // Grouper les jours par mois
    Map<int, List<FlightDay>> daysByMonth = {};
    for (var day in days) {
      if (!daysByMonth.containsKey(day.month)) {
        daysByMonth[day.month] = [];
      }
      daysByMonth[day.month]!.add(day);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          //color: Colors.grey[300],
          child: Row(
            children: [
              Text(
                '$year',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 4),
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.white],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Text(
                    "6 vols",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...daysByMonth.entries.map(
          (entry) => _flightMonthWidget(
            month: entry.key,
            days: entry.value,
            onDaySelected: onDaySelected,
            selectedDate: selectedDate,
          ),
        ),
      ],
    );
  }

  Widget _flightMonthWidget({
    required int month,
    required List<FlightDay> days,
    required Function(FlightDay) onDaySelected,
    FlightDay? selectedDate,
  }) {
    String getMonthName(int month) {
      String name = DateFormat.MMMM('fr_FR').format(DateTime(2024, month, 1));
      return name[0].toUpperCase() + name.substring(1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                child: Divider(color: Colors.blue, thickness: 1, endIndent: 2),
              ),
              Text(
                getMonthName(month),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(
                width: 20,
                child: Divider(color: Colors.blue, thickness: 1, indent: 2),
              ),
            ],
          ),
        ),
        Wrap(
          children: days
              .map(
                (day) => _flightDayWidget(
                  flightDay: day,
                  onDaySelected: onDaySelected,
                  isSelected:
                      selectedDate != null &&
                      day.year == selectedDate.year &&
                      day.month == selectedDate.month &&
                      day.day == selectedDate.day,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

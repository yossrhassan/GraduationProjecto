import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({super.key});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  // Don't initialize with DateTime.now() - instead use the date from the Cubit state
  DateTime? _selectedValue;

  @override
  void initState() {
    super.initState();
    // Get the current date from the Cubit state, if available
    final state = context.read<BookingCubit>().state;
    if (state is BookingSelection) {
      _selectedValue = state.date;
    } else {
      _selectedValue = DateTime.now(); // Fallback to today
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        // Update _selectedValue when the state changes
        if (state is BookingSelection) {
          setState(() {
            _selectedValue = state.date;
          });
        }
      },
      builder: (context, state) {
        // Use date from state if available, otherwise keep current selection
        DateTime currentDate = _selectedValue ?? DateTime.now();
        if (state is BookingSelection) {
          currentDate = state.date;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select a date:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: DatePicker(
                  DateTime.now(),
                  daysCount: 7,
                  initialSelectedDate: currentDate,  // Always use the current selection
                  selectionColor: kPrimaryColor,
                  selectedTextColor: Colors.white,
                  dayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  monthTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  dateTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  onDateChange: (date) {
                    setState(() {
                      _selectedValue = date;
                    });
                    context.read<BookingCubit>().selectDate(date);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
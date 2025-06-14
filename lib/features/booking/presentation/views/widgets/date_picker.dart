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
  DateTime? _selectedValue;

  @override
  void initState() {
    super.initState();
    final state = context.read<BookingCubit>().state;
    if (state is BookingSelection) {
      _selectedValue = state.date;
    } else {
      _selectedValue = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingSelection) {
          setState(() {
            _selectedValue = state.date;
          });
        }
      },
      builder: (context, state) {
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
                  initialSelectedDate: currentDate,
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

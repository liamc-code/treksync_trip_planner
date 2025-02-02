/* trip_detail_screen.dart
* TrekSync - Trip Planner
* Description - This file displays the details and fields of the selected trip 
*               entry either created or retrieved from the db.
*
*/

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'dbhelper.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic>? trip;
  final bool isEditing;

  const DetailScreen({super.key, this.trip, this.isEditing = false});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late FormGroup form;

  @override
  void initState() {
    super.initState();

    // Form fields to modify/create/view data of trip entry
    form = FormGroup({
      'customerType': FormControl<String>(
        value: widget.trip?['customerType'] ?? 'Individual',
        validators: [Validators.required],
      ),
      'destination': FormControl<String>(
        value: widget.trip?['destination'],
        validators: [Validators.required],
      ),
      'contactPhone': FormControl<String>(
        value: widget.trip?['contactPhone'],
        // validate phone number (numbers/dashes only)
        validators: [Validators.required, Validators.pattern(r'^[0-9-]+$')],
      ),
      'emailAddress': FormControl<String>(
        value: widget.trip?['emailAddress'],
        // validate email to be in proper email format
        validators: [Validators.required, Validators.email],
      ),
      'tripPrice': FormControl<String>(
        value: widget.trip?['tripPrice']?.toString(),
        // validate price is only numbers and decimal
        validators: [Validators.required, Validators.pattern(r'^\d+(\.\d+)?$')],
      ),
      // optional field 1
      'additionalInfo1': FormControl<String>(
        value: widget.trip?['additionalInfo1'] ?? '',
      ),
      // optional field 2
      'additionalInfo2': FormControl<String>(
        value: widget.trip?['additionalInfo2'] ?? '',
      ),
    });
  }

  Future<void> _saveTrip() async {
    if (form.valid) {
      // add all entered fields to Map
      final tripData = {
        'customerType': form.control('customerType').value,
        'destination': form.control('destination').value,
        'contactPhone': form.control('contactPhone').value,
        'emailAddress': form.control('emailAddress').value,
        'tripPrice': double.parse(form.control('tripPrice').value),
        'additionalInfo1': form.control('additionalInfo1').value,
        'additionalInfo2': form.control('additionalInfo2').value,
      };

      // modify DB trip entry or create if it doesn't exist using the above Map to pass data
      if (widget.isEditing) {
        await DatabaseHelper.instance.updateTrip(widget.trip!['id'], tripData);
      } else {
        await DatabaseHelper.instance.createTrip(tripData);
      }
      // check if widget is still mounted so no further operations are attempted
      if (!mounted) return;

      // Navigate back to TripListScreen
      Navigator.of(context).pop();
    } else {
      // mark fields as touched to display validation errors
      form.markAllAsTouched();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Trip' : 'Add Trip'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8, // Allow space for keyboard
                  child: ReactiveForm(
                    formGroup: form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReactiveDropdownField<String>(
                          formControlName: 'customerType',
                          items: const [
                            DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                            DropdownMenuItem(value: 'Family', child: Text('Family')),
                            DropdownMenuItem(value: 'Group', child: Text('Group')),
                          ],
                          decoration: const InputDecoration(labelText: 'Customer Type'),
                        ),
                        ReactiveTextField(
                          formControlName: 'destination',
                          decoration: const InputDecoration(labelText: 'Destination'),
                          validationMessages: {
                            'required': (_) => 'Enter a destination',
                          },
                        ),
                        ReactiveTextField(
                          formControlName: 'contactPhone',
                          decoration: const InputDecoration(labelText: 'Contact Phone'),
                          keyboardType: TextInputType.phone,
                          validationMessages: {
                            'required': (_) => 'Enter a phone number',
                            'pattern': (_) => 'Phone number can only contain numbers and dashes',
                          },
                        ),
                        ReactiveTextField(
                          formControlName: 'emailAddress',
                          decoration: const InputDecoration(labelText: 'Email Address'),
                          validationMessages: {
                            'required': (_) => 'Enter an email address',
                            'email': (_) => 'Enter a valid email',
                          },
                        ),
                        ReactiveTextField(
                          formControlName: 'tripPrice',
                          decoration: const InputDecoration(labelText: 'Trip Price'),
                          keyboardType: TextInputType.number,
                          validationMessages: {
                            'required': (_) => 'Enter a trip price',
                            'pattern': (_) => 'Enter a valid number',
                          },
                        ),
                        ReactiveValueListenableBuilder<String>(
                          formControlName: 'customerType',
                          builder: (context, control, child) {
                            final customerType = control.value;
                            // customerType specific fields (all optional)
                            if (customerType == 'Individual') {
                              return ReactiveTextField(
                                formControlName: 'additionalInfo1',
                                decoration: const InputDecoration(labelText: 'Home Address'),
                              );
                            } else if (customerType == 'Family') {
                              return Column(
                                children: [
                                  ReactiveTextField(
                                    formControlName: 'additionalInfo1',
                                    decoration: const InputDecoration(labelText: 'Family Member in Canada'),
                                  ),
                                  ReactiveTextField(
                                    formControlName: 'additionalInfo2',
                                    decoration: const InputDecoration(labelText: 'Family Insurance Company'),
                                  ),
                                ],
                              );
                            } else if (customerType == 'Group') {
                              return Column(
                                children: [
                                  ReactiveTextField(
                                    formControlName: 'additionalInfo1',
                                    decoration: const InputDecoration(labelText: 'Destination Company'),
                                  ),
                                  ReactiveTextField(
                                    formControlName: 'additionalInfo2',
                                    decoration: const InputDecoration(labelText: 'Policy Number'),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _saveTrip, // Save functionality
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 88, 13, 208),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save Trip'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Cancel and return to previous screen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 126, 46, 255),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

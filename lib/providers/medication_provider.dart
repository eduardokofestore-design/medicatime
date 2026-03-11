import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/medication.dart';

class MedicationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Stream<List<Medication>> getMedications() {
    final user = _auth.currentUser;

    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Medication.fromMap(doc.id, doc.data()))
              .toList());
    }

    return Stream.empty();
  }

  Future<void> addMedication(Medication medication) async {
    final user = _auth.currentUser;

    if (user != null) {
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .add(medication.toMap());

      medication.id = docRef.id;

      await scheduleNotifications(medication);

      notifyListeners();
    }
  }

  Future<void> updateMedication(Medication medication) async {
    final user = _auth.currentUser;

    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .doc(medication.id)
          .update(medication.toMap());

      await cancelNotifications(medication.id);
      await scheduleNotifications(medication);

      notifyListeners();
    }
  }

  Future<void> deleteMedication(String id) async {
    final user = _auth.currentUser;

    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .doc(id)
          .delete();

      await cancelNotifications(id);

      notifyListeners();
    }
  }

  Future<void> markAsTaken(String medicationId, String time) async {
    final user = _auth.currentUser;

    if (user != null) {
      final history = MedicationHistory(
        id: '',
        medicationId: medicationId,
        date: DateTime.now(),
        time: time,
        status: 'taken',
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add(history.toMap());
    }
  }

  Future<void> markAsSkipped(String medicationId, String time) async {
    final user = _auth.currentUser;

    if (user != null) {
      final history = MedicationHistory(
        id: '',
        medicationId: medicationId,
        date: DateTime.now(),
        time: time,
        status: 'skipped',
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add(history.toMap());
    }
  }

  Stream<List<MedicationHistory>> getHistory() {
    final user = _auth.currentUser;

    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MedicationHistory.fromMap(doc.id, doc.data()))
              .toList());
    }

    return Stream.empty();
  }

  Future<void> scheduleNotifications(Medication medication) async {
    for (String time in medication.times) {
      final timeParts = time.split(':');

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (medication.isDaily) {
        await _notificationsPlugin.zonedSchedule(
          id: medication.id.hashCode + time.hashCode,
          title: 'Hora da Medicação',
          body: 'É hora de tomar ${medication.name} - ${medication.dosage}',
          scheduledDate: _nextInstanceOfTime(hour, minute),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_channel',
              'Medicações',
              channelDescription: 'Notificações de medicações',
              importance: Importance.max,
              priority: Priority.high,
              actions: [
                AndroidNotificationAction('taken', 'Tomado'),
                AndroidNotificationAction('skip', 'Ignorar'),
              ],
            ),
          ),
          payload: '${medication.id}|$time',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        for (int day in medication.days ?? []) {
          await _notificationsPlugin.zonedSchedule(
            id: medication.id.hashCode + time.hashCode + day,
            title: 'Hora da Medicação',
            body: 'É hora de tomar ${medication.name} - ${medication.dosage}',
            scheduledDate: _nextInstanceOfTimeOnDay(hour, minute, day),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'medication_channel',
                'Medicações',
                channelDescription: 'Notificações de medicações',
                importance: Importance.max,
                priority: Priority.high,
                actions: [
                  AndroidNotificationAction('taken', 'Tomado'),
                  AndroidNotificationAction('skip', 'Ignorar'),
                ],
              ),
            ),
            payload: '${medication.id}|$time',
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents:
                DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    }
  }

  Future<void> cancelNotifications(String medicationId) async {
    await _notificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTimeOnDay(
      int hour, int minute, int weekday) {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
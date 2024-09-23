import 'package:intl/intl.dart';

import 'package:linkeat/utils/datetime_util.dart';
import 'package:linkeat/models/store.dart';

final timeOffset = 1;

List<DeliveryScheduleOption>? getDeliveryTimeOptions(
    String? postCode, DeliveryRange deliveryRange) {
  if (deliveryRange.schedules!.length == 0) return null;
  var now = DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  var todayString = formatter.format(now);

  // batch delivery schedule
  if (deliveryRange.mode == 'Batch') {
    return null;
//    List<DeliverySchedule> deliverySchedules =
//        filterAvaiableTimeSlicefromDeliveryScheduleForBatch(
//            deliveryRange.schedules);
//    if (deliverySchedules.length == 0) return null;
//    return deliverySchedules
//        .map((schedue) => DeliveryScheduleOption(
//              showing: schedue.start + ' - ' + schedue.end,
//              deliverySchedule: schedue,
//              expectArriveTime:
//                  DateTime.parse('${todayString} ${schedue.end}:00')
//                      .millisecondsSinceEpoch,
//            ))
//        .toList();
  }

  // instant delivery schedule
  if (deliveryRange.mode == 'Instant') {
    // get today schedules
    var now = DateTime.now();
    var weekOfDay = now.weekday;
    List<DeliveryScheduleDay> todaySchedule = deliveryRange.schedules!
        .where((item) => item.dayOfTheWeek == weekOfDay)
        .toList();
    if (todaySchedule.length == 0) return null;

    // convert schedule to int format
    List<DeliveryScheduleInt> deliverySchedulesInt = todaySchedule[0]
        .deliverySchedules!
        .map((schedule) => DeliveryScheduleInt(
              start: DateTimeUtil.convertHHmmTimeToBusinessHour(schedule.start),
              end: DateTimeUtil.convertHHmmTimeToBusinessHour(schedule.end),
            ))
        .toList();

    List<DeliveryScheduleInt> filteredDeliverySchedulesInt =
        filterAvaiableTimeSlicefromDeliveryScheduleForInstant(
            deliverySchedulesInt);
    // split time slice for schedule
    List<DeliveryScheduleOption> deliveryScheduleOptions = [];
    filteredDeliverySchedulesInt.forEach((schedule) {
      for (var i = 0; i < schedule.end! - schedule.start!; i++) {
        deliveryScheduleOptions.add(DeliveryScheduleOption(
          showing:
              '${DateTimeUtil.convertBusinessHourToTimeString(schedule.start! + i)} - ${DateTimeUtil.convertBusinessHourToTimeString(schedule.start! + i + 1)}',
          deliverySchedule: null,
          expectArriveTime: DateTime.parse(
                  '${todayString} ${DateTimeUtil.convertBusinessHourToTimeString(schedule.start! + i + 1)}:00')
              .millisecondsSinceEpoch,
        ));
      }
    });

    return deliveryScheduleOptions.length > 0 ? deliveryScheduleOptions : null;
  }
  return null;
}

List<DeliverySchedule> filterAvaiableTimeSlicefromDeliveryScheduleForBatch(
    List<DeliveryScheduleDay> schedules) {
  List<DeliverySchedule> filteredSchedules = [];
  var now = DateTime.now();
  var weekOfDay = now.weekday;
  var formatter = new DateFormat('yyyy-MM-dd');
  List<DeliveryScheduleDay> todaySchedule =
      schedules.where((item) => item.dayOfTheWeek == weekOfDay).toList();
  if (todaySchedule.length == 0) return [];

  todaySchedule[0].deliverySchedules!.forEach((schedule) {
    DateTime endTime =
        DateTime.parse('${formatter.format(now)} ${schedule.end}:00');
    if (now.isBefore(endTime)) {
      filteredSchedules.add(schedule);
    }
  });
  return filteredSchedules;
}

List<DeliveryScheduleInt> filterAvaiableTimeSlicefromDeliveryScheduleForInstant(
    List<DeliveryScheduleInt> schedules) {
  List<DeliveryScheduleInt> filteredSchedules = [];
  var now = DateTime.now();
  var checkHour = now.hour * 2 + timeOffset;
  if (now.minute >= 30) checkHour = checkHour + 1;
  schedules.forEach((schedule) {
    int? start, end;
    start = schedule.start;
    end = schedule.end;
    if (checkHour > start!) start = checkHour;
    if (end! > start) {
      filteredSchedules.add(DeliveryScheduleInt(start: start, end: end));
    }
  });
  return filteredSchedules;
}

List<TakeawayTimeOption>? getTakeAwayTimeOptions(
    List<BusinessHourDay> businessHour) {
  var now = DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  var todayString = formatter.format(now);
  var weekOfDay = now.weekday;
  var businessHourDays =
      businessHour.where((item) => item.dayOfTheWeek == weekOfDay).toList();
  if (businessHourDays.length == 0) return null;

  // split time slice
  List<OpeningHour> filteredOpenHours =
      filterAvaiableTimeSlicefromBusinessHourDay(
          businessHourDays[0].openingHours!);
  List<TakeawayTimeOption> takeawayTimeOptions = [];
  filteredOpenHours.forEach((businessHour) {
    for (var i = 0; i < businessHour.close! - businessHour.open!; i++) {
      takeawayTimeOptions.add(TakeawayTimeOption(
        showing:
            '${DateTimeUtil.convertBusinessHourToTimeString(businessHour.open! + i)} - ${DateTimeUtil.convertBusinessHourToTimeString(businessHour.open! + i + 1)}',
        pickUpTime: DateTime.parse(
                '${todayString} ${DateTimeUtil.convertBusinessHourToTimeString(businessHour.open! + i + 1)}:00')
            .millisecondsSinceEpoch,
      ));
    }
  });

  return takeawayTimeOptions.length > 0 ? takeawayTimeOptions : null;
}

List<OpeningHour> filterAvaiableTimeSlicefromBusinessHourDay(
    List<OpeningHour> openingHours) {
  List<OpeningHour> filteredOpeningHours = [];
  var now = DateTime.now();
  var checkHour = now.hour * 2 + timeOffset;
  if (now.minute >= 30) checkHour = checkHour + 1;
  openingHours.forEach((openingHour) {
    int? open, close;
    open = openingHour.open;
    close = openingHour.close;
    if (checkHour > open!) open = checkHour;
    if (close! > open) {
      filteredOpeningHours.add(OpeningHour(open: open, close: close));
    }
  });
  return filteredOpeningHours;
}

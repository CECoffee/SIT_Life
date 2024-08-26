import 'package:hive/hive.dart';
import 'package:mimir/utils/hive.dart';
import 'package:mimir/storage/hive/init.dart';

import '../entity/details.dart';
import '../entity/activity.dart';

class _K {
  static String activity(int id) => '/activities/$id';

  static String activityDetails(int id) => '/activityDetails/$id';

  static String activityIdList(Class2ndActivityCat type) => '/activityIdList/$type';
}

class Class2ndActivityStorage {
  Box get box => HiveInit.class2nd;

  const Class2ndActivityStorage();

  List<int>? getActivityIdList(Class2ndActivityCat type) => box.safeGet<List<int>>(_K.activityIdList(type));

  Future<void> setActivityIdList(Class2ndActivityCat type, List<int>? activityIdList) =>
      box.safePut<List<int>>(_K.activityIdList(type), activityIdList);

  Class2ndActivity? getActivity(int id) => box.safeGet<Class2ndActivity>(_K.activity(id));

  Future<void> setActivity(int id, Class2ndActivity? activity) =>
      box.safePut<Class2ndActivity>(_K.activity(id), activity);

  Class2ndActivityDetails? getActivityDetails(int id) => box.safeGet<Class2ndActivityDetails>(_K.activityDetails(id));

  Future<void> setActivityDetails(int id, Class2ndActivityDetails? details) =>
      box.safePut<Class2ndActivityDetails>(_K.activityDetails(id), details);

  List<Class2ndActivity>? getActivities(Class2ndActivityCat type) {
    final idList = getActivityIdList(type);
    if (idList == null) return null;
    final res = <Class2ndActivity>[];
    for (final id in idList) {
      final activity = getActivity(id);
      if (activity != null) {
        res.add(activity);
      }
    }
    return res;
  }

  Future<void>? setActivities(Class2ndActivityCat type, List<Class2ndActivity>? activities) async {
    if (activities == null) {
      await setActivities(type, null);
    } else {
      await setActivityIdList(type, activities.map((e) => e.id).toList(growable: false));
      for (final activity in activities) {
        await setActivity(activity.id, activity);
      }
    }
  }
}

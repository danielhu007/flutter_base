import 'package:flutter/material.dart';
import 'plus_android.dart';
import 'plus_audio.dart';
import 'plus_bridge_base.dart';
import 'plus_camera.dart';
import 'plus_device.dart';
import 'plus_downloader.dart';
import 'plus_events.dart';
import 'plus_gallery.dart';
import 'plus_geolocation.dart';
import 'plus_io.dart';
import 'plus_nativeObj.dart';
import 'plus_nativeUI.dart';
import 'plus_networkinfo.dart';
import 'plus_navigator.dart';
import 'plus_os.dart';
import 'plus_runtime.dart';
import 'plus_share.dart';
import 'plus_sqlite.dart';
import 'plus_uploader.dart';
import 'plus_zip.dart';

final PlusEventsModule plusEventsModule = PlusEventsModule();
final PlusDownloaderModule plusDownloaderModule = PlusDownloaderModule();
final PlusSqliteModule plusSqliteModule = PlusSqliteModule();
final PlusAudioModule plusAudioModule = PlusAudioModule();
final PlusAndroidModule plusAndroidModule = PlusAndroidModule();
final PlusCameraModule plusCameraModule = PlusCameraModule();
final PlusGeolocationModule plusGeolocationModule = PlusGeolocationModule();
final PlusGalleryModule plusGalleryModule = PlusGalleryModule();
final PlusNativeObjModule plusNativeObjModule = PlusNativeObjModule();
final PlusNativeUIModule plusNativeUIModule = PlusNativeUIModule();
final PlusNavigatorModule plusNavigatorModule = PlusNavigatorModule();
final PlusNetworkInfoModule plusNetworkInfoModule = PlusNetworkInfoModule();
final PlusOSModule plusOSModule = PlusOSModule();
final PlusIOModule plusIOModule = PlusIOModule();
final PlusShareModule plusShareModule = PlusShareModule();
final PlusUploaderModule plusUploaderModule = PlusUploaderModule();
final PlusZipModule plusZipModule = PlusZipModule();

final List<PlusBridgeModule> plusModules = [
  PlusRuntimeModule(),
  PlusDeviceModule(),
  plusEventsModule,
  plusDownloaderModule,
  plusSqliteModule,
  plusAudioModule,
  plusAndroidModule,
  plusCameraModule,
  plusGeolocationModule,
  plusGalleryModule,
  plusNativeObjModule,
  plusNativeUIModule,
  plusNavigatorModule,
  plusNetworkInfoModule,
  plusOSModule,
  plusIOModule,
  plusShareModule,
  plusUploaderModule,
  plusZipModule,
];

Future<dynamic>? handlePlusMethod(
    String namespace, String method, dynamic params, BuildContext context) {
  final module = plusModules.firstWhere(
    (m) => m.jsNamespace == namespace,
    orElse: () => null as PlusBridgeModule,
  );
  return module?.handle(method, params, context);
}

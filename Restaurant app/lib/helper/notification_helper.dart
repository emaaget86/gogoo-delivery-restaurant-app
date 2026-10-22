import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:stackfood_multivendor_restaurant/features/advertisement/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/chat/controllers/chat_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/dashboard/screens/dashboard_screen.dart';
import 'package:stackfood_multivendor_restaurant/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/chat/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor_restaurant/features/dashboard/widgets/new_request_dialog_widget.dart';
import 'package:stackfood_multivendor_restaurant/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor_restaurant/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_restaurant/helper/bogo_offer_action_helper.dart';
import 'package:stackfood_multivendor_restaurant/helper/custom_print_helper.dart';
import 'package:stackfood_multivendor_restaurant/helper/route_helper.dart';
import 'package:stackfood_multivendor_restaurant/helper/user_type.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stackfood_multivendor_restaurant/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

const String _orderChannelId = 'stackfood';
const String _orderChannelName = 'stackfood';
const String _orderChannelSound = 'notification';
const String _foregroundServiceChannelId = 'stackfood_foreground_service';
const int _foregroundServiceNotificationId = 256;

class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    await flutterLocalNotificationsPlugin.initialize(settings: initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse load) async{
      try{
        if(load.payload!.isNotEmpty){
          NotificationBodyModel payload = NotificationBodyModel.fromJson(jsonDecode(load.payload!));

          if(!Get.find<AuthController>().isLoggedIn()){
            return;
          }

          if(payload.notificationType == NotificationType.order){
            Get.toNamed(RouteHelper.getOrderDetailsRoute(payload.orderId, fromNotification: true));
          }else if(payload.notificationType == NotificationType.advertisement){
            Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: payload.advertisementId, fromNotification: true));
          }else if(payload.notificationType == NotificationType.message){
            customPrint('message enter');
            Get.toNamed(RouteHelper.getChatRoute(
              notificationBody: payload,
              conversationId: payload.conversationId,
              fromNotification: true,
            ));
          }else if(payload.notificationType == NotificationType.block || payload.notificationType == NotificationType.unblock){
            Get.toNamed(RouteHelper.getSignInRoute());
          }else if(payload.notificationType == NotificationType.withdraw){
            Get.to(const DashboardScreen(pageIndex: 3));
          }else if(payload.notificationType == NotificationType.campaign){
            Get.toNamed(RouteHelper.getCampaignDetailsRoute(id: payload.campaignId, fromNotification: true));
          }else if(payload.notificationType == NotificationType.bogoOffer){
            Get.toNamed(payload.bogoOfferId != null
                ? RouteHelper.getBogoOfferDetailsRoute(id: payload.bogoOfferId!, fromNotification: true)
                : RouteHelper.getBogoOfferRoute(fromNotification: true));
          }else if(payload.notificationType == NotificationType.happyHour && payload.happyHourId != null){
            Get.toNamed(RouteHelper.getHappyHourDetailsRoute(id: payload.happyHourId!, fromNotification: true));
          }else if (Get.find<AuthController>().isLoggedIn()) {
            Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
          }
        }
      }catch(_){}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("onMessage: ${message.data}");
      customPrint("onMessage: ${message.data}");
      customPrint("onMessage message type:${message.data['type']}");

      if(message.data['type'] == 'maintenance'){
        Get.find<SplashController>().getConfigData();
      }

      if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.chatScreen)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1, type: Get.find<ChatController>().type);
          if(Get.find<ChatController>().messageModel!.conversation!.id.toString() == message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1, NotificationBodyModel(
              notificationType: NotificationType.message,
              adminId: message.data['sender_type'] == UserType.admin.name ? 0 : null,
              customerId: message.data['sender_type'] == UserType.user.name ? 0 : null,
              deliveryManId: message.data['sender_type'] == UserType.delivery_man.name ? 0 : null,
            ),
              null, int.parse(message.data['conversation_id'].toString()),
            );
          }else {
            NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
          }
        }
      }else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversationListScreen)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1, type: Get.find<ChatController>().type);
        }
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
      }else if(message.data['type'] == 'maintenance'){
      } else {
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);

        if(Get.currentRoute.startsWith(RouteHelper.notification) && Get.find<AuthController>().isLoggedIn()) {
          Get.find<NotificationController>().getNotificationList();
        }

        if (message.data['type'] == 'new_order' || message.data['title'] == 'New order placed') {
          Get.find<OrderController>().getPaginatedOrders(1, true, isSubscription: 0);
          Get.find<OrderController>().getCurrentOrders();

          Get.dialog(const NewRequestDialogWidget());
        } else if(message.data['type'] == 'advertisement') {
          Get.find<AdvertisementController>().getAdvertisementList('1', 'all');
        } else if(message.data['type'] == 'bogo_offer') {
          _refreshBogoOffer(message.data['data_id']);
        } else if(message.data['type'] == 'happy_hour') {
          _refreshHappyHour(message.data['data_id']);
        }
      }

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      customPrint("onOpenApp: ${message.data}");
      customPrint("onOpenApp message type:${message.data['type']}");
      try{
        NotificationBodyModel notificationBody = convertNotification(message.data);

        if(!Get.find<AuthController>().isLoggedIn()){
          return;
        }

        if(notificationBody.notificationType == NotificationType.order){
          Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id']), fromNotification: true));
        }else if(notificationBody.notificationType == NotificationType.message){
          Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationId: notificationBody.conversationId, fromNotification: true));
        }else if(notificationBody.notificationType == NotificationType.block || notificationBody.notificationType == NotificationType.unblock) {
          Get.toNamed(RouteHelper.getSignInRoute());
        }else if(notificationBody.notificationType == NotificationType.withdraw){
          Get.to(const DashboardScreen(pageIndex: 3));
        }else if(notificationBody.notificationType == NotificationType.advertisement){
          Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody.advertisementId, fromNotification: true));
        }else if(notificationBody.notificationType == NotificationType.campaign){
          Get.toNamed(RouteHelper.getCampaignDetailsRoute(id: notificationBody.campaignId, fromNotification: true));
        }else if(notificationBody.notificationType == NotificationType.bogoOffer){
          Get.toNamed(notificationBody.bogoOfferId != null
              ? RouteHelper.getBogoOfferDetailsRoute(id: notificationBody.bogoOfferId!, fromNotification: true)
              : RouteHelper.getBogoOfferRoute(fromNotification: true));
        }else if(notificationBody.notificationType == NotificationType.happyHour && notificationBody.happyHourId != null){
          Get.toNamed(RouteHelper.getHappyHourDetailsRoute(id: notificationBody.happyHourId!, fromNotification: true));
        }else if (Get.find<AuthController>().isLoggedIn()) {
          Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
        }
      }catch (_) {}
    });

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if(androidPlugin != null) {
      try {
        final bool? permissionGranted = await androidPlugin.requestNotificationsPermission();
        if(permissionGranted == false) {
          customPrint('Notification permission is not granted');
        }
        await _ensureOrderAlertChannel(androidPlugin);
      } catch (e) {
        customPrint('Notification channel setup error: $e');
      }
    }
  }

  static Future<NotificationBodyModel?> notificationLaunchBody(FlutterLocalNotificationsPlugin plugin) async {
    try {
      final NotificationAppLaunchDetails? details = await plugin.getNotificationAppLaunchDetails();
      final String? payload = details?.notificationResponse?.payload;
      if(details?.didNotificationLaunchApp != true || payload == null || payload.isEmpty) {
        return null;
      }
      return NotificationBodyModel.fromJson(jsonDecode(payload));
    } catch (e) {
      customPrint('Notification launch payload error: $e');
      return null;
    }
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    if(!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? image;
      NotificationBodyModel notificationBody;

      title = message.data['title'];
      body = message.data['body'] ?? '';
      notificationBody = convertNotification(message.data);

      image = (message.data['image'] != null && message.data['image'].isNotEmpty)
          ? message.data['image'].startsWith('http') ? message.data['image']
          : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;

      if(image != null && image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(title, body, notificationBody, image, fln);
        }catch(e) {
          await showBigTextNotification(title, body!, notificationBody, fln);
        }
      }else {
        await showBigTextNotification(title, body!, notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =const AndroidNotificationDetails(
      _orderChannelId, _orderChannelName,
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
     NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: 0, title: title,body:  body,notificationDetails:  platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigTextNotification(String? title, String body, NotificationBodyModel? notificationBody, FlutterLocalNotificationsPlugin fln, {int id = 0, bool onlyAlertOnce = false}) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _orderChannelId, _orderChannelName, importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      onlyAlertOnce: onlyAlertOnce,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: id, title: title,body:  body, notificationDetails:  platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, NotificationBodyModel? notificationBody, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _orderChannelId, _orderChannelName,
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: 0,title:  title,body:  body,notificationDetails:  platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static void _refreshBogoOffer(dynamic dataId) {
    if(!Get.find<AuthController>().isLoggedIn()) {
      return;
    }

    final BogoOfferController bogoOfferController = Get.find<BogoOfferController>();

    if(Get.currentRoute.startsWith(RouteHelper.bogoOffer)) {
      bogoOfferController.getBogoOfferList(offset: '1');
    }

    final int? id = int.tryParse(dataId?.toString() ?? '');
    if(id == null) {
      return;
    }

    /// Keeps an open offer-details screen in step with the admin's decision, so
    /// its status pill and action buttons change without the vendor reopening it.
    bogoOfferController.syncBogoOffer(id);

    /// An admin invitation is raised in front of the restaurant wherever it is in the
    /// app; the helper reads the offer back first and stays quiet for anything else.
    BogoOfferActionHelper.showAdminRequestForOffer(id);
  }

  static void _refreshHappyHour(dynamic dataId) {
    if(!Get.find<AuthController>().isLoggedIn() || !Get.currentRoute.startsWith(RouteHelper.happyHour)) {
      return;
    }

    final int? id = int.tryParse(dataId?.toString() ?? '');
    if(id == null) {
      return;
    }

    Get.find<HappyHourController>().syncHappyHour(id);
  }

  static NotificationBodyModel convertNotification(Map<String, dynamic> data){
    if(data['type'] == 'advertisement'){
      return NotificationBodyModel(notificationType: NotificationType.advertisement, advertisementId: int.parse(data['advertisement_id']));
    } else if(data['type'] == 'new_order' || data['type'] == 'New order placed' || data['type'] == 'order_status'){
      return NotificationBodyModel(orderId: int.parse(data['order_id']), notificationType: NotificationType.order);
    } else if(data['type'] == 'message'){
      return NotificationBodyModel(
        orderId: (data['order_id'] != null && data['order_id'].isNotEmpty) ? int.parse(data['order_id']) : null,
        conversationId: (data['conversation_id'] != null && data['conversation_id'].isNotEmpty) ? int.parse(data['conversation_id']) : null,
        notificationType: NotificationType.message,
        type: data['sender_type'] == UserType.delivery_man.name ? UserType.delivery_man.name : UserType.customer.name,
      );
    }else if(data['type'] == 'block'){
      return NotificationBodyModel(notificationType: NotificationType.block);
    }else if(data['type'] == 'unblock'){
      return NotificationBodyModel(notificationType: NotificationType.unblock);
    }else if(data['type'] == 'withdraw'){
      return NotificationBodyModel(notificationType: NotificationType.withdraw);
    }else if(data['type'] == 'campaign'){
      return NotificationBodyModel(notificationType: NotificationType.campaign, campaignId: int.parse(data['data_id']));
    }else if(data['type'] == 'bogo_offer'){
      return NotificationBodyModel(notificationType: NotificationType.bogoOffer, bogoOfferId: int.tryParse(data['data_id'].toString()));
    }else if(data['type'] == 'happy_hour'){
      return NotificationBodyModel(notificationType: NotificationType.happyHour, happyHourId: int.parse(data['data_id'].toString()));
    }else{
      return NotificationBodyModel(notificationType: NotificationType.general) ;
    }
  }
}

final AudioPlayer _audioPlayer = AudioPlayer();

/// Background FCM message handler
@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  customPrint("onBackground: ${message.data}");

  final NotificationBodyModel notificationBody = NotificationHelper.convertNotification(message.data);
  if(notificationBody.notificationType != NotificationType.order) {
    return;
  }

  try {
    await _showBackgroundOrderNotification(message, notificationBody);
  } catch (e) {
    customPrint('Background order notification error: $e');
  }

  try {
    FlutterForegroundTask.initCommunicationPort();
    await _initService();
    await _startService(notificationBody.orderId.toString());
  } catch (e) {
    customPrint('Background order sound service error: $e');
  }
}

/// Posts one local order notification on the stackfood channel.
///
/// If Android already displayed a notification payload on a high-importance
/// channel, this only repairs the channel and does not post a second one.
@pragma('vm:entry-point')
Future<void> _showBackgroundOrderNotification(RemoteMessage message, NotificationBodyModel notificationBody) async {
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('notification_icon');
  await plugin.initialize(settings: const InitializationSettings(android: androidSettings));

  final AndroidFlutterLocalNotificationsPlugin? android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if(android == null) {
    return;
  }

  final bool channelWasReady = await _ensureOrderAlertChannel(android);
  if(message.notification != null && channelWasReady) {
    return;
  }

  final bool? notificationsEnabled = await android.areNotificationsEnabled();
  if(notificationsEnabled == false) {
    customPrint('Notification permission is not granted');
    return;
  }

  final String title = _orderNotificationTitle(message, notificationBody);
  final String body = _orderNotificationBody(message);
  final int notificationId = _orderNotificationId(notificationBody.orderId);
  if(await _sameOrderNotificationVisible(android, notificationId, title, body)) {
    customPrint('Order notification $notificationId is already posted');
    return;
  }

  await NotificationHelper.showBigTextNotification(title, body, notificationBody, plugin, id: notificationId);
}

Future<bool> _ensureOrderAlertChannel(AndroidFlutterLocalNotificationsPlugin android) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    _orderChannelId,
    _orderChannelName,
    description: 'Alerts for new restaurant orders.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(_orderChannelSound),
  );

  final List<AndroidNotificationChannel>? channels = await android.getNotificationChannels();
  AndroidNotificationChannel? current;
  for(final AndroidNotificationChannel existing in channels ?? const <AndroidNotificationChannel>[]) {
    if(existing.id == _orderChannelId) {
      current = existing;
      break;
    }
  }

  final bool channelReady = current != null
      && current.importance.value >= Importance.high.value
      && current.playSound;
  if(channelReady) {
    return true;
  }
  if(current != null) {
    await android.deleteNotificationChannel(channelId: _orderChannelId);
  }
  await android.createNotificationChannel(channel);
  return false;
}

String _orderNotificationTitle(RemoteMessage message, NotificationBodyModel notificationBody) {
  final String title = message.data['title']?.toString() ?? '';
  if(title.isNotEmpty) {
    return title;
  }
  final String orderLabel = notificationBody.orderId == null ? '' : ' (${notificationBody.orderId})';
  return 'You got a new order$orderLabel';
}

String _orderNotificationBody(RemoteMessage message) {
  final String body = message.data['body']?.toString() ?? '';
  if(body.isNotEmpty) {
    return body;
  }
  return 'Open app and check order details.';
}

int _orderNotificationId(int? orderId) {
  const int base = 100000;
  if(orderId == null || orderId <= 0) {
    return base;
  }
  return base + (orderId % 1000000);
}

Future<bool> _sameOrderNotificationVisible(AndroidFlutterLocalNotificationsPlugin android, int notificationId, String title, String body) async {
  try {
    final List<ActiveNotification> active = await android.getActiveNotifications();
    for(final ActiveNotification notification in active) {
      if(notification.id != notificationId) {
        continue;
      }
      final bool sameTitle = notification.title == null || notification.title == title;
      final bool sameBody = notification.body == null || notification.body == body || notification.bigText == body;
      return sameTitle && sameBody;
    }
  } catch (e) {
    customPrint('Active notification lookup failed: $e');
  }
  return false;
}

/// Initialize Foreground Service
@pragma('vm:entry-point')
Future<void> _initService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: _foregroundServiceChannelId,
      channelName: 'Foreground Service Notification',
      channelDescription: 'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      playSound: false,
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

/// Start Foreground Service
@pragma('vm:entry-point')
Future<ServiceRequestResult> _startService(String? orderId) async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: _foregroundServiceNotificationId,
      notificationTitle: 'You got a new order ($orderId)',
      notificationText: 'Open app and check order details.',
      callback: startCallback,
    );
  }
}

/// Stop Foreground Service
@pragma('vm:entry-point')
Future<ServiceRequestResult> stopService() async {
  try {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
  } catch (e) {
    customPrint('Audio dispose error: $e');
  }
  return FlutterForegroundTask.stopService();
}

/// Foreground Service entry point
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

/// Foreground Service Task Handler
class MyTaskHandler extends TaskHandler {
  AudioPlayer? _localPlayer;

  void _playAudio() {
    _localPlayer?.play(AssetSource('notification.mp3'));
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _localPlayer = AudioPlayer();
    _playAudio();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _playAudio();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _localPlayer?.dispose();
    await stopService();
  }

  @override
  void onReceiveData(Object data) {
    _playAudio();
  }

  @override
  void onNotificationButtonPressed(String id) {
    customPrint('onNotificationButtonPressed: $id');
    if (id == '1') {
      FlutterForegroundTask.launchApp('/');
    }
    stopService();
  }

  @override
  void onNotificationPressed() {
    customPrint('onNotificationPressed');
    FlutterForegroundTask.launchApp('/');
    stopService();
  }

  @override
  void onNotificationDismissed() {
    FlutterForegroundTask.updateService(
      notificationTitle: 'You got a new order!',
      notificationText: 'Open app and check order details.',
    );
  }
}
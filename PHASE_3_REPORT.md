# تقرير Phase 3 — إشعارات الصلاة وIqama المحلية

## الحالة

اكتمل تنفيذ الوظائف والاختبارات الآلية المذكورة أدناه. نجح بناء Android وتشغيل التطبيق على محاكي Android 17. لا أعدّ التسليم في الخلفية أو بعد إعادة تشغيل جهاز فعلي متحققًا: لم يُجرَ اختبار جهاز فعلي، ولم يُبنَ iOS على macOS. لذلك التنفيذ جاهز للمراجعة والتجربة، ويظل الاعتماد النهائي للتسليم على الأجهزة مشروطًا بهذه الاختبارات. لم تبدأ Phase 4 أوPhase 5، ولم يُنفذ commit أوpush.

## الملفات المتغيرة وأعداد الأسطر

الأعداد تشمل الأسطر الفارغة، و«قبل» مأخوذ من لقطة الملفات عند بدء هذا الطلب، لا من تقرير Phase 2 قديم. الصفر يعني ملفًا جديدًا. لا توجد ملفات مصدر محذوفة.

| الملف | قبل | بعد | سبب التغيير |
|---|---:|---:|---|
| [lib/main.dart](<D:/Flutter Project/deenora/lib/main.dart>) | 44 | 46 | تهيئة الخدمة بعد Hive وقبل تشغيل الواجهة. |
| [lib/core/data/local_data/hive_config.dart](<D:/Flutter Project/deenora/lib/core/data/local_data/hive_config.dart>) | 19 | 20 | مفتاح مستقل لجدول الغد. |
| [lib/core/data/local_data/hive_manager.dart](<D:/Flutter Project/deenora/lib/core/data/local_data/hive_manager.dart>) | 151 | 160 | قراءة وحفظ جدول الغد بالـAdapters الموجودة، ومراقبة إعدادات Iqama. |
| [lib/core/services/prayer_notification_plan.dart](<D:/Flutter Project/deenora/lib/core/services/prayer_notification_plan.dart>) | 0 | 147 | تحقق التاريخ والموقع وTimezone وبناء أحداث مستقلة بمعرّفات ثابتة. |
| [lib/core/services/prayer_notification_service.dart](<D:/Flutter Project/deenora/lib/core/services/prayer_notification_service.dart>) | 0 | 350 | مالك واحد للأذونات والجدولة والإلغاء والتحديث ونافذة البيانات. |
| [lib/features/settings/settings_screen.dart](<D:/Flutter Project/deenora/lib/features/settings/settings_screen.dart>) | 37 | 51 | مدخل صغير للأذونات وحالة التذكيرات فقط. |
| [lib/features/widget_prayer_times/controllers/prayer_times_controller.dart](<D:/Flutter Project/deenora/lib/features/widget_prayer_times/controllers/prayer_times_controller.dart>) | 233 | 252 | إبلاغ الجدولة بالبيانات، وفحص التاريخ الكامل، ورفض نتائج الطلبات القديمة. |
| [lib/features/widget_prayer_times/models/prayer_times_model.dart](<D:/Flutter Project/deenora/lib/features/widget_prayer_times/models/prayer_times_model.dart>) | 90 | 91 | تمييز وقت API المفقود عن منتصف الليل الحقيقي. |
| [test/prayer_notifications_test.dart](<D:/Flutter Project/deenora/test/prayer_notifications_test.dart>) | 0 | 653 | 19 اختبارًا مركّزًا للحساب والجدولة والأذونات والتخزين والتزامن. |
| [android/app/build.gradle.kts](<D:/Flutter Project/deenora/android/app/build.gradle.kts>) | 44 | 49 | تفعيل desugaring وإضافة مكتبته اللازمة. |
| [android/app/src/main/AndroidManifest.xml](<D:/Flutter Project/deenora/android/app/src/main/AndroidManifest.xml>) | 68 | 83 | أذونات الإشعارات الدقيقة وBoot وإعلان Receivers. |
| [android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java](<D:/Flutter Project/deenora/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java>) | 74 | 79 | تحديث مولّد آليًا لتسجيل Plugin؛ ليس تعديلًا يدويًا. |
| [android/app/src/main/res/drawable/ic_prayer_notification.xml](<D:/Flutter Project/deenora/android/app/src/main/res/drawable/ic_prayer_notification.xml>) | 0 | 6 | أيقونة إشعار أحادية اللون. |
| [android/app/src/main/res/raw/keep.xml](<D:/Flutter Project/deenora/android/app/src/main/res/raw/keep.xml>) | 3 | 3 | الاحتفاظ بالأيقونة الجديدة مع الحفاظ على أيقونتي Quran السابقتين. |
| [ios/Runner/AppDelegate.swift](<D:/Flutter Project/deenora/ios/Runner/AppDelegate.swift>) | 16 | 18 | توصيل UNUserNotificationCenter بالـdelegate. |
| [ios/Runner/GeneratedPluginRegistrant.m](<D:/Flutter Project/deenora/ios/Runner/GeneratedPluginRegistrant.m>) | 77 | 84 | تحديث مولّد آليًا لتسجيل Plugin؛ ليس تعديلًا يدويًا. |
| [ios/Runner/Info.plist](<D:/Flutter Project/deenora/ios/Runner/Info.plist>) | 70 | 72 | وصف When In Use الناقص لمسار الموقع الموجود أصلًا. |
| [pubspec.yaml](<D:/Flutter Project/deenora/pubspec.yaml>) | 117 | 119 | إضافة اعتمادي الإشعارات وTimezone فقط. |
| [pubspec.lock](<D:/Flutter Project/deenora/pubspec.lock>) | 1290 | 1330 | تثبيت الإصدارات المحلولة وتبعياتها المطلوبة. |
| [PHASE_3_REPORT.md](<D:/Flutter Project/deenora/PHASE_3_REPORT.md>) | 0 | 167 | توثيق التنفيذ والتحقق والحدود بالعربية. |

ملفا GeneratedPluginRegistrant تغيّرا آليًا مع أدوات Flutter؛ هما مولّدان وقد لا يظهران في Git status بسبب التجاهل. تشمل عملية البناء أيضًا نواتج build وملفات أدوات مولدة غير مذكورة كسورس معدل.

## ما فُحص قبل التنفيذ

- PrayerTimesService ومسار API القائم على الإحداثيات والتاريخ، وPrayerTimesController، وPrayerTimeCalculator.
- PrayerTimesModel وPrayerDateModel وPrayerMetaModel وPrayerType، وLocationService ومسار Cairo fallback.
- HiveManager وHiveConfig، وIqamaSettings وController وScreen الحالية، ومراجع الاختبارات.
- MuadhinController وMuadhinRepository، ومنطق الـID المحفوظ، وإشعارات Quran الموجودة وتهيئة audio_service. لم يُستخدم صوت المؤذن في هذه المرحلة.
- main وMainScreen وMosqueScreen وMosquePrayerSection، وSettingsScreen، ونمط Provider/ChangeNotifier القائم.
- AndroidManifest وGradle الخاص بالتطبيق وSettings وGradle wrapper، وFlutter SDK configuration.
- AppDelegate وInfo.plist وDeployment target في مشروع iOS، وpubspec وlockfile.
- اختبارات الصلاة وIqama والإشعارات الصوتية ذات الصلة، وأجزاء من مصدر Plugin المثبت للتحقق من واجهاته وسلوك Boot.
- لا يوجد AGENTS.md في جرد المشروع أو مسارات الآباء التي فُحصت.

## المكونات المضافة وما بقي كما هو

PrayerNotificationPlan مسؤول عن تحويل البيانات الموثقة إلى أحداث، دون Timer أو API أوتخزين. يحتوي أيضًا PrayerNotification، وهي بيانات صغيرة للـID والصلاة ونوع الحدث والموعد والنص وpayload.

PrayerNotificationService هو المالك الوحيد للجدولة. يتولى تهيئة Plugin والأذونات، وجلب التاريخ الناقص عبر PrayerTimesService الموجود، وقراءة Hive، وتسوية الأحداث مع طلبات النظام. لم تُضف طبقات Repository أوCoordinator إضافية.

بقيت ملفات Iqama الاثنين وMuadhin وQuran وLocationService وPrayerTimesService وPrayerTimeCalculator دون تعديل. لم تتغير الصبغات أوالخطوط أوAppBar أوNavigation الخاصة بالشاشات. إضافة UI الوحيدة هي مدخل Prayer notifications داخل Settings باستخدام OptionTileShare الموجود، لطلب الأذونات صراحة وعرض سبب توقف الجدولة أوخطئها.

لم يُضف تشغيل Adhan تلقائي أوتنزيل صوت أوFirebase أوSupabase أوBackground location أوForeground service جديد.

## الحزم والتوافق

- flutter_local_notifications 21.0.0: جدولة النظام والأذونات والقنوات وReceivers.
- timezone 0.11.2: قاعدة IANA وتحويل التوقيت والتحقق من DST.
- البيئة المثبتة: Flutter 3.41.4 وDart 3.11.1 وAGP 8.11.1 وcompileSdk 36 وJava 17؛ وiOS Deployment target الموجود 13.0. لم تُرفع هذه الإصدارات.
- أُضيف desugar_jdk_libs 2.1.4 مع تفعيل desugaring. يتفق ذلك مع [متطلبات Plugin 21](https://pub.dev/packages/flutter_local_notifications/versions/21.0.0).
- حلّ pub get أضاف تبعيات Plugin المنصية، وغيّر xml من 7.0.1 إلى 6.6.1 كاعتماد غير مباشر تفرضه القيود المحلولة. لم تُجرَ ترقية للحزم الأخرى.
- يستعمل timezone منطقة API الصريحة، لا المنطقة الافتراضية للجهاز؛ وهذا من استخدامات [قاعدة IANA وTZDateTime](https://pub.dev/packages/timezone/versions/0.11.2).

## التحقق الضروري بدل تنفيذ Phase 1 كاملة

المحلل الموجود للعرض قد يعيد منتصف الليل عند فشل قراءة الوقت، والـCountdown قد يستخدم Fajr اليوم لحساب الغد. لذلك لا يعتمد مسار الإشعارات على نتائج هذا Calculator، ولم يُعدّل Calculator نفسه.

التحقق الخاص بالإشعارات يشترط:
- تاريخ Gregorian بصيغة صحيحة ومتسقًا مع day وmonthNumber وyear، دون قبول تطبيع مثل 31 فبراير.
- Timezone معروفًا في IANA، وإحداثيات تطابق الموقع النشط ضمن 0.01 درجة لكل محور. مصدر Timezone هو metadata الخاص بالـAPI المرتبط بهذه الإحداثيات؛ لم تُضف قاعدة مستقلة لتحويل الإحداثيات إلى Timezone.
- عدم استخدام الموقع الاحتياطي للقاهرة تلقائيًا. إذا فشل تحديد الموقع، تُوقف الإشعارات المملوكة للميزة وتظهر الحالة في Settings.
- وقتًا صحيحًا HH:mm أوHH:mm:ss، مع رفض الساعة أوالدقائق أوالثواني خارج النطاق. الفحص يقرأ timings نفسها، ولا يستعمل getTimeFor الذي قد يوفر قيمة افتراضية.
- رفض الساعات المفقودة أثناء تقدم DST والساعات الملتبسة أثناء رجوعه، لأن API لا يقدم offset يكفي لاختيار أحد الاحتمالين في هذه الحالة.
- مواعيد مستقبلية فقط، مستخرجة من تاريخها الفعلي؛ لا يُنسخ Fajr اليوم إلى الغد.

التصحيحات الصغيرة خارج الخدمة: cleanTime يبقي الوقت المفقود فارغًا بدل 00:00، وController يقارن التاريخ الكامل بدل رقم اليوم فقط، ويستعمل رقم إصدار للطلب كي لا تستبدل استجابة موقع قديم متأخرة نتائج الموقع الأحدث. كما يبطل الطلب الجاري عند dispose. هذه حماية محدودة لازمة لتغذية الجدولة، وليست إعادة تصميم لمواقيت الصلاة أوالموقع.

وُجد أن Info.plist يفتقد وصف When In Use المطلوب لمسار LocationService الموجود؛ أُضيف الوصف فقط وفق [متطلبات geolocator المثبتة](https://pub.dev/packages/geolocator/versions/14.0.2). لم تُضف صلاحية موقع في الخلفية أوصلاحية Always.

## كيف تُجدول الصلاة وIqama

يُنشئ Planner حدثًا مستقلًا لكل من Fajr وDhuhr وAsr وMaghrib وIsha. الشروق خارج القائمة. النص يذكر اسم الصلاة، مع عنوان Prayer Time أوIqama Time.

يُقرأ IqamaSettings مباشرة من Hive بصيغة Phase 2 نفسها. إذا كان enabled معطلًا فلا تُنشأ أحداث Iqama. إذا كان مفعلًا، يُضاف التأخير المحفوظ لكل صلاة إلى بداية الصلاة الموثقة، حتى لو تجاوز الموعد منتصف الليل. لا علاقة للحساب بنهاية معاينة الصوت. بقيت القيم 20/15/15/5/15 ونطاق 0–180 دون تغيير.

تُحوّل النتيجة إلى UTC عند إرسالها إلى zonedSchedule، مع إبقاء منطقة الصلاة في payload. بذلك لا يزيح تغيير Timezone الجهاز الموعد المخطط، ولا يعتمد Alarm على قاعدة Timezone قديمة على الجهاز. لا يستعمل التطبيق تكرارًا يوميًا ثابتًا أوTimer لتسليم الإشعارات.

## نافذة البيانات والتخزين دون اتصال

النافذة المستقبلية هي اليوم والغد وفق منطقة المواقيت. يستخدم التنفيذ البيانات المحملة والكاش الصحيح أولًا، ولا يطلب تاريخًا موجودًا ومطابقًا. عند الحاجة يطلب التاريخ الناقص صراحة عبر الخدمة الحالية. الاستجابة ذات التاريخ أوالموقع المختلف لا تُعتمد.

يحفظ جدول الغد تحت notification_tomorrow داخل prayerTimesBox الموجود، باستخدام PrayerTimesModel Adapter القائم. لا يوجد Box أوAdapter جديد. وعندما يصبح جدول الغد هو اليوم، يُرقى إلى كاش اليوم قبل استبدال جدول الغد.

يمكن الاحتفاظ بحدث Iqama من صلاة Isha بالأمس إذا كان موعده ما زال مستقبلًا بعد منتصف الليل. لذلك يكون المعتاد حتى 20 حدثًا لليوم والغد، مع بقايا محدودة من اليوم السابق عند توفرها؛ الحد المحافظ ثلاثة تواريخ وخمسة أنواع صلاة ونوعان من الأحداث، أي30 حدثًا، دون حد iOS البالغ64.

إذا فشل API تُستخدم التواريخ المطابقة المخزنة فقط. لا يُختلق جدول بديل. يتجنب التنفيذ إعادة طلب التاريخ الذي فشل في كل تعديل للإعدادات، ويعيد المحاولة عند تحديث مواقيت الصلاة أوعودة التطبيق أوإجراء المستخدم الصريح.

## الأذونات والتحديث ومنع التكرار

طلب الأذونات يبدأ من نقرة المستخدم على Prayer notifications في Settings؛ فتح التطبيق أوالعودة إليه لا يفرضان Dialog جديدًا.

على Android يُفحص إذن الإشعارات وExact alarm access. إذا لم يتوفر أحدهما، لا تستخدم الخدمة جدولًا تقريبيًا وتصفه بأنه دقيق؛ تُوقف أحداثها وتوضح الإذن المطلوب. تستعمل SCHEDULE_EXACT_ALARM لاUSE_EXACT_ALARM، وقناة مستقلة deenora.prayer_reminders، وexactAllowWhileIdle بعد توفر الوصول. راجع [قيود Android الرسمية](https://developer.android.com/develop/background-work/services/alarms).

على iOS تتهيأ المكتبة دون طلب آلي، ثم يُطلب alert/sound/badge عند نقرة المستخدم، ويُفحص السماح بالإشعارات والتنبيهات قبل الجدولة. أُضيف UNUserNotificationCenter delegate وفق إعداد Plugin.

IDs مشتقة من التاريخ والصلاة ونوع الحدث، وتبقى ثابتة عند تغيير التأخير. تحدد payload الأحداث التي تملكها الميزة؛ لا يُستخدم cancelAll ولا تُلغى أحداث Quran أوغيرها.

تقرأ الخدمة pendingNotificationRequests، وتحذف أحداثها التي خرجت من الخطة، وتستبدل المواعيد المتغيرة، وتتجنب إعادة جدولة الحدث المطابق أثناء الجلسة. عند أول سماح في عملية جديدة أوعودة السماح، تُعاد كتابة IDs نفسها لاستعادة Alarms التي قد يكون النظام أزالها؛ هذا لا يضيف نسخًا بأرقام جديدة.

كل التحديثات تمر في طابور واحد، ورقم إصدار يمنع استجابة API أوعملية جدولة قديمة من الكتابة فوق قرار أحدث. تراقب الخدمة مفتاح Iqama في Hive؛ لذلك حفظ التأخير أوالتعطيل يعيد حساب الأحداث دون إضافة منطق إشعارات إلى Iqama UI أوController.

عند تحميل مواقيت جديدة أوطلب تحديث الموقع يبلغ PrayerTimesController الخدمة. وعند استئناف التطبيق تُراجع الأذونات والمواعيد وتُملأ نافذة البيانات إن أمكن. مراقبة تغير اليوم الموجودة في Controller بقيت، مع تصحيح مقارنة التاريخ. لا يوجد تعقب جديد لحركة المستخدم في الخلفية.

## الخلفية وإعادة التشغيل وحدود المنصات

بعد نجاح الجدولة، Android AlarmManager أوiOS UserNotifications هما من يسلمان الإشعار؛ لا يلزم تشغيل واجهة Flutter أوبدء Dart عند التسليم.

أُعلن ScheduledNotificationReceiver وScheduledNotificationBootReceiver وRECEIVE_BOOT_COMPLETED في Android لاستعادة الطلبات المخزنة بعد Boot أوتحديث التطبيق حيث يسمح النظام. الحماية من حذف أيقونات Quran الحالية بقيت في keep.xml، وأُضيفت أيقونة الإشعار الجديدة.

هذا إعداد للتعافي وليس اختبارًا فعليًا للتعافي. مصدر Plugin يعيد جدولة طلباته المحفوظة عند Boot، وقد يسلم النظام إشعارات فات موعدها أثناء إطفاء الجهاز بعد التشغيل؛ لم تُضف سياسة native مستقلة لإسقاط هذه الحالات. التطبيق نفسه لا يرسل طلب zonedSchedule لموعد مضى.

لا ينفذ Boot تحميل API أوتوسيع النافذة. بعد انقضاء التواريخ المتاحة دون فتح التطبيق تنتهي الأحداث؛ يجب فتح التطبيق للحصول على بيانات موثقة جديدة. هذا حد مقصود بدل خدمة خلفية أوتكرار زائف.

الإغلاق بالقوة وقيود البطارية وDoze وإعدادات القناة وFocus في iOS قد تؤثر في التسليم. Exact access لا يلغي جميع قيود النظام. تغيير الموقع فعليًا أثناء إغلاق التطبيق لا يُكتشف تلقائيًا، ولا توجد مراقبة موقع في الخلفية.

## الاختبارات والأوامر الفعلية

التشغيل النهائي المكتمل: **67 اختبارًا نجحت**، باستخدام:

```powershell
flutter test --no-pub test/prayer_notifications_test.dart test/adhan_iqama_settings_test.dart test/muadhin_controller_test.dart test/muadhin_data_test.dart test/audio_player_controller_test.dart test/quran_audio_notification_test.dart test/sleep_timer_controller_test.dart test/surah_navigation_service_test.dart
```

منها19 اختبارًا جديدًا: الصلوات الخمس، واستبعاد الشروق، والتأخيرات المستقلة وصفر دقيقة، وIDs، والماضي والكاش القديم، والقيم المفقودة وغير الصالحة، واختلاف الموقع وTimezone، وDST، وحدود الشهر والسنة، وعبور Isha لمنتصف الليل، ورفض استجابة الغد ذات تاريخ اليوم، وعدم التكرار، وتعديل Iqama وتعطيلها عبر Hive watch، ورفض الأذونات، وعودة التطبيق وتغير اليوم، وتزامن الطلبات، وتفويض iOS باستخدام mock، وإغلاق Hive وإعادة فتحه دون فقد تفضيلات المؤذن وIqama.

اختبارات Android/iOS الخاصة بالجدولة تستعمل Platform Channel وهميًا. لا تثبت إرسال إشعار فعلي على منصة حقيقية. صححت أثناء تطويرها تسجيل Android Plugin في بيئة الاختبار وتوقع اسم UTC الفعلي Etc/UTC؛ هذه إخفاقات وسيطة، والنتيجة النهائية أعلاه بعد تصحيحها.

الأوامر الأخرى:
- flutter pub get نجح، والإصدارات الجديدة مثبتة في lockfile.
- dart format على ملفات Dart المعدلة والجديدة.
- التحليل المحدد أدناه: **No issues found** بعد آخر تغيير.
- flutter analyze --no-pub للمشروع كله: **8 ملاحظات موجودة خارج الكود الجديد**، دون errors: ست info وتحذيران في اختبار Verse؛ لذلك خرج الأمر بحالة غير ناجحة.
- flutter test --no-pub test/adhan_iqama_settings_test.dart test/prayer_times_test.dart: **27 نجح و4 فشلت** في اختبارات Prayer Times التي تستدعي HiveManager دون تهيئة prayerTimesBox. لم تُصلح هذه الاختبارات خارج نطاق المرحلة، ولم يُدّع نجاح جميع اختبارات المشروع.
- flutter build apk --debug --no-pub نجح، وأُعيد بعد آخر تعديل لكود التطبيق ونجح.
- flutter run -d emulator-5554 --debug --no-resident --no-pub بنى وثبت وشغل التطبيق على Android17/API37 emulator بنجاح. فحص logcat المحدد للعملية لم يعرض flutter:E أوAndroidRuntime:E وقت الفحص.
- dumpsys package أكد إعلان Receivers وأذونات الإشعارات؛ إذن POST_NOTIFICATIONS على المحاكي كان granted=false. لم يُمنح قسرًا أوتُغيّر خيارات المستخدم.
- XML الخاص بـManifest والأيقونة وkeep وInfo.plist قُرئ بنجاح، وgit diff --check نجح.

```powershell
flutter analyze --no-pub lib/core/services/prayer_notification_plan.dart lib/core/services/prayer_notification_service.dart lib/core/data/local_data lib/features/settings/settings_screen.dart lib/features/widget_prayer_times/controllers/prayer_times_controller.dart lib/features/widget_prayer_times/models/prayer_times_model.dart lib/main.dart test/prayer_notifications_test.dart
```

لم تُنفذ اختبارات تسليم حقيقية في الخلفية أوبعد reboot، ولم يُنفذ iOS build أواختبار جهاز فعلي. نجح تشغيل المحاكي فقط؛ لا يصح استنتاج موثوقية الخلفية منه.

## المتبقي للاعتماد النهائي

- منح الأذونات من الواجهة على جهاز فعلي، وفحص كل صلاة وIqama أثناء foreground/background وإغلاق UI.
- فحص Android reboot وExact access revoke/restore وقيود البطارية، وتحديد السلوك المرغوب للتذكيرات التي فاتت أثناء إطفاء الجهاز.
- بناء iOS على macOS واختبار authorization وforeground/background وFocus وإعادة التشغيل.
- اختبار تجربة Permission UI فعليًا؛ الاختبارات الحالية تغطي منطقها وPlatform Channel فقط.
- تذكر نافذة اليوم والغد والحاجة إلى فتح التطبيق بعد انتهاء البيانات؛ لا يوجد تحديث شبكي خلفي دائم.
- إصلاح إخفاقات اختبارات Prayer Times وملاحظات التحليل العامة في مهمة مستقلة إذا رغبت.

لم تُغيّر قيم المستخدم أوصيغة Iqama أوالمؤذن المختار، ولم يُنفذ تشغيل صوت Adhan تلقائي. توقفت المهمة عند Phase 3.

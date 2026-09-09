# colloborator_v3 — holat va eslatmalar

Bu fayl **o'zgaradi**. Qat'iy qoidalar `CLAUDE.md` da va ular bu yerdan boshqarilmaydi:
bu yerda faqat loyihaning hozirgi holati, ochiq ishlar, backendga savollar va
kelajakda qilinadigan ishlar turadi.

*Yangilangan: 2026-09-09*

---


### Tugallangan tizimlar

**Xatolar (5.x) — to'liq.** `FailureGroup` va `Failure.group` / `Failure.isReportable` getterlari `core/error` da. Barcha bloclar `Failure?` saqlaydi, birortasi matn to'qimaydi. `FailureView` guruhga qarab yo'naltiradi: `session` → dialog + chiqish, `connection` → banner + "Qayta urinish", `input` → maydon tagida, `internal` → umumiy matn. Foydalanuvchiga ko'rinadigan matn `FailureText` da — yagona manba. To'rtala ekran ham ulangan: mijozlar, shartnomalar, login, registratsiya.

**Telegram bot (5.7) — ishlayapti.** `TelegramErrorReporter` + `ErrorReportInterceptor`, `injection.dart` da ulangan. `JsonParser.reporter` ham shu kanalga ulandi — u loyiha boshidan beri o'lik turgan edi. Token va chat id `.env` da (git'da kuzatilmaydi). Takrorlar 10 daqiqalik oynada filtrlanadi.

**`guard()` — `core/error/result_guard.dart` da** (2026-09-09 da `contract_create` dan ko'chirildi: uni ikkita feature ishlatadi, 1.2). `underwriter` dagi nusxa o'chirildi.

**Repository chegarasidagi xatolar ham botga ketadi** (`GuardReport.reporter`, 2026-09-09). Ilgari faqat `ErrorReportInterceptor` xabar berardi, u esa **faqat interceptor zanjiridan o'tgan** `DioException` ni ko'radi. `TypeError`, buzuq shakl va Dio'ning javobni tipga keltirishdagi xatosi — ya'ni 5.7 aynan xabar berishni talab qiladigan sinf — hech qayerga bormasdi. Takrorlanmaslik uchun `guard` `DioException` ni yubormaydi; istisno — `error is TypeError` bo'lgani, chunki u interceptordan **keyin** yaraladi (`dio_mixin.dart:576`).

**Dio javob tipi — tuzoq (2026-09-09).** `dio.get<Map<String, dynamic>>` javobni `response.data as T?` bilan tipga keltiradi (`dio_mixin.dart:807`). Server obyekt o'rniga bo'sh ro'yxat, HTML sahifa yoki matn qaytarsa yiqiladi, va yiqilish **interceptor zanjiri tugagandan keyin** sodir bo'ladi — ekranda «Xatolik yuz berdi», botda hech nima. Anderrayter ekrani shu sababli ochilmasdi: hujjat kiritilmagan shartnomada `GET underwriters` `[]` qaytaradi.

Qolip: datasource'da javob tipi `dynamic`, shakl qarori `JsonParser` va DTO da. Bo'sh javob qonuniy bo'lsa `null`, kutilmagan shakl bo'lsa `FormatException` — jimgina "bo'sh" ga aylantirilmaydi (5.8). Namuna: `underwriter_remote_datasource.dart` + `UnderwriterDataDto.tryFrom`, testi `underwriter_dto_test.dart`.

**Qolgan 37 joy hali eski qolipda** — 13 ta datasource (`contract_create` da 10, `contracts` da 8). Ular bugun ishlayapti, chunki o'sha endpointlar obyekt qaytaryapti.

**Oferta bir marta o'qiladi va spinnersiz ochiladi** (2026-09-09). Ikkita yuklanish belgisi bor edi, ikkalasi ham **har ochilishda**:

1. `HtmlWidget` ning `buildAsync` sukut qiymati `html.length > 10000`, oferta esa ~26 000 belgi. Async rejimda kutubxona `compute()` bilan har safar yangi izolyat ochadi va parse tugagunicha **o'zining** `CircularProgressIndicator` ini chizadi (`core_widget_factory.dart:628`). `enableCaching` ning sukut qiymati esa `!buildAsync` — ya'ni kesh ham o'chiq qolardi. Endi `buildAsync: false` + `enableCaching: true`; sinxron parse o'lchandi va bir-ikki kadr.
2. Oyna `rootBundle.loadString` ni `await` qilardi. `rootBundle` keshlaydi (birinchi o'qish 14.6 ms, keyingisi 0.3 ms), lekin natija baribir `Future` — kamida bitta kadr belgi bilan chiziladi. `OfferDocument` (`core/services/`) matnni saqlaydi va oyna uni **sinxron** oladi; `AppStartup` uni ishga tushishda oldindan o'qiydi, shuning uchun birinchi ochilish ham belgisiz.

`offer_sheet_test.dart` shuni qulflaydi: ekranda birorta yuklanish belgisi bo'lmasligi kerak (`buildAsync` qaytarilsa test yiqiladi — tekshirildi).

**Kiritish validatsiyasi (7.x).** Qoida domainda (`CustomerSearchIssue`) yoki presentationda (`LoginFieldIssue`), holat bloc'da, matn sahifada. Bloc'da birorta foydalanuvchi matni qolmagan.

**Featurelar.** Login, registratsiya, mijozlar, shartnomalar — to'liq zanjir bilan. Shartnomalarda `ContractStatus` enum, `ContractsFilter`, sana filtri va amal oynasi bor.

**face_id (mijozlar ichida) — to'liq.** Forma (`FaceCheckForm`: seriya, raqam, sana; 16 yosh qoidasi) → oferta tasdig'i → kamera → avtomatik surat → `checkClient`. Kamera qismi uchga bo'lingan: `FacePlacementRule` va `FaceHold` domainda va kamerasiz testlanadi, `FaceScanner` aylantirish va ko'zguni hisoblaydi, `FaceCameraController` kamera hayotini boshqaradi. Flex'ning platformaga bog'liq chegaralari, bir martalik barqarorlik taymeri va bo'sh `catch` lari takrorlanmagan. Rasm har doim 720px ga siqiladi, base64 `Isolate.run` da kodlanadi.

**Mijoz qo'shish / tahrirlash — to'liq.** `CustomerForm` (validatsiya domainda), manzil ma'lumotnomasi 24 soatlik kesh bilan (`LocalCache` + `SharedPrefsCache`), ish joyi qidiruvi (serverda, `restartable` + 350 ms kutish), `PUT update_client_data`. Qarindosh izohi `RelativeKind` enumida: `title` — backend shartnomasi, ekran matni tarjimadan keyin undan ajraladi.

**Mijoz amallari.** Skoring natijasi, to'liq ma'lumot oynasi va tahrirlash ulangan. `pressContract` ochiq — u mahsulotlarga olib boradi.

**Shartnoma natijasi — uchala tab to'liq.** Shartnomalar ro'yxatidagi "Batafsil" ochadi.

- **Skoring:** `scoring-result/{id}` ro'yxat qaytaradi — har ishtirokchi (mijoz va kafillar) uchun bitta yozuv. Limit kartasi, ichki 4 tekshiruv, tashqi 8 manba. Flex shartnomalarida `flex-contracts/{id}/error-messages` qo'shiladi.
- **MIB:** `credit-reports` ishtirokchilarni beradi, `mib?client_id=` hisobotni. `state: not_checked` — xato emas, qonuniy holat.
- **KATM:** `katm?client_id=`, javob 1.7 MB gacha — `ResponseType.plain` bilan olinib `Isolate.run` da ochiladi. Ball gauge'i va dinamika grafigi `CustomPainter` bilan (grafik kutubxonasi qo'shilmagan). Jadvallar backend maketiga (`layout`) qarab chiziladi, shartnoma qatori bosilganda tafsilot oynasi va oltita ichki ro'yxat ochiladi.

Har uch tabning **o'z xatosi va o'z "Qayta urinish"** i bor: bir tabning nosozligi ikkinchisining ma'lumotini o'chirmaydi.

**KATM summalari bo'linmaydi.** Javob so'mda keladi (DEV-4085). Flex'da model ularni 100 ga bo'lgan, bu xato deb topilib olib tashlangan — lekin `katm_fields.dart:41` da yetim izoh qolgan va u o'chirilgan metodga havola qiladi. Shu izohga ishonib bo'lmaydi; flex'ning `test/helper_money_test.dart` i haqiqiy qoidani qulflaydi. v3 da ham `katm_money_fields_test.dart` shuni qulflaydi.

**UI.** Mijozlar va shartnomalar ekranlari qurilgan; umumiy komponentlar `core/widgets/` da (`sheets/`, `states/`, `feedback/`, `dialogs/`, `backgrounds/`). `!` operatori UI'da **nol**, eskirgan API va `ignore_for_file` yo'q, barcha UI klasslari `final`.

---

**Shartnoma tuzish — uch tabli ekran.** `lib/features/contract_create/`. `presentation/` ekran papkalariga bo'lingan (1.1a).

Flex'ning shakli saqlangan — **Shartnoma / Tovarlar / Kafillar** — chunki eng ko'p ishlatiladigan uchta narsa orasida o'tish uchun orqaga qaytish shart emas. Flex'ning nuqsoni esa saqlanmagan: **birinchi tab scroll qiladi.** Flex'da u `Column(spaceBetween)` da turadi va 360×780 da ~160px toshadi (ko'rish rejimida ham).

**Scroll olib tashlanmaydi — bu o'lchangan** (`terms_tab_fit_test.dart`, 2026-09-08). Ekranda kontent "sig'ayotganday" ko'rinishi aldamchi: oxirgi qatorlar ekran chetidan sal pastda qoladi. `maxScrollExtent` (toshgan piksel):

| Holat | Toshish |
|---|---|
| 393×852, yengil (kartasiz, «Qo'shimcha» da 3 qator) | **82px** |
| 393×852, to'liq (karta + 5 qator) | **242px** |
| 360×640 (kichik Android) | **319px** |
| 393×852, tizim shrifti 1.3× | **444px** |

Ya'ni eng yengil holatda ham sig'maydi. Test shu faktni qulflaydi: kimdir `ListView` ni `Column` ga almashtirsa, u yiqiladi.

Tabga tiqilmaydigan narsalar — **kam ishlatiladigan va shartli** bo'lganlar: to'lov jadvali, maxsus tarif, anderrayter, menejer bonusi, KATM skip. Ular «Qo'shimcha» qatorlaridan alohida ekran bo'lib ochiladi. Aks holda birinchi tab flex'dagidek cheksiz o'sadi.

| Ekran | Egallaydigan server resursi |
|---|---|
| `ContractCreatePage` — uch tab | `GET loans/{id}`, `contract_payment_days`, `occupation-types`, `POST/PUT loans` |
| ↳ tab «Shartnoma» | muddat, to'lov kuni, daromad asosi, kasb turi (yuborishda saqlanadi) |
| ↳ tab «Tovarlar» | `loans/draft`, `add/update/delete_loan_product` |
| ↳ tab «Kafillar» | `add/delete_loan_guarantor` |
| `CardSection` (1-tab ichida) | `add/delete_loan_plastic_card` |
| `ProductPickerPage` | katalog kaskadi |
| `GuarantorPickerPage` (mijozlar ichida) | `client-search`, `check_client_by_myid` |
| `PaymentSchedulePage` | `generate_graphic` |
| `SpecialTariffPage` | `contracts/{id}/special-tariff` |
| `ManagerBonusPage` | `contract/benefit` |
| `KatmSkipPage` | `underwriter/turn-off-katm`, `skip-reason-categories` |
| `ContractDetailsPage` | status 11 — faqat o'qish, alohida ekran |

**Qulflangan qarorlar:**

1. **Qoralama birinchi tovar qo'shilganda yaratiladi.** Uni yaratadigan yagona bloc — `ContractProductsBloc`. `contractId` paydo bo'lishi alohida signal: tovar qo'shish undan keyin yiqilsa ham karta va kafil bo'limlari ochiladi.
2. **Har bir resurs o'z bloci.** `ContractCreateBloc` shartnoma yozuvini (muddat, kun, daromad asosi, kasb) va yuborishni egallaydi; tovar, kafil va karta — alohida. Ular bir-birini bilmaydi: muvaffaqiyatli yozuvdan keyin `revision` oshadi va ekran shartnomani qayta o'qiydi. **Yopishqoq bayroq emas, hisoblagich** — aks holda ikkinchi o'zgarish tinglovchini uyg'otmaydi.
3. **`ContractWriteMixin`** har bir yozuvda ikkita qoidani qulflaydi: mahalliy holat faqat `Ok` dan keyin o'zgaradi, va muvaffaqiyatsiz amal eslab qolinadi ("Qayta urinish" aynan shuni takrorlaydi).
4. **`SpokeScaffold`** — `failure` konstruktor parametri, ya'ni xato yuzasisiz yangi qo'shimcha ekran yozib bo'lmaydi (5.8).
5. **`ContractExtras` — sof Dart obyekt.** Qaysi qo'shimcha ekran ko'rinishi va nega ochilmasligi shu yerda; widget faqat chizadi.
6. **`ContractDetailsPage` alohida qoladi**, `mode: readOnly` bayrog'iga aylantirilmaydi. Flex'ning `showAction` bayrog'i ikki joyda unutilgan va ko'rish rejimida karta ham, kafil ham o'chirib yuboriladi.
7. **`POST` va `PUT` mezoni — status, marshrut argumenti emas.** Qoralama status 1 da turadi va aynan shunda `POST` kutiladi.
8. **Repository iste'molchi bo'yicha bo'lingan** (ISP): `ContractCreate`, `ContractIncome`, `ContractGuarantor`, `PaymentSchedule`, `SpecialTariff`, `ManagerBonus`, `KatmSkip`. `guard()` — istisnodan `Failure` ga o'girishning yagona joyi, shuning uchun 5.5 dagi oxirgi `catch (_)` ni unutib bo'lmaydi.
9. **`IncomeBasis { formal, informal }`** — flex'ning `isFormal: state.isInformal` teskari nomlanishi tip darajasida yopildi.
10. **"Yuborish" tugmasi hech qachon o'chirilmaydi.** Tovar yo'q bo'lsa ekran o'zi «Tovarlar» tabiga o'tadi — aks holda tugma bosiladi va hech nima ko'rinmasdi.

**Flex nuqsonlari takrorlanmadi:** birinchi tabning toshib ketishi; bo'sh shartnomani rangga (`color != grey`) tayangan holda to'sish; ko'rish rejimida o'chirish tugmalarining ochiq qolishi; `occupation-types` xatosining butunlay yutilishi; grafikda bo'sh javob bilan tarmoq xatosining farqlanmasligi; bonus so'rovining yuklanish belgisisiz ketishi; KATM `success: false` ning e'tiborsiz qolishi.

**Ochiq qolgani:** imzolash, avto-to'lov.

**IMEI faqat rasmdan o'qiladi — qo'lda kiritilmaydi.** Raqamlanadigan toifada foydalanuvchi qurilma yorlig'ini suratga oladi, `POST imei/phone/img` suratni va tanlangan tovar id sini oladi, javobdagi ro'yxat draftdagini **butunligicha almashtiradi**. Server o'sha qurilmaga tegishli barcha raqamlarni qaytaradi, ya'ni javob to'liq ro'yxat — qo'shish emas, almashtirish. Shu sababli kiritish maydoni ham, bittalab o'chirish ham yo'q: aks holda ekranda serverning javobi bilan foydalanuvchi yozgani aralashib, qaysi biri to'g'ri ekani bilinmasdi.

Kamera sahifada ochiladi, bloc faqat `File` ni oladi (6.2). Rasm 2400px / 90% ga chegaralanadi — chegara ataylab baland: yorliqdagi IMEI mayda shrift, kuchli siqish serverning o'qishini buzadi. Base64 `Isolate.run` da kodlanadi (flex umuman siqmaydi va 4-6 MB tanani base64 bilan ~7 MB ga chiqaradi).

**Tovar almashsa IMEI ro'yxati bekor bo'ladi** (`ProductDraft.withVariant`). Raqamlar aynan tanlangan qurilmaning yorlig'idan o'qilgan; almashtirilmasa, oldingi qurilmaning IMEI'lari yangisining nomi bilan serverga ketardi. Flex ham shunday qiladi (`SelectedItem` ning to'rttala tarmog'ida `imeiS: []`).

**Kamera ochilmasligi ham ko'rinadigan holat.** `pickImage` ruxsat berilmaganda, kamera yo'q bo'lganda yoki oldingi tanlov tugamaganda `PlatformException` otadi. Qo'lda kiritish olib tashlangani uchun bu holatda foydalanuvchida boshqa yo'l qolmaydi — sabab `CameraIssue` ga aylanib maydon tagida chiqadi. U server xatosi emas, shuning uchun `Failure` dan alohida maydonda turadi (7.5).

**`ImeiScanned` — `restartable`, `droppable` emas.** Yangi surat eskisining o'rnini egallaydi. `droppable` bilan ikkinchi surat jimgina tashlanardi, tovar almashtirilgach tugma qaytadan ochilgani uchun bu oson yuz berardi. Skan ketayotganda «Qo'shish» ishlamaydi (tugmada aylanish belgisi) — aks holda ekran hali yo'ldagi ro'yxat o'rniga eskisini shartnomaga yozib yopilardi.

**Flex nuqsonlari takrorlanmadi:** xato tarmog'ining `(error) => emit(isLoading: false)` bilan yutilishi — v3 da `FailureView` ga chiqadi va aloqa uzilsa banner + «Qayta urinish» oxirgi suratni qayta yuboradi (foydalanuvchi ikkinchi marta suratga olmaydi); tovar tanlanmasdan yuborilgan `product_variant_id: null` — v3 da tugma tovar tanlanmaguncha o'chiq va tagida sababi yozilgan; **ro'yxat to'lgach kamera tugmasining butunlay yo'qolishi** (`visible: … && state.imeiS.isEmpty`) — flex'da noto'g'ri o'qilgan raqamni tuzatishning yagona yo'li tovarni almashtirish edi, v3 da tugma «Qayta suratga olish» bo'lib qoladi. Bo'sh `imeis` ro'yxati — HTTP 200 bo'lsa ham xato: repositoryda `ClientFailure` ga aylanadi.

**Shartnomalar ro'yxati tortib yangilanadi.** `PullRefresh` — `RefreshIndicator` ning `onRefresh` i yuklash tugagunicha kutadigan `Future` talab qiladi; bloc bilan bu o'z-o'zidan bajarilmaydi va indikator aylanmasdan yo'qoladi. Widget buni bloc oqimidan kutadi (30 soniya chegara bilan — javob kelmasa indikator abadiy aylanib qolmaydi). Skelet endi faqat **birinchi** yuklashda chiziladi: yangilashda ro'yxat ekranda qoladi.

Shartnoma tuzish ekranidan qaytilganda ro'yxat **har qanday holatda** yangilanadi — ekran yuborilmasa ham tovar, kafil yoki kartani serverga yozgan bo'lishi mumkin.

**Push xabarlari — `core/services/push_notifications.dart`** (2026-09-09). `PushMessage` (`message`, `contract_id`) va `PushNotifications` kanali: `received` (ilova ochiq) va `opened` (bildirishnoma bosildi). `FirebaseService` xabarni **oladi**, ekranlar unga **javob beradi** — shuning uchun ikkitasi alohida klass.

Uchala kirish yo'li ham yopilgan: `onMessage`, `onMessageOpenedApp`, `getInitialMessage` va lokal bildirishnomaning `getNotificationAppLaunchDetails` i. Sovuq startda ikkita tuzoq bor: broadcast oqim xabarni saqlamaydi va `ContractsBloc` hali yaratilmagan bo'ladi (`takePending` shuning uchun), `AppRouter` ham `FirebaseService.initialize()` dan keyin yaraladi (shuning uchun `redirect` da `hasPending` ham tekshiriladi).

Bosilganda: `AppRouter` shartnomalar tabiga o'tkazadi, `ContractsBloc` sana filtrini tozalab ro'yxatni qayta o'qiydi, `ContractsPage` esa **ro'yxat yuklanib bo'lgach** shartnomani topib `_onTap` ni chaqiradi — ya'ni kartani bosish bilan bir xil natija. Yuklash yiqilsa belgi saqlanadi: «Qayta urinish» muvaffaqiyatli tugagach shartnoma baribir ochiladi. Imzolash sahifasi yozilganda push kodiga tegilmaydi — `ApproveAction.proceed` o'sha sahifaga olib boradi.

**`LocalNotificationService` endi DI da** (2026-09-09). Ilgari u `static` singleton edi (12-bo'lim taqiqi) va **har qanday** bildirishnoma bosilganda Android "Yuklanmalar" papkasini ochardi — payloadga umuman qaralmasdi. `openDownloadsFolder` o'chirildi: v3 da yuklab olish funksiyasi yo'q.

**`ContractChanges` — `core/contract/contract_changes.dart`** (2026-09-09). `ContractCreateBloc` yuborish `Ok` bo'lganda `created` yoki `updated` deb belgilaydi, `ContractsBloc` esa ro'yxatni qayta o'qiydi. `created` da sana filtri ham tozalanadi (yangi shartnoma bugungi, eski sanaga qo'yilgan filtr uni yashirardi); `updated` da tegilmaydi.

Shu bilan mijozlar ekranidan shartnoma tuzilgach ilova **o'zi** shartnomalar tabiga o'tadi va ro'yxatni yangilaydi — ilgari buni foydalanuvchi har safar qo'lda qilardi. Navigatsiya `CustomerPage` da (6.2), yangilash `ContractChanges` orqali (1.3 — `customers` `contracts` ni ko'rmaydi).

**Anderrayter — alohida feature.** `lib/features/underwriter/` (19 fayl). Beshta bo'lim: ish haqi (oxirgi 6 oy), pensiya, guvohnoma, talaba, avtomobil. Har biri **o'z server yozuvi** va o'z `editId` si — shuning uchun saqlash bo'lim bo'yicha ketadi.

Nega alohida feature: uni `contract_create` ochadi, lekin status 40 orqali `contracts` ham ochadi; ikkalasi ham import qilmasligi uchun marshrut argumenti oddiy yozuv (1.3). Ustiga bu mustaqil ish — daromad hujjatlarini yig'ish — va uni `contract_create` ichiga qo'yish featureni ikkita o'zgarish sababiga ega qilardi (10-bo'lim, S).

Qaysi bo'lim ochilishi `UnderwriterPlan` da — sof Dart: guvohnoma ish joyi toifasi 4/5/6 da, pensiya qolganida, talaba esa rasmiy daromad + kartasiz + guvohnomasiz holatda.

Fayl yuklash ikki qadam: `POST upload-s3-url` imzolangan havola beradi, keyin baytlar o'sha havolaga `PUT` qilinadi. Buning uchun **interceptorsiz alohida klient** (`UploadClient`, `core/network/dio_client.dart`): imzolangan havolaga `Authorization` va `Content-Type: application/json` ketsa imzo buziladi.

**Flex nuqsonlari takrorlanmadi:** yuklash xatosi e'tiborsiz qoldirilib kaliti baribir yozilishi; `GET` yiqilganda `editId` nolda qolib mavjud yozuv ustidan ikkinchisining yaratilishi; muvaffaqiyat toastining data qatlamidan otilishi; saqlashdan keyin id o'qilmagani uchun ikkinchi bosishda takroriy `POST`; ish haqi oylarining `DateTime.now()` ga qotirilishi.

**Javob kalitlari assimetrik** — bu bir marta noto'g'ri yozilgan va `underwriter_dto_test.dart` bilan qulflangan:

| Nima | O'qishda (`GET`) | Yozishda (`POST`/`PUT`) |
|---|---|---|
| Lavozim | `military.rank` → `{id, name, amount}` (**ichma-ich**) | tekis `rank_id`, `sum` |
| Avtomobil brendi | id `car_brand_id`, nomi `brand_name` | `car_brand_id` |
| Avtomobil markasi | id `car_model_id`, nomi `model_name` | `car_model_id` |

Xato `rank_id`/`car_brand_name` ni o'qishga urinardi: saqlashdan keyin bo'lim «Lavozimni tanlang» ga qaytib, ikkinchi bosishda saqlanmay qolardi.

**«Qayta urinish» aynan yiqilgan amalni takrorlaydi** (`_Attempt`: load / references / models / submit). Avval u faqat `data != null` ga qarardi va ma'lumotnoma xatosidan keyin **saqlashni** bajarardi — foydalanuvchi so'ramagan `POST`, brendlar ro'yxati esa abadiy bo'sh qolardi.

**«Saqlandi» va «qayta o'qildi» — ikki xil natija** (`SaveOutcome`). Yozuv ketib, qayta o'qish yiqilsa natija baribir `Ok`, faqat `data` siz: aks holda «Qayta urinish» takroriy `POST` yuborib serverda **ikkinchi yozuv** qoldirardi.

**Yuklashda yiqilgan hujjat ro'yxatda qoladi.** `skip(uploaded.length + 1)` da bittalik xato bor edi — u aynan yiqilgan faylni tashlab yuborardi va foydalanuvchining hujjati jimgina yo'qolardi (5.8), «Qayta urinish» esa «Kamida bitta hujjat yuklang» deb javob berardi.

### Ochiq ishlar

*A — ulanmagan tugmalar (5.8 buzilishi)*

Bosiladi, lekin hech nima qilmaydi — foydalanuvchi uchun bu jimgina yiqilish. 2026-09-09 holatiga **bitta**:

1. Menyu tugmasi — `customer_page.dart` va `contracts_page.dart` (`drawerPress: () {}`). Menyuning o'zi hali yo'q.

Ochiq, lekin holatini aytadigan to'rt joy qoldi (`ContractTapText`): daromad turini tanlash, SMS tasdiqlash, imzolash va markazdagi anderrayter plitkasi.

Oldingi A ro'yxatidagilar — `cache_data.dart`, `debugPrint`, `workpalce` imlosi, `FirebaseService` singletoni, face_id natijasi, mijoz amallari, shartnoma tafsiloti, `pressContract`, shartnoma amallari va tahrirlash — **yopilgan**. 2026-09-09 da yana ikkitasi yopildi: bildirishnoma bosilganda "Yuklanmalar" papkasining ochilishi va kafil qidiruvidagi bo'sh ekran (nima yozish kerakligi aytilmasdi).

*A2 — backenddan javob kutayotganlar*

5. **`is_edit` har doim `true` ketadi.** Flex'da map literalida kalit ikki marta yozilgan va oxirgisi shartsiz `true` edi — ya'ni yangi mijozda ham `true` ketgan. v3 shu xatti-harakatni saqlaydi: backend `false` yo'lida sinalmagan. **So'ralishi kerak:** `is_edit` nima uchun kerak va yangi mijozda `false` bo'lishi kerakmi?
6. **`data:image/png;base64,`** — yuz suratida yuborilayotgan baytlar JPEG. Prefiks o'qiladimi? (IMEI so'rovida prefiks `image/jpg` — u baytlarga mos.)
7. **`client-search` `page: 1` da qotgan.** Flex sahifalash qilardi; 30 tadan ko'p natija jimgina kesiladi.
8. **Skoring DTO'sida 13 ta qat'iy tip.** Flex hammasiga zaxira qiymat qo'ygan. Bitta maydon kelmasa `ParseFailure` chiqadi va botga aynan qaysi maydon ekani yoziladi — shundan keyin aniq hal qilinadi.
9. **Push xabarida `contract_id` dan boshqa maydon bormi?** Hozir faqat `message` va `contract_id` o'qiladi (flex ham shundagina). `status` yoki xabar turi bo'lsa, bosish to'g'ridan-to'g'ri kerakli ekranga tushardi — hozir status ro'yxatdagi shartnomadan olinadi, ya'ni ro'yxat yuklanmaguncha kutiladi.
10. **`GET underwriters?contract_id=` bo'sh javobda aynan nima qaytaradi?** v3 `null` va `[]` ni "hali hech nima saqlanmagan" deb qabul qiladi, boshqa shaklni esa `ParseFailure` ga aylantirib botga yozadi. Botdan kelgan birinchi xabar aniq javobni beradi.

*B — qaror kutayotganlar*

5. **Lokalizatsiya — ongli ravishda kechiktirilgan.** Uch til rejalashtirilgan: lotin o'zbek, kiril o'zbek va rus tili. `easy_localization` shuning uchun qoladi, lekin `tr()` ga o'tish **featurelar tugagandan keyin**, bitta o'tishda qilinadi — hozir har yangi ekran kalitlarni ikki marta yozishga majbur qiladi.

   O'sha ishni boshlaganda:
   - `main.dart` dagi `useOnlyLangCode: true` → **`false`** bo'lishi shart. U faqat til kodiga qaraydi, lotin va kiril o'zbek esa ikkalasi ham `uz` — bitta faylga tushib, bir-birini bosib ketadi.
   - Qo'lda ikkita fayl yoziladi (lotin o'zbek, rus). Kiril o'zbek — **transliteratsiya**, u skript bilan lotindan yaratiladi.

   Shu qaror tufayli UI'da hozirdan amal qiladigan qoida: matn qat'iy kenglikka bog'lanmaydi (`Flexible`/`Expanded`, bir qatorlida `maxLines: 1` + `ellipsis`), va foydalanuvchi matnlari har feature uchun bitta faylga yig'iladi. Kiril va rus matnlari lotindan 15–30% uzunroq.
   - **Ommaviy oferta ham tilga qarab tanlanadi.** `assets/offer/` da `offerUZ.html` va `offerRU.html` bor, `AppIcons.offerUz` / `AppIcons.offerRu` sifatida yozilgan. Hozir `OfferSheet` faqat o'zbekchasini ochadi — `offerRu` shu ishgacha chaqirilmaydi. Kiril o'zbek uchun uchinchi fayl kerak bo'ladi (transliteratsiya HTML ustida ishlamaydi — teglarni ham o'zgartirib yuboradi).
11. **Ism bo'yicha qidiruv faqat tasdiqlanganda ketadi.** `_onQueryChanged` avtomatik qidiradi, lekin faqat `params.isComplete` bo'lganda — `fullName` uchun u ta'rifi bo'yicha har doim `false`. Ya'ni ism yozib kutgan odam hech nima ko'rmaydi (klaviaturada qidiruv tugmasi turadi). Ish joyi qidiruvida bu `restartable` + 350 ms kutish bilan hal qilingan. Ismga ham shunday qilinsinmi, yoki har harfda serverga so'rov ketmasin deb shundayligicha qolsinmi? Mijozlar va kafil ekranlariga birdek tegadi.
9. Contracts DTO'sida 25 + 8 zaxira qiymat — backend qaysi maydonlar `null` bo'lishi mumkinligini aytgach hal qilinadi.
10. Registratsiyadagi `successMessage` backenddan keladi va ekranga chiqadi. Backend har xil holatda har xil matn yuborsa, matn emas `code` kerak bo'ladi.

*C — ataylab qoldirilgan*

8. `auth_remote_datasource.dart` dagi qattiq yozilgan `device_id` — turli qurilmalarda sinov uchun. **Eslatilmaydi.** Relizdan oldin `AppConstants.isStaging` bilan ajratish tavsiya etilgan.

### Shartnoma tuzish — ko'chirish rejasi

*Belgilangan: 2026-09-03. Flex to'liq skanerlangan (13 agent, 871 fayl o'qish).*

**Qabul qilingan ikkita qaror:**

1. **Qoralama birinchi tovar qo'shilganda yaratiladi**, ekran ochilganda emas. Flex'dan farq qiladi: u `POST loans/draft` ni darhol yuboradi va har bir tashlab ketilgan urinish ro'yxatda status 1 bilan axlat qator qoldiradi.
2. **Tartib: 0 → 1 → 2.** Avval poydevor, keyin faqat ko'rish ekrani (eng katta DTO yozuvsiz sinaladi), keyin yaratish.

**Bosqichlar** (har biri alohida ishga tushadi):

| # | Bosqich | Nima ochiladi |
|---|---|---|
| 0 | Poydevor: sessiya do'koni, endpointlar, qidiruvli tanlagich, tasdiq dialogi — **tugadi** | hammasi |
| 1 | Shartnomani ko'rish (status 11) — **tugadi** | `ContractTap.viewProduct` |
| 2 | Yaratish: mahsulot tanlash + qoralama + yuborish — **tugadi** | `pressContract`, `pressEdit` |
| 3 | Kafillar — **tugadi** | |
| 4 | Daromad bloki (norasmiy, avto, karta, kasb) — **tugadi** | status 40 |
| 5 | To'lov jadvali — **tugadi** | 2 va 8 ishlatadi |
| 6 | Maxsus tarif — **tugadi** | |
| 7 | KATM skip + menejer bonusi — **tugadi** | |
| 8 | Imzolash — **navbatda** | `onSigningRequested`, push bosilishi shu yerga ulanadi |
| 9 | Avto-to'lov | status 24/25 |
| T1 | Anderrayter (mustaqil, alohida feature) — **tugadi** | |

Yangi papka: `lib/features/contract_create/`. Marshrut argumentlari — oddiy `int` (clientId, contractId, rejim), shuning uchun u `features/contracts` ni ham, `features/customers` ni ham import qilmaydi (1.3). Imzolash ekrani `features/contracts/` da qoladi — u `ContractInfo` ni iste'mol qiladi.

**Eng katta xavf.** Oqim — tranzaksiyasiz 12 ta server yozuvi zanjiri. Flex'da ularning har bir xatosi data qatlamidan otilgan toast bilan yashiringan (14 ta joy). v3 toastlarni taqiqlaydi, ya'ni ularni o'chirgan zahoti 12 amal jimgina yiqiladigan bo'ladi. Ikkitasi HTTP **200** bilan keladi — `loans/draft` → `contract_id: null`, `turn-off-katm` → `success: false` — ya'ni `ErrorMapper` ularni ko'rmaydi va repositoryда `Err(ClientFailure)` ga aylantirilishi shart.

Shuning uchun: avval **bitta** amal ("mahsulot qo'shish") to'liq yoziladi va tekshiriladi, qolgan 11 tasi shu qolipda ketadi.

### Shartnoma tuzish — backendga savollar

Ko'chirishni boshlashdan oldin javob kerak:

1. `GET loans/{id}` da maxsus tarif kaliti `special_tariff` mi yoki `specialTariff`? (Flex ikki joyda ikki xil o'qiydi. Xato bo'lsa qayta ochilgan shartnomada tarif jimgina yo'qoladi.)
2. `POST add_loan_guarantor` mijoz id sini qaytaradimi yoki qator id sini? `DELETE` qaysinisini kutadi?
3. `POST /loans` tanasida `contract_id` bo'lsa u upsert bo'ladimi?
4. `count` va `price` ni satr emas, son sifatida qabul qiladimi?
5. `confirm_client_face` da `front` (base64) yoki `client_face` (multipart) — qaysi biri o'qiladi? Bittasini yuborsa bo'ladimi? (Hozir bir xil baytlar ikki marta ketadi.)
6. `add_loan_guarantor` ataylab tanasiz query-params bilanmi? `delete_loan_plastic_card` ataylab PUT mi?
7. `client-search` tekis `workplace_category_id` qaytaradimi va u `workplace.category.id` bilan bir xilmi?
8. `POST loans/draft` HTTP 200 va `contract_id: null` qaytarsa — bu doim "mijozda ochiq shartnoma bor" degani mi? Matn o'rniga kod bormi?
9. `turn-off-katm` `success: false` qaytarsa sabab maydoni bormi?
10. `POST contract/benefit` da `contract_id` qayerdan olinadi?
11. Tarif biriktirilgach muddat o'zgarsa, server uni bekor qiladimi?
12. `sign_*_contract` da HTTP 201 — shartnoma to'liq imzolanganining yagona belgisimi, yoki javob tanasida maydon bormi?
13. KATM skip tugmasi uchun status 5 + `elma_katm_check_failed` yetarlimi, yoki `permissions.scoring['turn-off-katm']` ham tekshirilishi kerakmi?
14. ~~**IMEI'li toifada `count` nima bo'lishi kerak?**~~ **Hal qilindi:** `count = 1`, flex bilan bir xil (`products_state.dart:151`). IMEI qo'lda kiritilmay, yorliqdan o'qiladigan bo'lgach savol o'z-o'zidan yopildi: bitta yorliq — bitta qurilma, lekin uning IMEI'lari bittadan ko'p bo'lishi mumkin (ikki SIM'li telefonda ikkita). `imeis.length` dan miqdor yasalsa bitta telefon ikki dona bo'lib yozilib, summa ikki barobar chiqardi.
15. **`PUT loans/{id}` qisman tanani qabul qiladimi?** Ha bo'lsa muddat, to'lov kuni va daromad asosi o'z ekranida darhol saqlanadi va "saqlanmagan qiymat" holati butunlay yo'qoladi.
16. **`GET loans/{id}` `occupation_type_id` ni qaytarmaydi.** Shu sababli shartnoma qayta ochilganda tanlangan kasb turi ko'rinmaydi va qayta so'raladi. Javobga qo'shish mumkinmi?
17. **`add_loan_guarantor` qaytaradigan `id` — mijoz id simi yoki qator id si?** `DELETE delete_loan_guarantor/{id}` qaysinisini kutadi? Hozir server qaytargani o'zgartirilmasdan saqlanadi va o'chirishda ishlatiladi (flex ham shunday).

*D — hali boshlanmagan*

9. `invoices` va `outputs` — sahifalari `Center(Text(...))`, bloclari bo'sh shablon (`// TODO: implement event handler`).
10. **Testlar — ongli ravishda loyiha oxiriga qoldirilgan.** 2026-09-09 holatiga 272 ta. Ular qoida yozilganda birga yozilgan, alohida ish sifatida emas: har biri bitta qarorni qulflaydi (`terms_tab_fit_test`, `underwriter_dto_test`, `guarantor_picker_layout_test`, `contracts_push_test`). Qolgan qamrov featurelar tugagandan keyin. **Eslatilmaydi.**
11. **`get<Map<String, dynamic>>` qolgan 37 joyda** — yuqoridagi "Dio javob tipi" qolipiga o'tkazilishi kerak.

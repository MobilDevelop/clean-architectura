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

**Yuz tekshiruvi ketayotganda ekran band** (2026-09-09). Yuklanish paytida ofertani qayta ochish mumkin edi va javob kelganda sahifaning `context.pop(verified)` i eng ustdagi marshrutni — ya'ni **ochiq turgan oferta oynasini** — yopardi. Tasdiqlangan mijoz shu bilan yo'qolib, oqim to'xtab qolardi (mijozlar va `client_verify` ekranlarida bir xil).

Qoida bloc'da: `isLoading` bo'lsa `OfferAccepted` ham, `CaptureRequested` ham e'tiborsiz qoladi; `PhotoCaptured` va `CheckRetried` esa `droppable` — ikkinchi surat birinchisining ustidan tushmaydi. Tugmaning rangi emas, qoida ushlab turadi (6.7). Sahifalar ham oyna ochmaydi, lekin bu ikkinchi qatlam.

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

**Ochiq qolgani:** avto-to'lov.

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

**Kartani tasdiqlash (ELMA OTP) — tugadi** (2026-09-09). Status 24/25 bosilganda ochiladi; ilgari «SMS tasdiqlash hali ulanmagan» toasti chiqardi. `GET get_sms_for_card_confirmation/{id}` bosqichni aytadi, `POST give_sms_code_to_elma` esa amalni yuboradi.

Bosqich va amal ikkita alohida enum: `CardConfirmStep` (server nima kutyapti) va `CardConfirmAction` (`state` bo'lib ketadigan `1/2/3/4`). Flex'da bular bir xil satr edi va ekranda to'rt joyda solishtirilardi. Noma'lum `state` OTP deb qabul qilinadi — ELMA yangi kod qo'shishi mumkin.

**Flex nuqsonlari takrorlanmadi:** `getSmsConfirmation` xatoni yutib bo'sh model qaytarardi va ekran raqamsiz, hisoblagichsiz OTP oynasini chizardi — xodim kod kutardi, kod esa umuman yuborilmagan (v3 da `ParseFailure`); `DateTime.parse` buzuq sanada istisno otardi (`tryParse` + hisoblagichsiz ko'rinish); `int.parse(date.substring(0, 2))` noto'g'ri kiritilgan muddatda yiqilardi (`CardEntry.month/year`); `future.data!` (v3 da `!` yo'q); servis to'g'ridan-to'g'ri widgetdan chaqirilardi (`FutureBuilder`); toast data qatlamidan otilardi.

`card_owner_mismatch` bosqichdan **qat'i nazar** aniqlanadi — ELMA uni `"2"` bilan ham, `"4"` bilan ham yuboradi. U holatda OTP maydoni ham, «Tasdiqlash» ham chizilmaydi: yagona yo'l shartnomani bekor qilish, u esa amallar oynasida (tasdiq dialogi va xato yuzasi bir joyda tursin).

**OTP maydoni oddiy kiritish maydoni** — `pinput` qo'shilmadi. Webview va imzo kutubxonasi kabi, bitta ekran uchun yangi bog'liqlik olinmadi.

**Shartnoma faylini ulashish** (2026-09-09). `ContractDetailsPage` ning **pastida qotib turadigan panel** (`ContractFileBar`): «Faylni ochish» va «Ulashish». Ilgari ular ro'yxatning ichida, tovarlar/kafillar/karta bo'limlaridan keyin turardi — uzun shartnomada ekranning eng pastiga tushib ketib, topilmasdi. Fayl yo'q bo'lsa panel o'rniga sabab yoziladi (5.8) — avval u umuman chizilmasdi. Ulashishda fayl vaqtinchalik papkaga yuklab olinadi va tizim ulashish oynasi ochiladi.

Yagona yangi bog'liqlik — **`share_plus`**. Webview, imzo kutubxonasi va `pinput` dan farqli, bunga muqobil yo'q: ulashish oynasi platformaniki. `path_provider` esa **olinmadi** — `Directory.systemTemp` `dart:io` da bor va vaqtinchalik fayl uchun yetarli.

Fayl imzolangan S3 havolasidan olinadi, shuning uchun `UploadClient` ning interceptorsiz `Dio` si ishlatiladi — bizning `Authorization` sarlavhamiz imzoni buzardi. Bo'sh havola ham, bo'sh fayl ham xato: ulashish oynasi ochilib, qabul qiluvchiga ochilmaydigan hujjat ketardi (5.8).

Ulashish oynasini **sahifa** ochadi, bloc emas (6.2): bloc faqat faylni tayyorlaydi va holatga qo'yadi, sahifa oynani ochib darhol `FileShared` bilan tozalaydi — aks holda ekran qayta qurilganda oyna ikkinchi marta ochilardi.

Yo'lda tuzatildi: «Shartnoma faylini ochish» `launchUrl` natijasini tekshirmasdi — ochadigan ilova bo'lmasa bosish jimgina yo'qolardi.

**Imzolangan shartnoma (status 10) bosilganda faqat ko'rish ekrani ochiladi** — flex'da u amal oynasiga tushardi va xodim «Batafsil» ni qidirishga majbur bo'lardi. Tahrirlash baribir mumkin emas (`_editStatuses` da yo'q).

**Imzolash — tugadi** (2026-09-09, 8-bosqich). `features/contracts/` da: `ContractSigning` + `SigningParticipant` (domain), `ContractSigningRepository`, uchta usecase, datasource, bloc va `ContractSigningPage`. Amal oynasidagi «Imzolash» endi shu ekranni ochadi (ilgari toast chiqarardi), `ContractTapText.signing` o'chirildi.

**Mijoz va kafil bitta tipda.** Flex'da holat ikkita alohida joyda turardi (`isClientSigned` + `guarantors` ro'yxati) va har bir tekshiruv ikki tarmoqqa bo'linardi — yangi maydon qo'shilganda ikki joyda yozish kerak edi. v3 da ikkalasi `SigningParticipant`, farq faqat qaysi endpointga borishida (`sign_client_contract` / `sign_guarantor_contract`).

**Navbat yo'q.** Imzolash uchun yagona shart — ishtirokchining o'z yuzi tasdiqlangani (`canSign`). Kafil mijozdan oldin imzolashi mumkin. Shartnoma matni esa bitta va u hamma uchun bir marta o'qiladi.

**Yakunlanishning ikkita manbai.** Server `sign_*_contract` da HTTP **201** bilan "to'liq imzolandi" deydi, lekin buni har doim qilishi tasdiqlanmagan (12-savol). Shuning uchun ekran `isAllSigned` ni o'zi ham hisoblaydi. Bo'sh ishtirokchilar ro'yxati "hammasi imzolangan" deb qabul qilinmaydi — u o'qishdagi nosozlik belgisi.

**Webview qo'shilmadi.** Flex shartnoma matnini `webview_flutter` da ochadi. v3 da bu bog'liqlik yo'q va oferta oynasi allaqachon `HtmlWidget` bilan ishlaydi — shu qolip ishlatildi (`buildAsync: false` bilan, sabab yuqorida). Oxirigacha o'qilgani `ScrollController` orqali aniqlanadi, matn ekranga sig'ib qolsa ham (aks holda tugma abadiy o'chiq qolardi).

**Yuz kamerasi qayta ishlatildi.** `Routes.faceCamera` marshrut bo'lib `File` qaytaradi va 720px ga siqib beradi, shuning uchun `contracts` `customers` ni import qilmaydi (1.3).

**Flex nuqsonlari takrorlanmadi:** yiqilgan yuz tasdig'idan keyin holatning baribir o'zgarishi; imzo havolasi bo'sh kelganda ham "imzolangan" deb ko'rsatilishi (v3 da `ParseFailure`); bitta «Qayta urinish» ning yiqilgan amaldan boshqasini bajarishi (v3 da `_Attempt`: file / face / signature); `Future.delayed(1200ms)` bilan sun'iy kutish; muvaffaqiyat toastining data qatlamidan otilishi.

**Imzo alohida ekranda chiziladi** (`SignaturePage`). Ro'yxat ichida vertikal harakat uchun ikkita da'vogar bo'lardi — pad'ning `PanGestureRecognizer` i va `ListView` ning vertikal drag'i — va qaysi biri yutishi barmoqning tikligiga bog'liq edi: bazida chizish o'rniga ro'yxat surilardi. Sozlash bilan emas, **tuzilma bilan** hal qilindi: imzo ekranida scroll umuman yo'q.

Yon foyda: maydon 160px lik tasmadan ~500px ga o'sdi va ishtirokchi qatori yengillashdi — u endi faqat holat ko'rsatadi. Izoh ham o'sha ekranda yoziladi va imzo bilan birga `SignatureSubmitted` da keladi; bloc'dagi `comment` maydoni olib tashlandi (u ekranga chiqmaydigan holat bo'lib qolardi).

`signature_page_test.dart` tuzilmani qulflaydi: pad'ning `Scrollable` ota-onasi bo'lmasligi, maydon balandligi 300px dan katta bo'lishi va ishtirokchi qatorida chizish maydoni **bo'lmasligi**.

**Shartnoma matnini o'qish sharti — yuz qadamida, imzoda emas.** Rozilik yuz so'rovi bilan birga ketadi (`accepted_oferta: true`), shuning uchun matn aynan shundan oldin o'qiladi. Imzolash uchun qayta o'qish talab qilinmaydi: ekran yopilib qayta ochilsa ham, yuzi tasdiqlangan ishtirokchi to'g'ridan-to'g'ri imzolaydi.

**Klaviatura izoh maydonini yopmaydi** — `resizeToAvoidBottomInset` o'chirilmaydi. Maydon vaqtincha kichrayadi, lekin **eksport nuqtalarning haqiqiy chegarasi bo'yicha** bajariladi (`_canvasFor`): faqat joriy o'lchamga tayansak, klaviatura ochiq holda yuborilgan imzoning pasti kesilib qolardi. Testi sinab ko'rilgan — `box.size` ga qaytarilsa yiqiladi.

**Imzo maydonining `shouldRepaint` tuzog'i.** Nuqtalar ro'yxati joyida o'zgartiriladi, ya'ni `oldDelegate.points` bilan `points` — **bitta obyekt**. Uzunlikni ham, mazmunni ham solishtirish doim "o'zgarmadi" deb javob beradi va imzo ekranda ko'rinmaydi (birinchi chiziq ko'rinadi, chunki ko'rsatma matni yo'qolib daraxt baribir o'zgaradi — aynan shu narsa xatoni yashiradi). `shouldRepaint => true`.

Testi (`signature_pad_test.dart`) shuni **ikkinchi** chiziq bilan qulflaydi: birinchisi daraxt o'zgargani uchun baribir chiziladi. Ekrandagi qora piksellar `RepaintBoundary.toImage()` bilan sanaladi — `export()` bilan tekshirish yaramaydi, u yangi painter yaratadi va xato bo'lsa ham ishlayveradi. Sinab ko'rilgan: eski `shouldRepaint` qaytarilsa test yiqiladi.

**Eslatma:** `ui.Image.toByteData()` widget testda `tester.runAsync` ichida bo'lishi shart — aks holda test qotib qoladi (xato bermaydi, shunchaki tugamaydi).

**Ochiq qolgani — mijoz hujjati rasmi (DEV-4714).** Flex'da passport old/orqa tomonini suratga olib `contract/client-document` ga yuborish bor, lekin flex kodining o'zida "Backend tayyor bo'lgach faqat shu qator va payload tekshiriladi" deb turibdi. Endpoint tasdiqlanmagani uchun v3 ga kiritilmadi — taxminiy manzil jimgina yiqiladigan yo'l yaratardi.

**Shartnoma kartasi Figma tuzilishiga o'tkazildi** (2026-09-12). Yuqorida avatar + «Mijozning F.I.O si:» yorlig'i va ism, ostida chiziq bilan ajratilgan «yorliq — qiymat» qatorlari: Shartnoma kodi, Sanasi, Status. Ilgari ma'lumot ixcham joylashtirilgan edi va qaysi raqam nima ekanini bilish uchun kartani o'qib chiqish kerak bo'lardi.

Maketda yo'q, lekin **saqlangan** narsalar: KATM/imtiyoz chegara rangi (xodim ro'yxatdan aynan shu ikki holatni izlaydi), kafillar soni, Flex belgisi, `ContractApprovalNote`. Ular endi alohida chip emas, o'sha jadval qatorlari — va faqat ma'lumot bo'lganda chiqadi (bo'sh «0 kafil» qatori kartani uzaytirib, hech nima aytmasdi).

Status chipi kattalashdi (Figma'dagidek to'ldirilgan fon, chegarasiz).

**Kartada birorta matn kesilmaydi.** Dastlab qatorda yorliq `Expanded` bilan butun bo'sh joyni olardi va uzun status nomi («Shartnoma tasdiqlangan») uch nuqta bilan tugardi — xodim shartnomaning holatini o'qiy olmasdi. Endi qator `Wrap`: sig'sa bir qatorda chetlarga tarqaladi, sig'masa qiymat o'z qatoriga tushadi. Mijoz ismidagi `maxLines: 2` ham olib tashlandi — kesilgan ism mijozni tanishga xalaqit beradi.

`contract_card_fit_test.dart` to'rtta holatda (393/360px × 1.0/1.3 shrift) `didExceedMaxLines` bayrog'ini sanaydi va u nol bo'lishi kerak.

**Olinmagan narsalar va sabablari:**

- **Shartnomalar sarlavhasiga «ISHONCH» logotipi** — maketda u har ikkala tabda markazda turadi. Olinmadi: 48px lik qatorda menyu (44) + logotip (~120) + faol filtr chipi (~90) + kalendar (44) sig'maydi va filtr yoqilganda toshardi. Ekran nomi ham yo'qolardi. Mijozlar tabida logotip allaqachon markazda — u maketga mos.
- **Maketdagi bo'sh menyu** — o'rta qismi butunlay bo'sh, bo'limlar chizilmagan.
- **Ikonkasiz bo'sh holatlar** — maketda faqat kulrang matn; bizdagi ikonka + sarlavha + yo'l-yo'riq foydaliroq.
- **Past kontrastli kulrang matn** — yuqoridagi ochiq savolga qarang.

Maket xato, yuklanish va ruxsat holatlarini umuman chizmaydi — ular ilovada qoladi.

**Ranglar Figma palitrasiga o'tkazildi** (2026-09-12). Manba: Cover → `Colors` (ramplar 25…900) va `Colors 2` (semantik: Primary / Success / Error / Warning / Info / Background).

| Token | Edi | Bo'ldi | Figma nomi |
|---|---|---|---|
| `primary` | #00BB31 | **#18B83C** | Primary (yashil 700) |
| `green` | #00B329 | **#01B329** | Success (yashil 800) |
| `yellow` | #FF9800 | **#E7BD06** | Warning (sariq 800) |
| `grey` | #798179 | **#888888** | kulrang 600 |
| `grey1` | #CCD5CD | **#D3D3D3** | kulrang 300 |
| `textBlack` | #131313 | **#111111** | kulrang 900 |
| `backcolor` | #F1F2F6 | **#F4F3F9** | Background / Primary |
| `btnBackcolor` | #F1F2F6 | **#F1F1F1** | kulrang 100 |
| `stroke` | #E5E5E5 | **#E2E2E2** | kulrang 200 |
| `primarySoft` | #01C000 | **#4DCA69** | yashil 600 (gradiyent juftligi) |

`blue`, `red`, `black`, `blackSoft`, `white`, `background` allaqachon mos edi. Eski kulranglar **yashilga moyil** edi (#798179, #CCD5CD) — Figma'niki sof neytral.

**`secondary` ataylab o'zgartirilmadi.** Figma'dagi «Secondary» — oq (brend juftligi), ilovadagi `secondary` esa ekrandagi ikkinchi darajali ko'k urg'u. Rol boshqa, qiymat esa Figma'ning «Info» rangi bilan bir xil.

**Sakkizta rang tokeni o'chirildi** — `redSoft`, `greenSoft`, `lineColor`, `iconColor`, `chartColor1…4`. Hech qayerda ishlatilmasdi (15.3). `redSoft` ayniqsa chalg'ituvchi edi: nomi qizil, qiymati esa fon rangi (#F4F3F9).

**Ochiq savol — kulrang matnning kontrasti.** Figma'ning kulrang 600 (#888888) oq fonda **3.54:1** beradi, WCAG AA oddiy matn uchun 4.5:1 talab qiladi (eski #798179 — 4.02:1, u ham past edi). `colors.grey` 77 joyda ishlatiladi, shundan ~14 tasi matn. Uch yo'l: (1) shundayligicha qoldirish; (2) matn joylarini `textGraySoft` ga (#737373 ≈ 4.74:1) o'tkazish; (3) matn uchun Figma'ning kulrang 700 (#4D4D4D, 8.45:1) ni ishlatish. Qaror kutilmoqda.

**Qorong'i mavzu Figma'da yo'q.** `DarkModeColor` eski qiymatlarda qoldi va u hozir ishga tushmaydi (`themeMode = ThemeMode.light`).

**Tipografiya Figma shkalasiga o'tkazildi** (2026-09-12). Manba: Figma fayli `movJ59yMoLg3BGyLOcHaWD` → Cover → `Typography` freymi (`2295:10101`) va uchta tayyor ekrandagi haqiqiy ishlatilish (Drawer, Mijozlar, Shartnomalar).

Figma'da e'lon qilingan (published) matn uslublari **yo'q** — shkala `Typography` freymidan va ekranlardagi tugunlardan yig'ildi. Dizayn ishlatadigan o'lchamlar: **24 / 20 / 16 / 15 / 14 / 13**, og'irliklar **400 / 500 / 600 / 700**.

| Token | Edi | Bo'ldi |
|---|---|---|
| `display` | 18 (700/500/400) | **20** (700/600/400) |
| `headline` | 15 (700/500/400) | **16** (600/500/400) |
| `title` | 14 (700/500/400) | **15** (600/500/400) |
| `body` | 12 (700/500/400) | **14** (600/500/400) |
| `label` | 10 (700/500/400) | **13** (600/500/400) |

Ya'ni butun ilova dizayndan **1–3px kichik** chizilardi. Og'irlik ham to'g'rilandi: dizayn urg'u uchun **600** ni ishlatadi (uchta ekranda 26 marta), mavzuda esa 600 umuman yo'q edi va 500 dan to'g'ri 700 ga sakrardi. Qator balandligi qo'shildi (≥20px da 1.4, ≤18px da 1.5) — ilgari u umuman berilmagan edi.

Rollar o'zgarmadi, faqat o'lchamlar — shuning uchun birorta chaqiruv joyi tahrirlanmadi.

**Chetki holat topildi:** yangi shkalada pastki navigatsiya tizim shrifti **1.3×** bo'lganda paneldan toshib ketdi (panel balandligi 80px — dizayn doimiysi). Yozuv `labelSmall` (13px, dizayndagi qiymat) ga o'tkazildi va kattalashuvi 1.1 bilan chegaralandi. `fixed_height_fit_test.dart` to'rtta o'lcham/shkala kombinatsiyasida buni qulflaydi.

Shartnoma tabining toshishi ham o'sdi (o'lchangan): 82→144, 242→347, 319→410, 444→661px. Ekran allaqachon scroll qiladi, shuning uchun bu buzilish emas.

**Shrift oilasi tuzatildi** (2026-09-12). Mavzuda `fontFamily: 'BetaniaPatmos-Regular'` turardi, lekin bu oila `pubspec.yaml` ning `fonts:` bo'limida **umuman e'lon qilinmagan**. Flutter e'lon qilinmagan oilani topa olmaydi va jimgina tizim shriftiga tushadi — ilova Figma shriftida ham, paketga qo'shilgan NotoSans'da ham chizilmasdi va hech qanday xato bermasdi.

Figma `Noto Sans` ishlatadi, u esa allaqachon 9 og'irlik bilan e'lon qilingan → `fontFamily: 'NotoSans'`.

Yo'lda: `assets/fonts/` `assets:` ro'yxatidan olib tashlandi — `fonts:` dagi fayllar paketga o'zi tushadi, papkani `assets:` ga qo'shish ularni **ikkinchi marta** yuklardi. `BetaniaPatmos-Regular.ttf` o'chirildi (hech qayerda ishlatilmasdi).

`app_theme_font_test.dart` shuni qulflaydi: oila `pubspec.yaml` dagi nom bilan bir xil bo'lishi kerak. Sinab ko'rilgan — eski nom qaytarilsa test yiqiladi.

**Matn o'lchamlari hali Figma bilan solishtirilmagan.** Hozirgi shkala: `display` 18 / `headline` 15 / `title` 14 / `body` 12 / `label` 10, har birida 700/500/400. Figma MCP kvotasi tugagani uchun uslublar ro'yxati olinmadi — `2132:12467` («Heading+cardclient») tanlangan holda qolgan.

**Yon menyu (drawer) — tugadi** (2026-09-11). `core/widgets/drawer/`: uni mijozlar va shartnomalar ekranlari ochadi, ya'ni featurega tegishli emas (1.2). Sarlavhada bosh harflar, ism, tashkilot va lavozim; pastda chiqish va versiya.

**Menyu shellning `Scaffold` ida** (`MainPage`), sahifalarnikida emas — shunda u pastki panel ustiga ham chiqadi. Sahifalar uni `AppDrawerScope` orqali ochadi: ularning o'z `Scaffold` i shell ichida turadi va `Scaffold.of(context)` yuqoriga chiqa olmaydi. Global kalit emas — yo'l daraxt orqali beriladi, ya'ni testda almashtiriladi va ikkita shell bo'lsa chalkashmaydi.

**Sarlavha menyuning katta qismini egallaydi**: 72px avatar, yonida lavozim chipi, ostida ism, tashkilot va telefon (ikonkalar bilan). Xodim menyuni ochganda birinchi navbatda kim sifatida kirganini ko'radi.

Flex'dan farqlari: cho'zilib qiyshayadigan fon rasmi **yo'q** (rang mavzudan), rasm o'rniga bosh harflar, lavozim chipi, bo'limlar kartalarda va ikonlar rangli doirada. Chiqishda tasdiq dialogi bor — flex'da bitta bosishda chiqib ketardi.

**Bo'limlar ekranlari hali yozilmagan va bu ko'rinib turadi.** Har biriga «tez orada» belgisi qo'yilgan: bosilgandan **keyin** «ulanmagan» deyish xodimni bekorga bosishga majbur qiladi. Bosilganda toast ham chiqadi — bosish jimgina yo'qolmasin (5.8). «Mijoz tahlili» esa `showPrescoring` huquqi bo'lmasa umuman ko'rinmaydi.

`DrawerTileMark { open, soon, none }` — qator o'ng chetida strelka, «tez orada» belgisi yoki hech nima. Ikkita mantiqiy bayroq o'rniga bitta enum: chiqish tugmasida strelka turishi noto'g'ri edi.

**`AppInfo` (`core/services/`)** — versiya `AppStartup` da bir marta o'qiladi va shu yerda turadi. `PackageInfo` ni mantiq ichida qayta o'qish taqiqlangan (13.4), menyu esa versiyani ko'rsatadi. `SessionStore` va `AppInfo` `splash_page.dart` dagi `MultiProvider` ga qo'shildi — `AuthNotifier` va `OfferDocument` bilan bir xil qolip.

**Chiqim tovarlar — 1-bosqich tugadi** (2026-09-09). `lib/features/outputs/`: `GET output_contracts` ro'yxati (sana filtri, 15 tadan sahifalash, tortib yangilash) va qator ochilganda `GET get_products_for_cancelled/{id}`.

**Sahifa raqami faqat muvaffaqiyatdan keyin oshadi** — aks holda yiqilgan so'rovdan keyin o'sha sahifa butunlay tushib qolardi. **Oxirgi sahifa bayroq bilan** aniqlanadi (server bersa `last_page`, bermasa to'lmagan sahifa): flex bo'sh javob kelguncha sahifani oshiraverardi, ya'ni har doim bitta ortiqcha so'rov yuborardi.

Tovarlar shartnoma bo'yicha saqlanadi — qator ikkinchi marta ochilganda so'rov takrorlanmaydi (ular chiqim berilgunicha o'zgarmaydi). Tovarlar o'qishi yiqilsa qator **yopiladi**: ochiq turgan bo'sh qator «tovar yo'q» degan ma'noni berardi (5.8). Ro'yxat yangilanganda ochiq qator va o'qilgan tovarlar tozalanadi.

`PullRefresh` `core/widgets/states/` ga ko'chdi — endi uni ikkita ro'yxat ishlatadi (1.2).

**Backenddan so'raladi (1-bosqichdan):**

- **`get_products_for_cancelled` dagi `price` — bitta dona narximi yoki qator summasimi?** Aniqlanmaguncha u **ko'paytirilmaydi**: `price * count` deb chiqarish javob boshqacha bo'lsa summani jimgina ikki barobar ko'rsatardi. Flex ham uni o'zgartirmasdan ko'rsatadi.
- **`output_contracts` da `total_price` yoki `count` kelmasa** ekranda `0` ko'rinadi. Zaxira qiymat qo'yilmadi (4.6): `count` ni `1` qilish shartnoma buzilishini qonuniy qiymatga aylantirardi. Nol ko'rinsa — bu nosozlik belgisi.

**Chiqim tovarlar — 2, 3, 4-bosqichlar tugadi** (2026-09-12). Chiqim berish, iCloud talablari va tovar qaytarish qo'shildi; feature to'liq.

`presentation/` **ekran papkalariga** bo'lindi (1.1a): `list/`, `release/`, `requirements/`, `credential/`, `shared/`. To'rtta ekran bo'lgach `bloc/ pages/ widgets/ styles/` bo'linishi bitta ekranni o'zgartirish uchun to'rt papka ochishni talab qilardi.

**Amal shartnoma holatidan kelib chiqadi** (`OutputContract.canRelease`): imzolangan shartnoma — chiqim berish, qolganida — tovar qaytarish. Flex shu ajratishni `statusId == 10` deb qotirib yozgan.

**Chiqim berish oynasi talab tekshiruvidan boshlanadi.** Flex'da tekshiruv ro'yxat bloc'ida turgan va talab bajarilmasa **kutilmaganda** boshqa oynaga sakrardi. Bu yerda oyna ochiladi va uning ichida sabab ko'rinadi: «N ta qurilma uchun iCloud ma'lumotlari kerak» + «To'ldirish».

**Oyna sahifaning ustiga qo'yilmaydi — avval yopiladi.** «To'ldirish» oynani `ReleaseOutcome.requirementsNeeded` bilan yopadi, sahifa talablar oynasini ochadi va qaytilgach chiqim oynasini qaytadan ochadi (yangi oyna talabni qaytadan tekshiradi). Modal oynaning ustiga `go_router` sahifasini qo'yish deklarativ sahifalar ro'yxatini imperativ marshrut bilan aralashtiradi; `contract_action_sheet` ham shu qolipda — avval `pop()`, keyin o'tish.

**Talab o'qilmasa chiqim ochilmaydi.** `is_satisfied` kelmasa **`false`** deb qaraladi (4.6): `true` zaxira qiymati kalit yo'qolganda tekshiruvni jimgina o'chirib qo'yardi. `missing` kelmasa esa `null` — qurilma **ochiq** qoladi; `0` qo'yilsa barcha qurilma «to'ldirilgan» bo'lib ochilmay qolardi.

**Tovar tanlash state'da, entityda emas.** Flex `OutputProducts.selected` ni modelning ichiga qo'ygan — belgilar model qayta o'qilganda yo'qolardi. Belgilar qator almashganda tozalanadi: qolsa, boshqa shartnomaning tovarlari qaytarilib ketardi.

**Qaytarish tasdiq so'raydi.** Flex'da tasdiq dialogi (`output_return.dart`) yozilgan, lekin uni ochadigan hodisa **hech qayerdan yuborilmagan** (`showReturn` hech qachon `true` bo'lmaydi) va `successPress: (){}` bo'sh — ya'ni flex tovarlarni tasdiqsiz qaytaradi. Bundan tashqari flex'da qaytarish yiqilsa **hech nima ko'rsatilmaydi** (`(failure) => emit(state.copyWith(loading: false))`).

**Bo'sh tanlov bilan so'rov yuborilmaydi** (`ReturnProductsUsecase`): u shartnomani o'zgartirmaydi, lekin javobi muvaffaqiyat bo'lgani uchun ekran «qaytarildi» deb ko'rsatardi (5.8).

**Chiqim ham, qaytarish ham `ContractChanges.updated` ni belgilaydi** — ikkalasi shartnoma holatini o'zgartiradi va shartnomalar ro'yxati eskiradi.

**Surat siqilmaydi, kameraning o'zida chegaralanadi** (`maxWidth/maxHeight 1600`, `imageQuality 70`) — `product_picker_page` bilan bir xil qolip. Flex kamerani xuddi shu sozlama bilan ochib, keyin yana `compressTo1mb` chaqiradi: ikkinchi siqish deyarli har doim ortiqcha.

**Hisoblagich tugmani to'smaydi.** U `updated_at + 5 daqiqa` dan sanaydi va faqat xabar beradi: server vaqti bilan qurilma vaqti farq qilishi mumkin, va shu farq tufayli kelgan kodni kiritib bo'lmay qolishi kerak emas. Sana o'qilmasa hisoblagich umuman chizilmaydi. `updated_at` `toLocal()` bilan o'qiladi — server `Z` bilan yuborsa ayirma mintaqa qadar noto'g'ri chiqardi.

**Apple ID egasi — domainda `AppleIdOwner` enum, serverdagi yozuv (`OZINIKI` / `Личный`) faqat DTO'da** (3.1). Ekranda ham aynan shu ikki qator ko'rsatiladi: ular server kutadigan qiymat va xodim ularni flex'dan shunday biladi, tarjima qilinsa qaysi biri tanlanganini aniqlab bo'lmay qolardi.

**Forma xatosi maydon tagida** (7.5). Flex butun forma uchun bitta «Ma'lumotlarni to'ldiring» toastini chiqarardi — qaysi maydon ekani aytilmasdi.

**IMEI serverda bo'lsa forma uni o'zgartirtirmaydi** — raqam yorliqdan o'qilgan, qo'lda qayta yozish xato kiritishning yo'li. IMEI2 majburiy emas: bitta SIM'li qurilmada u umuman bo'lmaydi.

**Backenddan so'raladi (2-4 bosqichdan):**

- **`icloud_phone` qaysi shaklda kutiladi?** Flex maskaning o'zini yuboradi (`(90) 123-45-67`), bu yerda esa ilovaning qolgan qismi bilan bir xil — faqat raqamlar (`998901234567`). Server matnni saqlasa ikkalasi ham ishlaydi; formatni tekshirsa aniqlashtirish kerak.
- **`apple_id_login` / `apple_id_password` dagi `OZINIKI` va `Личный` nimani anglatadi?** Ikkalasi ham «o'ziniki» degan ma'noni beradi, faqat ikki xil tilda. Ro'yxat flex'dan o'zgarmasdan ko'chirildi.
- **Qisman qaytarishda shartnoma bekor bo'ladimi?** `PUT product_returned` faqat `product_ids` ni oladi; flex'ning (ishlatilmaydigan) dialogi «Shartnomani bekor qilish» deb yozilgan. Tasdiq matni shuning uchun faqat tovarlar haqida gapiradi.
- **`sms_confirm` kodi harf bo'lishi mumkinmi?** Flex `Pinput` ni `TextInputType.text` bilan ochadi, shuning uchun maydon raqam bilan cheklanmadi — uzunligi 5 ta belgi.

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

Bosiladi, lekin hech nima qilmaydi — foydalanuvchi uchun bu jimgina yiqilish. 2026-09-11 holatiga **birorta ham yo'q**: menyu tugmasi ulandi.

Menyu ichidagi to'rt bo'lim (mijoz tahlili, kredit kalkulyator, parol o'zgartirish, yordam) hali ekransiz, lekin ular «tez orada» belgisi bilan turadi va bosilganda holatini aytadi — ya'ni jimgina emas.

Ochiq, lekin holatini aytadigan to'rt joy qoldi (`ContractTapText`): daromad turini tanlash, SMS tasdiqlash, imzolash va markazdagi anderrayter plitkasi.

Oldingi A ro'yxatidagilar — `cache_data.dart`, `debugPrint`, `workpalce` imlosi, `FirebaseService` singletoni, face_id natijasi, mijoz amallari, shartnoma tafsiloti, `pressContract`, shartnoma amallari va tahrirlash — **yopilgan**. 2026-09-09 da yana ikkitasi yopildi: bildirishnoma bosilganda "Yuklanmalar" papkasining ochilishi va kafil qidiruvidagi bo'sh ekran (nima yozish kerakligi aytilmasdi).

*A2 — backenddan javob kutayotganlar*

5. **`is_edit` har doim `true` ketadi.** Flex'da map literalida kalit ikki marta yozilgan va oxirgisi shartsiz `true` edi — ya'ni yangi mijozda ham `true` ketgan. v3 shu xatti-harakatni saqlaydi: backend `false` yo'lida sinalmagan. **So'ralishi kerak:** `is_edit` nima uchun kerak va yangi mijozda `false` bo'lishi kerakmi?
6. **`data:image/png;base64,`** — yuz suratida yuborilayotgan baytlar JPEG. Prefiks o'qiladimi? (IMEI so'rovida prefiks `image/jpg` — u baytlarga mos.)
7. **`client-search` `page: 1` da qotgan.** Flex sahifalash qilardi; 30 tadan ko'p natija jimgina kesiladi.
8. **Skoring DTO'sida 13 ta qat'iy tip.** Flex hammasiga zaxira qiymat qo'ygan. Bitta maydon kelmasa `ParseFailure` chiqadi va botga aynan qaysi maydon ekani yoziladi — shundan keyin aniq hal qilinadi.
9. ~~**Push xabarida `contract_id` dan boshqa maydon bormi?**~~ **Hal qilindi (2026-09-09):** faqat `message` va `contract_id`. Hozirgi kod to'g'ri — bosilganda ro'yxat yuklanadi, shartnoma topiladi va statusiga qarab kerakli ekran ochiladi.
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
| 8 | Imzolash — **tugadi** | `onSigningRequested` |
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

**Fakturalar tugadi** (2026-09-12). `lib/features/invoices/`: `GET invoices` ro'yxati (sana filtri, sahifalash, tortib yangilash), karta bosilganda amallar oynasi — faylni ochish va yuk xatini ta'minotchiga yuborish (`POST waybills/{id}/send-to-partner`).

Bitta ekran bo'lgani uchun `presentation/` qatlam papkalarida qoldi (1.1a chegarasi oshmagan).

**Fayl tashqi ilovada ochiladi.** Flex `syncfusion_flutter_pdfviewer` bilan ilova ichida ko'rsatadi; v3 da bu kutubxona yo'q va faqat shuning uchun qo'shish ortiqcha — `url_launcher` allaqachon bor. Natija tekshiriladi: ochadigan ilova bo'lmasa sabab aytiladi (5.8).

**Ichma-ich obyektlar himoyalangan.** Flex `json['status']['id']` deb o'qiydi — `status` kelmasa **butun ro'yxat** parse paytida yiqilib, ekran «Ma'lumot topilmadi» deb turib qolardi. Bu yerda `_nested()` orqali o'qiladi va yozuv `unknown` holat bilan qoladi.

**Fayli yoki yuk xati yozuvi yo'q faktura amali o'chiq turadi** va sababi oyna tepasida yoziladi. Yozuvsiz `POST waybills/0/send-to-partner` serverda rad etilib, xodimga umumiy xato ko'rinardi.

**Yuborish aylanishi aynan bosilgan kartada.** State'da bayroq emas, `sendingId` turadi: umumiy bayroq butun ro'yxatni aylantirib yuborardi.

**Backenddan so'raladi:**

- **`invoices` `per_page` ni qabul qiladimi?** Flex'da u **izohga olingan** (`// "per_page": 15`), ya'ni sahifa hajmi noma'lum. Bu yerda `output_contracts` bilan bir xil 15 yuboriladi va oxirgi sahifa server bergan `last_page` yoki to'lmagan sahifa bo'yicha aniqlanadi. Server `per_page` ni e'tiborsiz qoldirsa ortiqcha bitta so'rov ketadi (flex'dagi holat).
- **`invoices` javobidagi `file_url` / `file` / `document` nima?** Flex uni modelga o'qiydi, lekin **hech qayerda ishlatmaydi** — ko'rish uchun `waybill_url` ochiladi. Shuning uchun entityga qo'shilmadi.

**Yo'l-yo'lakay topilgan va tuzatilgan nuqsonlar (2026-09-12):**

- **`MainButton` uzun yozuvda toshib ketardi.** Ikonkali tugmada `Row` ning yozuvi `Flexible` emas edi, tugmaning balandligi esa qat'iy — ikkinchi qatorga tushgan yozuv ichida kesilib, jimgina ko'rinmay qolardi (5.8). Endi `constraints: minHeight` va `Flexible` + `textAlign.center`. Bu **butun ilovaning** tugmalariga tegadi.
- **Chiqim kartasida summa va holat bir qatorda edi** — uzun holat nomi qatordan toshib ketardi, summa esa uch nuqtaga aylanardi. Shartnoma kartasidagi yechim qo'yildi: `Wrap(spaceBetween)`, `maxLines` olib tashlandi. Tovar qatorida ham narx nom bilan yonma-yon turardi — endi u nom ostida, alohida qatorda.
- Ikkalasini `output_card_fit_test.dart` qulflaydi: 393/360 px × 1.0/1.3 shrift — toshish ham, kesilgan matn ham nolga teng bo'lishi shart. Faktura kartasi uchun ham xuddi shunday (`invoice_card_fit_test.dart`).
- **Chiqim tovarlar bo'limida menyu tugmasi yo'q edi** — ya'ni o'sha bo'limdan menyuni umuman ochib bo'lmasdi. Uchta ro'yxat sarlavhasi deyarli bir xil bo'lgani uchun ular `core/widgets/headers/date_filter_header.dart` ga birlashtirildi (1.2) va tugma o'z-o'zidan hamma joyda paydo bo'ldi.
- Shu bilan birga `core/` ga chiqarildi: `PagedResponse.isLast` (ikkita ro'yxat), `ListSkeleton` (ikkita ro'yxat), `LabeledRow` (shartnoma va faktura kartalari — «hamma matn sig'sin» qoidasi endi bitta joyda), `ExternalFile.open` (shartnoma tafsiloti va fakturalar; `launchUrl` ning platforma istisnosi ham shu yerda ushlanadi).

## Qoidalar auditi — 73 ta topilma (2026-09-12)

Butun kod CLAUDE.md ning har bir bo'limi bo'yicha 12 yo'nalishda tekshirildi, har bir topilma alohida agent tomonidan **rad etishga urinib** tasdiqlandi (128 agent). Natija: **53 buzilish, 16 shubha, 4 ma'lumot**.

### Shu turda tuzatilgani

1. **KATM xavf bayroqlari** (`katm_report_dto`, `credit_report_dto`) — `?? false` qora ro'yxatdagi mijozni «toza» qilib ko'rsatishi mumkin edi. Endi: kalit **umuman kelmasa** «yo'q» (backend salbiy bayroqni yubormasligi mumkin), lekin kalit kelib tipi `bool` bo'lmasa — `FormatException`, ya'ni ekranda xato va botda xabar. Zaxira qiymat xavfli tomonga yiqilmaydi.
2. **`statusCode` endi `int?`** (`contract_details_dto`). `?? 0` bo'lganda `0 != draftStatus` chiqib, **yangi shartnoma `POST` o'rniga `PUT` bilan** yuborilardi. `null` esa blocdagi `?? draftStatus` himoyasini haqiqatan ishga soladi.
3. **Bonus `contract_id` siz yasalmaydi.** `?? 0` bo'lsa menejer qarori 0-shartnomaga ketardi.
4. **S3 yuklash klientiga xato interceptori qo'shildi.** `guard` har qanday `DioException` ni «interceptor ko'rdi» deb hisoblardi, lekin `UploadClient` da interceptor yo'q edi — ya'ni fayl yuklashdagi **barcha nosozlik botga umuman yetib bormasdi** (§5.7).
5. **Chiqim qaytarishda «Qayta urinish» jimgina hech nima qilmasdi**: qator yopilsa banner qolib, `_returnRequested` darhol qaytardi. Endi qator yopilganda xato ham tozalanadi, takrorlab bo'lmaydigan holat esa sabab bilan aytiladi.
6. `address_local_datasource` dagi `try/catch` (yuqoridagi 2-bandga qarang).

### Qolgan 67 ta topilma

Dalillari va tuzatish yo'llari to'liq holda audit natijasida. Guruhlab olganda:

- **§3.9 — domain foydalanuvchi matnini to'qiydi** (5 ta usecase: `card_confirm`, `signing`, `release`, `icloud`, `invoices`). Eng yomoni: `CardConfirmText.issue` presentationda **tayyor turadi, lekin hech qayerdan chaqirilmaydi** — ya'ni to'g'ri qatlamdagi nusxa o'lik kod, foydalanuvchiga esa domaindagi matn chiqadi. Ikki nusxa allaqachon farq qilib ketgan (`signing_usecases` da «Avval yuzni tasdiqlash kerak», `signing_text.dart` da «Imzolashdan oldin yuzni tasdiqlang»).
- **§15.3 — o'lik kod va ulanmagan mexanizmlar** (~20 ta): `logout` zanjiri to'liq yozilgan lekin chaqirilmaydi; `routes.dart` da 9 ta marshrut hech qayerda ishlatilmaydi; **shartnomalar ro'yxatida sahifalash ulanmagan** (`page` serverga ketadi, lekin hech qachon oshmaydi); `ScreenSize` da 360 o'lchamdan 266 tasi ishlatilmaydi; 16 ta ishlatilmaydigan ikonka.
- **§6.6 — o'tgan zamonda bo'lmagan event nomlari** (4 ta): `RegistrationSendData`, `ContractsGet`, `ContractsStale`, `ShowSearch`, `CatalogNextPage`.
- **§1.2 — `core/` da bitta feature ishlatadigan fayllar**: `paged.dart`, `paged_pick_sheet.dart`, `info_tile.dart`, `validator/rules.dart`.
- **§12 — `!` operatori** `contract_details_page` da 3 joyda.
- **§5.8 — jimgina yiqilish**: ishga tushish yiqilsa na ekran, na bot; `add_customer` blocidagi xato matni ekranga chiqmaydi; «Tovar yo'q» xatosi ko'rinmaydi.
- **§6.7 — `MainButton` o'chiq holatni rangdan hisoblaydi** (`color == grey`). Bu men shu sessiyada tegib o'tgan joy: kimdir kulrang tugma bersa u bosilmaydigan bo'lib qoladi.

| Jiddiylik | Qoida | Fayl | Nima |
|---|---|---|---|
| violation | §3.9 | `contracts/domain/usecase/card_confirm_usecases.dart:48` | Domain foydalanuvchi matnini to'qiydi, presentationdagi tayyor nusxasi esa o'lik kod |
| violation | §3.9 | `contracts/domain/usecase/signing_usecases.dart:39` | Imzolash usecase'i uchta xabarni domainda to'qiydi, biri presentationdagi matn bilan zid |
| violation | §3.9 | `outputs/domain/usecase/release_usecases.dart:27` | Chiqim usecase'i xabar matnini domainda yaratadi |
| violation | §4.6 | `contract_create/data/models/special_tariff_dto.dart:17` | Tarif id si `?? 0` — "biriktirilmagan" belgisi bilan to'qnashadi |
| violation | §4.6 | `contract_create/data/models/skip_reason_dto.dart:10` | Sabab id si `?? 0` — forma "tanlanmagan" deb qoladi |
| violation | §4.6 | `contract_create/data/models/catalog_dto.dart:28` | Ma'lumotnoma id si `?? 0` — tanlangan tovar 0 bo'lib yuboriladi |
| violation | §4.2 | `contract_create/data/datasources/special_tariff_remote_datasource.dart:32` | Datasource DTO emas, xom `Map` qaytaradi; parse repositoryda |
| violation | §§5.8 | `core/di/app_init.dart:54` | Ishga tushish yiqilsa ilova jimgina o'ladi: na ekran, na bot |
| violation | §§12 | `contract_create/presentation/details/contract_details_page.dart:152` | `!` operatori ishlatilgan |
| violation | §12 / 15.3 | `auth/registration/presentation/bloc/registration/registration_bloc.dart:47` | Registratsiya arizasi majburiy `partnerId` va `organizationId` ni har doim 0 qilib yuboradi |
| violation | §15.3 | `auth/registration/presentation/bloc/registration/registration_state.dart:28` | `RegistrationState.partners` state'ga yoziladi, lekin hech qayerda ekranga chiqmaydi |
| violation | §6.3 | `customers/presentation/bloc/add_customer/add_customer_bloc.dart:168` | Bloc ichida qo'lda yozilgan xato matni — ustiga u ekranga umuman chiqmaydi |
| violation | §6.6 | `auth/registration/presentation/bloc/registration/registration_event.dart:33` | `RegistrationSendData` eventi o'tgan zamonda emas |
| violation | §6.6 | `contracts/presentation/bloc/contracts/contracts_event.dart:12` | `ContractsGet` va `ContractsStale` eventlari o'tgan zamonda emas |
| violation | §6.6 | `customers/presentation/bloc/customers/customers_event.dart:10` | `ShowSearch` eventi o'tgan zamonda emas va nomi ishiga zid |
| violation | §6.6 | `contract_create/presentation/bloc/catalog/catalog_event.dart:23` | `CatalogNextPage` eventi o'tgan zamonda emas |
| violation | §§15.3 / §5.8 / §11.5 | `contract_create/presentation/products/products_tab.dart:61` | «Tovar yo'q» xatosi hech qachon ekranga chiqmaydi — ProganlarSection.errorText doimiy `null` |
| violation | §§6.7 / §7.2 / §7.5 | `contract_create/presentation/products/product_edit_sheet.dart:57` | ProductEditSheet validatsiyani o'zi hisoblaydi va xato matnini o'zi to'qiydi |
| violation | §§6.10 | `auth/registration/presentation/pages/registration_page.dart:42` | registration_page: `super.initState()` birinchi emas, oxirida chaqirilgan |
| violation | §§12 | `contract_create/presentation/details/contract_details_page.dart:152` | `!` operatori: contract_details_page da tip va'da qilingan |
| violation | §8.2 | `splash/presentation/pages/splash_page.dart:77` | `getIt` splash sahifasida — DI dan tashqarida 6 ta chaqiruv |
| violation | §1.2 | `core/result/paged.dart:8` | `core/result/paged.dart` faqat bitta feature'da ishlatiladi |
| violation | §1.2 | `core/widgets/sheets/paged_pick_sheet.dart:17` | `core/widgets/sheets/paged_pick_sheet.dart` faqat bitta feature'da ishlatiladi |
| violation | §1.2 | `core/widgets/info_tile.dart:9` | `core/widgets/info_tile.dart` faqat `customers` feature'ida ishlatiladi |
| violation | §1.2 | `core/utils/validator/rules.dart:1` | `core/utils/validator/rules.dart` faqat login bloc'ida ishlatiladi |
| violation | §15.3 | `auth/login/domain/repositories/auth_repository.dart:10` | `logout` zanjiri to'liq yozilgan, lekin hech qayerdan chaqirilmaydi — server sessiyani hech qachon yopmaydi |
| violation | §15.3 | `core/router/routes.dart:34` | `routes.dart` da to'qqizta marshrut e'lon qilingan, lekin na `GoRoute` si bor, na kimdir unga o'tadi |
| violation | §15.3 | `core/router/coordinate.dart:1` | `Coordinate` shartnomasi hech narsani majburlamaydi — `implements` bu yerda bo'sh belgi |
| violation | §15.3 | `contract_create/presentation/income/card_section.dart:269` | `cardBlocProvider()` funksiyasi hech qayerdan chaqirilmaydi — uning ishini `contract_tabs.dart` qo'lda takrorlaydi |
| violation | §15.3 | `contract_create/presentation/bloc/contract_create/contract_create_state.dart:65` | `hasUnsavedTerms` hisoblanadi, lekin hech qayerda o'qilmaydi — izoh «foydalanuvchi buni bilishi kerak» deydi, u esa bilmaydi |
| violation | §15.3 | `contract_create/presentation/shared/contract_write_mixin.dart:19` | Oltita ochiq getter/metod hech qayerdan chaqirilmaydi (qaror mantig'i yozilgan, iste'molchisi yo'q) |
| violation | §15.3 | `core/widgets/toasts/custom_animated_toast.dart:60` | `CustomAnimatedToast` da ikkita o'lik ochiq a'zo: `showFromRoutes()` va `key` getter |
| violation | §15.3 | `underwriter/presentation/widgets/document_list.dart:144` | `DocumentHint` widgeti e'lon qilingan, lekin hech qachon qurilmaydi |
| violation | §15.3 | `core/theme/base_colors.dart:30` | `BaseColors` da toast ranglari e'lon qilingan va ikki temada bajarilgan — bittasi ham ishlatilmaydi |
| violation | §§12 (taqiqlar) / §15.3 | `contract_create/presentation/details/contract_details_page.dart:152` | `!` null-assertion operatori ishlatilgan |
| violation | §§11.1 (shartnomalar — `abstract interface class`) | `core/router/coordinate.dart:1` | `Coordinate` shartnomasi `abstract class`, va uning barcha a'zolari o'lik |
| violation | §§11.4 (izohlar o'zbek tilida; nima uchun, nima qilishini emas) | `core/network/endpoints.dart:4` | Bo'lim izohlari ingliz tilida va faqat kodni takrorlaydi |
| violation | §§15.3 (o'lik kod) / §11.4 | `core/widgets/inputs/text_input.dart:180` | Fayl oxirida izohga o'ralgan o'lik kod bloki qolgan |
| violation | §7.5 | `contracts/domain/usecase/card_confirm_usecases.dart:39` | Karta tasdiqlashda kiritish xatosi server xatosi kanalidan o'tadi |
| violation | §15.3 | `contracts/presentation/styles/card_confirm_text.dart:27` | CardConfirmText.issue hech qayerdan chaqirilmaydi — ulanmagan mexanizm |
| violation | §3.9 | `contracts/domain/usecase/card_confirm_usecases.dart:48` | Domain usecase foydalanuvchiga ko'rsatiladigan matn to'qiydi |
| violation | §1.2 | `core/utils/validator/rules.dart:3` | core/utils/validator/rules.dart ni bitta feature ishlatadi |
| violation | §6.7, 12-bo'lim, 15.4 | `core/widgets/buttons/main_button.dart:73` | MainButton o'chiq holatni rangdan hisoblaydi — widget qaror qabul qilyapti |
| violation | §5.8, 15.3 (state'ga yozilib ekranga chiqmaydigan maydon), 9.5 | `test/features/contract_create/presentation/contract_products_bloc_test.dart:161` | ContractProductsBloc xatosi ekranga umuman chiqmaydi — testlar hech kim chaqirmaydigan yo'lni qulflaydi |
| violation | §11.5, 13.4, 15.2 | `test/core/utils/money_test.dart:13` | money_test kasrli summadagi flex xatosini «to'g'ri» deb qulflaydi |
| violation | §15.3 / 5.8 | `contracts/domain/entities/contracts_filter.dart:4` | Shartnomalar ro'yxatida sahifalash mexanizmi ulanmagan: `page` serverga yuboriladi, lekin hech qachon oshmaydi |
| violation | §1.2 | `contracts/presentation/widgets/mib_summary_card.dart:10` | `core/utils/money.dart` bor, lekin 7 ta widget summani o'zi formatlaydi — `Money.withUnit` so'zma-so'z takrorlangan |
| smell | §§5.7 / §5.8 | `core/di/app_startup.dart:39` | `AppStartup` yiqilganda sabab butunlay yo'qoladi: botga xabar yo'q, ekranda «Qayta urinish» yo'q |
| smell | §§5.8 | `core/services/push_token_service.dart:11` | Push token olinmasa bo'sh satr yuboriladi — bildirishnomalar jimgina o'chadi |
| smell | §§5.8 | `core/services/device_info_service.dart:61` | Qurilma ma'lumoti o'qilmasa bo'sh `DeviceInfo` qaytadi va login ekranida bo'sh quti ko'rinadi |
| smell | §15.3 | `contract_create/presentation/shared/contract_write_mixin.dart:57` | `ContractWriteMixin` dagi `forgetLastWrite()` va `lastWrite` hech qayerdan chaqirilmaydi |
| smell | §15.3 | `auth/login/presentation/bloc/login/login_event.dart:21` | `LoginOnChanged` va `PasswordOnChanged` `value` maydonini olib keladi, handler uni o'qimaydi |
| smell | §§8.2 / §14.1 | `splash/presentation/pages/splash_page.dart:77` | splash_page ichida `getIt<>` — `BlocProvider.create` dan tashqarida |
| smell | §15.3 | `contracts/domain/entities/credit_report.dart:17` | Entity maydonlari backenddan parse qilinadi, entityda saqlanadi va hech qayerda o'qilmaydi |
| smell | §15.3 | `core/constants/app_icons.dart:15` | 16 ta `AppIcons` konstantasi ishlatilmaydi; 3 ta asset fayl esa umuman konstantasiz — 17 ta fayl bekorga bundle'ga kiryapti |
| smell | §15.3 | `core/network/endpoints.dart:10` | Ikkita endpoint konstantasi hech qayerdan chaqirilmaydi |
| smell | §15.3 | `contracts/presentation/styles/signing_text.dart:32` | `SigningText.cameraFailed` — hech qayerda ko'rsatilmaydigan xato matni |
| smell | §15.3 | `core/theme/screen_size.dart:376` | `ScreenSize` da 360 ta o'lchamdan 266 tasi hech qayerda ishlatilmaydi |
| smell | §3.9 | `outputs/domain/usecase/icloud_usecases.dart:26` | iCloud usecase Failure ichida foydalanuvchi matnini yozadi |
| smell | §15.4 | `contract_create/presentation/guarantors/guarantor_issue_text.dart:7` | Kafillar chegarasi matnda sehrli raqam bilan yozilgan |
| smell | §15.3 | `core/widgets/inputs/text_input.dart:180` | text_input.dart oxirida flex davridagi o'lik validatsiya bloki |
| smell | §5.8, 4.7 | `outputs/data/datasources/outputs_remote_datasource.dart:46` | PagedResponse'ga o'qilmagan yozuvlar tashlab yuborilgandan keyingi son beriladi — sahifalash erta to'xtaydi |
| smell | §3.9 / 1.2 | `contracts/data/models/contract_info_dto.dart:102` | `createdAt` ikki xil hosil qilinadi: chiqimda DTO uni formatlaydi, shartnomalarda backend satri to'g'ridan-to'g'ri ekranga chiqadi |
| info | §11.5 | `contract_create/presentation/bloc/contract_guarantors/contract_guarantors_bloc.dart:39` | Izoh ikkita qoida deydi, kodda uchta tekshiruv bor |
| info | §15.3 | `core/widgets/states/list_skeleton.dart:16` | `ListSkeleton.height` parametrini hech kim bermaydi — o'lik mexanizm |
| info | §15.3 | `outputs/presentation/credential/credential_text.dart:7` | `CredentialText.saved` konstantasi hech qayerdan chaqirilmaydi |
| info | §15.3 (o'lik kod) | `test/features/underwriter/_fake_underwriter_repository.dart:69` | Test yordamchisida hech qayerda ishlatilmaydigan doimiy |

## Qoidalar bo'yicha to'liq tekshiruv (2026-09-12)

Butun kod CLAUDE.md ga solishtirib chiqildi. Topilgan va **tuzatilgan** kamchiliklar:

**1. Beshta repository `guard()` dan tashqarida qolgan edi — xatolar botga yetib bormasdi (§5.7).**

`contracts`, `contract_create`, `customers` (uchta repo) qo'lda `on DioException / on TypeError / catch (_)` yozib, `ParseFailure` va `UnknownFailure` ni to'g'ridan-to'g'ri qaytarardi. `guard()` esa aynan shu ikki turni `GuardReport.reporter` orqali botga yuboradi. Ya'ni ro'yxatlar, skoring, KATM/MIB hisobotlari va shartnoma tuzish oqimidagi **har qanday parse nosozligi jimgina yo'qolardi** — ekranda umumiy xabar chiqib, sabab hech kimga yetib bormasdi. Endi 19 ta repositoryning hammasi `guard()` orqali.

Buning uchun `result_guard.dart` ga **`GuardFailure`** qo'shildi: repository o'zi biladigan `Failure` ni (masalan server 200 bilan «qoralama yaratilmadi» degani — bu `ClientFailure`, parse xatosi emas) istisno sifatida otadi va `guard` uni o'ramsiz qaytaradi. Bunday `Failure` botga **yuborilmaydi** — u nosozlik emas, kutilgan natija. Usiz o'sha metodlar `guard` dan tashqarida qolishga majbur edi.

**2. `_int` beshta DTO faylida so'zma-so'z takrorlangan (§1.2).** `_digits` ikkitasida, `_text` ikkitasida. `core/utils/json_value.dart` (`JsonValue.toInt/toNullableInt/toText/toDigits`) ga chiqarildi, `test/core/json_value_test.dart` bilan qulflandi. Takrorlangan nusxada bittasi tuzatilsa qolganlari eski holicha qolib ketardi.

**3. `ChuckButton` klass ichida `getIt<Alice>()` chaqirardi (§8.1, §12).** Endi inspektorni ochish amali konstruktordan keladi, bog'liqlik esa `splash_page` da — ilovaning yig'ilish nuqtasida — beriladi.

**4. O'lik kod (§15.3):**
- `splash/presentation/widgets/dot_widget.dart` — hech kim import qilmasdi;
- `auth/login/domain/entities/device_info.dart` — `core/services/device_info_service.dart` uni butunlay almashtirgan, ustiga entityda `fromMap` va majburiy maydonlarga `?? ''` bor edi (§3.1, §4.6);
- `AppManagerInitial.version` — holatga yozilar, lekin **hech qayerda ko'rsatilmasdi**: versiyani menyu `AppInfo` dan oladi. Maydon ham, uni uzatuvchi `AppStartup.prepare()` ning `String` qaytarishi ham olib tashlandi;
- `splash_page` dagi izohga olingan `OverlayEntry` qatorlari.

**5. `MaterialApp.title` hali `'Collaborator Flex'` edi** — flex'dan qolgan nom (§13.4). `'Ishonch Collaborator'` ga almashtirildi.

**6. O'n to'rtta klass `final class` / `abstract final class` emas edi (§11.1)** — `AppTheme` va `ScreenSize` (statik yordamchilar), formatterlar, interceptor, `AppRouter`, `Routes`, `AuthNotifier`, `SecureTokenStorage`, rang palitralari, `MyApp`. Hech biridan meros olinmasligi tekshirilgach o'zgartirildi.

**7. Importlar tartibi** — yuqoridagi alohida bo'limga qarang: `directives_ordering` yoqildi, 76 ta faylda tartibga solindi.

### Tekshirilgan va toza chiqqan joylar

`flutter analyze` (yangi lint bilan), 389 test, §14 ning ikkala grepi, `print`/`debugPrint`, `!` null-assertion operatori, datasource'larda `try/catch` (bittasi — `address_local_datasource` — ataylab va izohlangan), DI qoidalari (§8.3/§8.4), event nomlarining o'tgan zamonda ekani, domain qatlamining tozaligi.

### Qaror talab qilgan to'rt joy — hammasi hal qilindi

**1. Formatterlar endi faqat formatlaydi.** `PhoneFormatter` operator kodini tekshirib **toast chiqarardi**, `CardExpiryFormatter` esa oy oralig'i, muddat o'tgani va juda uzoqqa ketganini tekshirib to'rtta joyda toast chiqarardi. Uchta qoida buzilardi: yordamchi UI ta'sirini bajarmaydi (§6.2), kiritish xatosi maydon tagida ko'rinishi kerak (§7.5), `DateTime.now()` esa mantiq ichida chaqirilmaydi (§9.4).

Endi qoidalar sof Dart yordamchilarda: **`core/utils/uz_phone.dart`** (`UzPhone.isValid` — uzunlik + operator kodi) va **`core/utils/card_expiry.dart`** (`CardExpiry.isUsable` — oy oralig'i, muddat o'tgani, besh yillik chegara; **vaqt tashqaridan beriladi**). Tekshiruv esa entitylarning `issue` qoidalarida: `CustomerForm`, `CardForm`, `CardEntry`, `IcloudCredential`.

Karta muddati vaqtga bog'liq bo'lgani uchun `CardForm.issue` va `CardEntry.issue` getterlari **`issueAt(DateTime now)`** metodiga aylandi; soat `ContractCardBloc` va `SubmitCardConfirmationUsecase` ga kiritildi (`face_id_bloc` dagi qolip bilan bir xil). Shu tufayli muddat o'tgan karta qoidasi **birinchi marta testlanadigan** bo'ldi — ilgari u `DateTime.now()` ga qotirilgan edi.

Xato matnlari ham kengaytirildi: «Raqamni to'liq kiriting» → «Raqamni to'liq va to'g'ri kiriting», chunki endi operator kodi ham shu xatoga kiradi.

**2. `address_local_datasource` endi xom satr qaytaradi.** `jsonDecode` va buzuq keshni tashlash mantig'i repositoryga ko'chdi (`_decode`). Datasource xato ushlamaydi (§4.3), ma'lumot kutilgan shaklda ekanini tekshirish esa repositoryning ishi (§4.7.4). Xatti-harakat o'zgarmadi: buzuq kesh «keshda yo'q» deb qaraladi, yozuv o'chiriladi va serverga boriladi.

**3. `OfferDocument.load` endi `Result<String>` qaytaradi.** `offer_sheet.dart` dagi `try/catch` olib tashlandi — §12 aynan shuni «chaqiruv `Result` tizimidan tashqarida qolgan» belgisi deb ataydi. Endi sabab `guard` orqali botga ham ketadi.

**4. `get<Map<String, dynamic>>` — 45 ta chaqiruvning hammasi o'tkazildi.** Endi hech qayerda tipli javob so'ralmaydi. Kalitlarni o'qish uchun **`JsonParser.field(body, key)`** qo'shildi: u `dynamic` ustidan chaqiruvni ham (`avoid_dynamic_calls`), tipli so'rovning tuzog'ini ham yo'q qiladi. `pagedFrom` va `catalogList` ham `Object?` qabul qiladigan bo'ldi.

Yangi testlar: `test/core/uz_phone`+`phone_test.dart`, `card_expiry_test.dart`, `json_value_test.dart`, `camera_issue_test.dart`. Jami **407 test**.

## Bloc papkalari — butun loyiha bo'yicha (2026-09-12)

Har bir blocning uchligi (`_bloc` / `_event` / `_state`) `presentation/bloc/<nom>/` ichiga yig'ildi. Papka nomi bloc nomidan olinadi (`_bloc`/`_cubit`/`_event`/`_state` qo'shimchasisiz), fayl nomlari o'zgarmadi — shuning uchun `part 'xxx_event.dart'` direktivalari o'z holicha ishlayveradi.

| Feature | `bloc/` ichidagi papkalar |
|---|---|
| `auth/login` | `login` |
| `auth/registration` | `registration` |
| `contract_create` | `catalog` `contract_card` `contract_create` `contract_details` `contract_guarantors` `contract_products` `katm_skip` `manager_bonus` `payment_schedule` `product_picker` `special_tariff` |
| `contracts` | `card_confirm` `contract_action` `contract_result` `contract_signing` `contracts` |
| `customers` | `add_customer` `customers` `face_id` `scoring` |
| `outputs` | `credential` `outputs` `release` `requirements` |
| `invoices` `splash` `underwriter` | bittadan |

**Sahifalar, widgetlar va matnlar tegilmadi** — ular qayerda bo'lsa o'sha yerda qoldi. `contract_create` va `outputs` da ekran papkalari (`create/`, `picker/`, `list/`, `release/` …) saqlanib qoldi, faqat bloc fayllari ulardan chiqib `bloc/` ga o'tdi.

Jami 86 ta bloc fayli ko'chdi.

### Importlar tartibi endi lint bilan qulflandi

Ko'chirishlardan keyin importlar aralashib ketgani ko'rindi: `core/…` fayllari `features/…` orasida, bir xil papkadagilar bir-biridan uzoqda. Sabab — `directives_ordering` linti yoqilmagan edi, shuning uchun `flutter analyze` buni umuman ko'rsatmasdi.

`analysis_options.yaml` ga qo'shildi va `dart fix --apply` bilan **76 ta faylda** tartibga solindi: `dart:` → `package:` → nisbiy, har biri alifbo bo'yicha. Endi tartib buzilsa `analyze` darhol aytadi.

### ⚠️ Bu CLAUDE.md §1.1a bilan ziddiyatda

§1.1a `presentation/` uch-to'rt ekrandan oshganda **ekran papkalari** talab qiladi — har bir ekranning bloci, sahifasi, widgetlari va matnlari bitta joyda. Endi bloc fayllari o'z ekranidan ajratilgan.

Men avval §1.1a bo'yicha qilgandim, buyurtmachi boshqacha xohladi va qaror qabul qilindi. **Natijada kod o'zining qoidalar faylidan chetga chiqdi.** §1.1a shu yangi qolipga moslab qayta yozilishi kerak — aks holda keyingi featureda qaysi qoidaga amal qilish noma'lum bo'lib qoladi.

## iOS da sinash (2026-09-12 da tekshirildi)

**Haqiqiy iPhone'da ishlaydi.** Simulyatorda esa to'g'ridan-to'g'ri **ishlamaydi** — sababi bitta va aniq:

`google_mlkit_face_detection` ning iOS kutubxonalari **arm64 simulyator uchun qurilmagan**. CocoaPods shuning uchun `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64` qo'yadi, natijada faqat `x86_64` binar chiqadi, Apple Silicon + iOS 26 simulyatori esa uni o'rnatishdan bosh tortadi: «This app needs to be updated by the developer». Plaginning eng yangi versiyasi (0.15.1 / MLKitCommon 14.0.0) ham xuddi shunday — **yangilash yordam bermaydi**.

**Bajarilgan tuzatish (kerak va o'rnida qoldirildi):** iOS deployment target `15.0` → **`15.5`** (`google_mlkit_commons` shuni talab qiladi), `ios/Podfile` da `platform :ios, '15.5'` yoqildi. Busiz `pod install` umuman o'tmaydi.

**Simulyatorda sinash retsepti** (vaqtinchalik, keyin albatta qaytariladi):

1. `pubspec.yaml` da `google_mlkit_face_detection` qatorini izohga oling;
2. `lib/features/customers/presentation/camera/face_scanner.dart` ni o'rinbosar bilan almashtiring — `isBusy => false`, `scan(...) async => null`, `close() async {}` (ML Kit importisiz). Simulyatorda kamera baribir yo'q, shuning uchun bu klass chaqirilmaydi;
3. `flutter pub get` → `cd ios && LANG=en_US.UTF-8 pod install` → `flutter build ios --simulator --debug`.

So'ng `lipo -info build/ios/iphonesimulator/Runner.app/Runner` da `arm64` paydo bo'ladi va ilova o'rnatiladi. **Ikkala faylni darhol qaytaring** — ML Kit'siz kod haqiqiy qurilmada yuz tekshiruvini o'chirib qo'yadi.

Shu yo'l bilan ilova simulyatorda ishga tushirildi: splash → asosiy oyna → sessiya eskirgani uchun to'g'ri ravishda login oynasi. Shrift, mavzu, pastki menyu (to'rtta bo'lim, «Fakturalar» ham) joyida.

### iOS auditi topilmalari (2026-09-12, 39 ta agent, 20 ta tasdiqlangan)

**1. `.env` ilova paketi ichiga oddiy fayl bo'lib tushadi — bu maxfiy kalitlarning oshkor bo'lishi.**

`pubspec.yaml:71` da `.env` asset sifatida e'lon qilingan, ya'ni u `.ipa`/`.apk` ichiga **shifrlanmagan holda** qo'shiladi. Arxivni ochgan har kim `BOT_TOKEN`, `BOT_CHAT_ID` va `FIGMA_TOKEN` ni o'qiy oladi. Telegram bot tokeni bilan bot nomidan xabar yuborish va uning yozishmalarini o'qish mumkin.

Qilinishi kerak:

- `FIGMA_TOKEN` ni `.env` dan **olib tashlang** — u faqat ishlab chiqish vositalariga kerak, ilovaga umuman kerak emas. Figma'da uni **bekor qilib, yangisini yarating**: u allaqachon qurilgan paketlar ichiga tushgan.
- `BOT_TOKEN` ni ham ilovadan chiqarish kerak. Eng to'g'risi — xato xabarlarini botga ilova emas, **server** yuborsin. Oraliq yechim sifatida `--dart-define` bilan qurish paytida berish mumkin, lekin u ham binardan topiladi — ya'ni bu faqat vaqtinchalik.
- Token almashtirilgunicha uni oshkor deb hisoblash kerak.

**2. `device_id` qotirib qo'yilgan.** `lib/features/auth/login/data/datasources/auth_remote_datasource.dart:36` da `'device_id': "aa2ad6bb11fcdefd"`, haqiqiy `device.uniqueId` esa 35-qatorda izohga olingan. Natijada barcha o'rnatmalar serverga **bitta qurilma** sifatida kiradi: qurilma bo'yicha sessiya boshqaruvi va push manzillash buziladi. Sinov uchun qotirilgan bo'lsa, qaytarilishi kerak.

**3. iOS'da push umuman ishlamaydi — uch sabab birga.**

- `aps-environment` entitlement yo'q: `ios/Runner/Runner.entitlements` mavjud emas va `project.pbxproj` da `CODE_SIGN_ENTITLEMENTS` **umuman uchramaydi**. Shuning uchun `registerForRemoteNotifications` rad etiladi.
- `firebase_options.dart` dagi `iosBundleId` — `com.example.colloboratorFlex`, ilovaniki esa `com.example.colloboratorV3`.
- `push_token_service.dart:11-13` dagi `catch (_) { return ''; }` xatoni **jimgina yutadi** (5.8) va serverga bo'sh token yuboradi — shuning uchun bu nosozlik hech qachon ko'rinmaydi.

Tuzatish tartibi: bundle ID ni hal qilish → `flutterfire configure` ni qayta ishga tushirish → Xcode'da Runner target → Signing & Capabilities → **Push Notifications** qo'shish (u `.entitlements` ni ham, `CODE_SIGN_ENTITLEMENTS` ni ham o'zi yozadi) → Apple Developer portalida App ID ga push yoqish va APNs kalitini Firebase konsoliga yuklash. `push_token_service` dagi `catch` esa `ErrorReporter` ga ulanishi kerak.

**4. `image_picker` xato kodlari ikki platformada boshqa-boshqa — tuzatildi.** iOS `already_active` emas, `multiple_request` yuboradi; u qamrab olinmagani uchun «oldingi so'rov tugamagan» holati «Kamerani ochib bo'lmadi» degan noto'g'ri xabar bilan chiqardi. `core/utils/camera_issue.dart` ga qo'shildi, `test/core/camera_issue_test.dart` ikkala platformaning kodlarini qulflaydi.

**5. iOS'da kamera yo'q bo'lsa `image_picker` istisno otmaydi.** `FLTImagePickerPlugin.m:321-344` — o'zining «Camera not available» oynasini ko'rsatib, natijani `null` qilib qaytaradi. Ya'ni bizning `CameraIssue` mexanizmi bu yo'lda umuman ishga tushmaydi; sababni plaginning o'zi aytadi. Android'da esa `no_available_camera` istisnosi keladi. Kod noto'g'ri emas, lekin farqni bilib qo'yish kerak.

**Yo'l-yo'lakay chiqqan boshqa to'siqlar:**

- `pod install` ni qo'lda ishga tushirganda `Encoding::CompatibilityError` beradi — `LANG=en_US.UTF-8` qo'yish kerak (`flutter build` buni o'zi qiladi).
- Podsiz qurishdan qolgan artefaktlar `Framework 'Pods_Runner' not found` beradi; `video_player_avfoundation` esa `Malformed or corrupted AST file` beradi. Ikkalasi ham `flutter clean` + `rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*` bilan yo'qoladi.
- `GoogleService-Info.plist` **yo'q, lekin kerak emas**: Firebase `firebase_options.dart` dagi Dart konfiguratsiyasidan ishga tushadi.

**Ochiq savol:** `firebase_options.dart` dagi `iosBundleId` — `com.example.colloboratorFlex`, Xcode'dagi haqiqiy identifikator esa `com.example.colloboratorV3`. Firebase buni ishga tushishda xato deb yozadi va push ro'yxatdan o'tishi buzilishi mumkin. Ikkalasi moslashtirilishi kerak (va ikkalasi ham hali `com.example.` — relizdan oldin haqiqiy identifikatorga o'tkaziladi).

**Simulyatorda ishlamaydigan qismlar** (qurilmada ishlaydi): mijoz yuzini tasdiqlash (kamera + ML Kit), IMEI yorlig'ini suratga olish, chiqim berishdagi tovar surati, push bildirishnomalar. Kodda bularning hammasi sababini aytadigan qilib yozilgan (`CameraStartIssue.notFound`, `CameraIssue.unavailable`), ya'ni jimgina yiqilmaydi.

**Ochiq, tuzatilmagan:**

- **`showAppSheet` klaviaturani hisobga olmaydi.** `card_confirm_sheet` balandligi qat'iy (`.75`) va kod maydoni ochilganda «Tasdiqlash» tugmasi klaviatura ostida qoladi. `release_sheet` da bu mahalliy hal qilindi (`MediaQuery.viewInsetsOf(context).bottom`); `SheetSurface` ga qo'shish qat'iy balandlikdagi oynani siqib qo'yishi mumkin, shuning uchun tegilmadi.

*D — hali boshlanmagan*

9. **Mijoz hujjati rasmi (DEV-4714)** — endpoint (`contract/client-document`) va `side` kaliti backend bilan tasdiqlangach imzolash ekraniga qo'shiladi.
10. **Testlar — ongli ravishda loyiha oxiriga qoldirilgan.** 2026-09-09 holatiga 272 ta. Ular qoida yozilganda birga yozilgan, alohida ish sifatida emas: har biri bitta qarorni qulflaydi (`terms_tab_fit_test`, `underwriter_dto_test`, `guarantor_picker_layout_test`, `contracts_push_test`). Qolgan qamrov featurelar tugagandan keyin. **Eslatilmaydi.**
11. **`get<Map<String, dynamic>>` qolgan 37 joyda** — yuqoridagi "Dio javob tipi" qolipiga o'tkazilishi kerak.

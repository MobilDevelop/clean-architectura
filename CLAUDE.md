# colloborator_v3 — arxitektura qoidalari

KATM/MIB kredit hisoboti mijoz ilovasi. `colloborator_flex` dan Clean Architecture'ga qayta yozilyapti.
Bu hujjat — loyihaning majburiy qoidalari. Yangi kod shu qoidalarga bo'ysunadi, mavjud kod shu qoidalar bo'yicha tekshiriladi.

---

## 1. Tuzilma

```
lib/
├── core/                          # featurelararo umumiy kod
│   ├── constants/  di/  error/  network/  result/  router/
│   ├── services/   theme/  usecase/  utils/  widgets/
└── features/<feature>/
    ├── data/
    │   ├── datasources/           # tarmoq va lokal manbalar
    │   ├── models/                # DTO
    │   └── repositories/          # <X>RepositoryImpl
    ├── domain/
    │   ├── entities/              # entity va Param obyektlari
    │   ├── repositories/          # abstrakt shartnoma
    │   └── usecase/               # bitta biznes amali
    └── presentation/
        ├── bloc/  pages/  widgets/  styles/
```

**1.1** Yangi feature — yangi papka. Qatlam papkalari featuredan tashqarida umumlashtirilmaydi.

**1.2** `core/` ga faqat **kamida ikkita feature** ishlatadigan narsa tushadi. Bitta feature ishlatsa — o'sha feature ichida qoladi.

**1.3** Feature featureni import qilmaydi. Umumiy narsa kerak bo'lsa — `core/` ga chiqariladi.

---

## 2. Bog'liqlik qoidasi (Dependency Rule)

```
presentation ──▶ domain ◀── data
```

**2.1** `domain/` hech kimni bilmaydi. `data/`, `presentation/`, `dio`, `flutter/`, `flutter_bloc` — bularning **birortasi ham** domain ichida import qilinmaydi. Ruxsat: sof Dart, `core/result`, `core/error`, `equatable`.

**2.2** `data/` domainni bilishi mumkin va biladi. Teskarisi taqiqlanadi.

**2.3** `presentation/` domainni biladi. `data/` ni **bilmaydi** — bloc DTO'ni ham, datasource'ni ham ko'rmaydi.

**2.4** Ma'lumot oqimi (runtime) va bog'liqlik yo'nalishi (compile-time) — boshqa-boshqa narsa. Ma'lumot tashqariga oqadi, bog'liqlik ichkariga qaraydi.

**2.5** Tekshirish:

```bash
grep -rn "import.*data/\|package:dio\|package:flutter/" lib/features/*/domain lib/features/*/*/domain
```

Natija bo'sh bo'lishi shart.

---

## 3. Domain qatlami

**3.1 Entity** — sof Dart obyekt. `fromJson`/`toJson` **yo'q**. Backend maydon nomlari entityda uchramaydi. `Equatable` ruxsat etiladi.

**3.2** Entity ichida `Map<String, dynamic>` bo'lmaydi. Har bir maydon o'z tipiga ega.

**3.3 Param obyektlari** (`LoginParams`, `CustomerParam`) — domain entitylari. Usecase kirishida `Map` emas, param obyekti turadi.

**3.4 Repository shartnomasi** — `abstract interface class`, `domain/repositories/` da. Imzolarida **faqat domain va core tiplari** bo'ladi. DTO paydo bo'lsa — shartnoma buzilgan.

**3.5** Shartnoma iste'molchiga tegishli: u domainda turadi, chunki uni domain talab qiladi. Implementatsiyasining yoniga ko'chirilmaydi.

**3.6 Usecase** — `core/usecase/usecase.dart` dagi `UseCase<T, Params>` ni implement qiladi:

```dart
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}
```

Parametrsiz amal uchun `NoParams`.

**3.7** Bitta usecase — bitta amal. Ikkita amalni bitta klassga qo'shmang.

**3.8** Repositoryni chaqirishdan tashqari **barcha biznes qoidalari** usecaseda turadi: bir necha repositoryni ketma-ket chaqirish, amaldan oldingi va keyingi shartlar, natijani tekshirish. Bu qoidalar bloc'ga ham, widgetga ham tushmaydi.

**3.9** Domain foydalanuvchiga ko'rsatiladigan matn yaratmaydi va backend matnini uzatmaydi.

---

## 4. Data qatlami

**4.1 DataSource** nomida manbasi ko'rsatiladi: `<X>RemoteDataSource` (server), `<X>LocalDataSource` (disk, kesh). Bitta klass ikkalasini bajarmaydi.

**4.2 DataSource DTO qaytaradi**, entity emas. Kirishda domain tipini qabul qilishi mumkin (2.2 bo'yicha qonuniy).

**4.3 DataSource xato ushlamaydi.** `try/catch` yo'q. `DioException` repositoryga chiqadi.

**4.4 DTO** — backendning shakli: snake_case kalitlar, `null` bo'lishi mumkin bo'lgan maydonlar. `fromJson` DTO'da yoziladi.

**4.5** DTO'da `toEntity()` bo'ladi. Entityda `fromDto()` **bo'lmaydi** — u domainni datadan qaram qilib qo'yadi.

**4.6** `?? ''`, `?? 0` kabi zaxira qiymatlar faqat **haqiqatan ixtiyoriy** maydonlarga qo'yiladi. Majburiy maydonga zaxira qiymat qo'yish shartnoma buzilishini qonuniy qiymatga aylantiradi va jimgina yiqilishga olib keladi.

**4.7 RepositoryImpl** — shartnomaning bajarilishi. Uning ishi:

1. datasource'ni chaqirish;
2. DTO → entity (`dto.toEntity()`);
3. istisnolarni `Failure` ga o'girish;
4. **ma'lumot domain kutgan shartlarni qanoatlantirishini tekshirish** va qanoatlantirmasa `Err` qaytarish.

**4.8** Istisnolar **repository chegarasida o'ladi**. Undan yuqorida (`usecase`, `bloc`, `widget`) `try/catch` bo'lmaydi. Yuqorida `try/catch` paydo bo'lsa — demak biror chaqiruv `Result` tizimidan tashqarida qolgan.

---

## 5. Xatolar

**5.1** `Result<T>` — `sealed`, ikkita farzandi: `Ok<T>` (qiymat), `Err<T>` (`Failure`). Barcha repository va usecase metodlari `Future<Result<T>>` qaytaradi.

**5.2** `Failure` — `sealed`. Turlari **kim aybdor va foydalanuvchi nima qilishi kerak** bo'yicha ajratiladi, alomat bo'yicha emas:

| Failure | Manba | Foydalanuvchi harakati |
|---|---|---|
| `NetworkFailure` | ulanish yo'q | aloqani tekshiradi, qayta uradi |
| `TimeoutFailure` | server javob bermadi | kutadi, qayta uradi |
| `UnauthorizedFailure` | 401 | qaytadan kiradi |
| `ClientFailure` | 4xx | kiritganini tuzatadi |
| `ServerFailure` | 5xx yoki buzuq javob | kutadi |
| `ParseFailure` | shakl mos emas | hech nima — bu bizning nosozligimiz |
| `UnknownFailure` | noma'lum | hech nima — bu bizning nosozligimiz |

**5.3** Yangi `Failure` turi faqat uni **biror joy ajratib ishlatsa** qo'shiladi: boshqa xatti-harakat, o'ziga xos maydon, yoki alohida tashxis qiymati. Aks holda mavjud tur ishlatiladi.

**5.4** `ErrorMapper.fromDio` faqat `DioException` ni qabul qiladi. Boshqa istisnolar repositoryda o'z `catch` iga tushadi.

**5.5** Har bir repository metodida oxirgi `catch (_)` **majburiy**. U `Result` va'dasini to'liq qiladi: metod hech qachon otilmaydi. Usiz kutilmagan istisno bloc'ga chiqadi va ekran `isLoading` holatida qotib qoladi.

**5.6** `Failure` xatti-harakat bo'yicha guruhlanadi, UI 7 turni emas, guruhlarni biladi:

- `Unauthorized` → `signOut()` + login sahifasi (toast emas);
- `Network` / `Timeout` → ekranda turadigan banner + "Qayta urinish" (o'chib ketadigan toast emas);
- `Client` → tegishli maydon tagida;
- `Parse` / `Unknown` → foydalanuvchiga umumiy xabar, tafsilot botga.

**5.7** Botga faqat **biz tuzata oladigan** xatolar yuboriladi: `ParseFailure`, `UnknownFailure`, `ServerFailure`. `NetworkFailure` va `TimeoutFailure` yuborilmaydi — ular oqimni to'ldirib, haqiqiy nosozlikni ko'mib yuboradi.

**5.8** Jimgina yiqilish taqiqlanadi. Har qanday muvaffaqiyatsiz amal foydalanuvchiga **ko'rinadigan** natija beradi. Yashiriladigan narsa — sabab, hodisaning o'zi emas.

---

## 6. Presentation qatlami

**6.1** Bloc faqat usecase'ni chaqiradi. Repository, datasource, DTO, `Dio` — bloc ularni ko'rmaydi.

**6.2** Bloc UI ta'sirini bajarmaydi: toast, dialog, navigatsiya bloc ichidan chaqirilmaydi. Bloc **holatni** o'zgartiradi, ko'rsatishni widget hal qiladi (`BlocListener`).

**6.3** Bloc `Failure` matnini o'zi to'qimaydi. Foydalanuvchiga ko'rsatiladigan matn `Failure` dan keladi.

**6.4** Bir ekranda ikkita xato tizimi bo'lmaydi. Barcha xato `Result` orqali `switch` ga tushadi.

**6.5 State** — `Equatable`, `copyWith` bilan. `copyWith` da `x ?? this.x` shakli ishlatilgani uchun `null` bilan tozalash **ishlamaydi**: maydonni tozalash uchun aniq `''` beriladi.

**6.6 Event** — `sealed class`, farzandlari `final class`. Nomi o'tgan zamonda: `LoginSubmitted`, `SearchCustomerChanged`.

**6.7** Widget qaror qabul qilmaydi. `TextInputWidget` `errorText` ni **ko'rsatadi**, uni hisoblamaydi.

**6.8** Sahifa o'zi yaratmagan obyektni yopmaydi. `BlocProvider` yaratgan bloc'ni `dispose()` da `close()` qilmang. O'zingiz yaratgan `TextEditingController`, `FocusNode`, `StreamSubscription` — yopiladi.

**6.9** `context.read<T>()` ni `initState` da chaqirish mumkin (obuna yaratmaydi). `context.watch` — mumkin emas.

**6.10** `initState` da `super.initState()` birinchi, `dispose` da `super.dispose()` oxirgi chaqiriladi.

**6.11** Butun ekranni qayta qurmaslik uchun `BlocSelector` ishlatiladi. `BlocBuilder` faqat butun state kerak bo'lganda.

**6.12** `Form` + `GlobalKey<FormState>` + `TextFormField.validator` ishlatilmaydi — u bloc'ga parallel ikkinchi holat manbai. Validatsiya natijasi state'da yashaydi.

---

## 7. Validatsiya

**7.1** Validatsiya kichik, birlashtiriladigan qoidalardan tuziladi (`String? Function(String)`), maydon uchun qoidalar ro'yxati beriladi. "Universal validator" ham, har maydonga alohida funksiya ham yozilmaydi.

**7.2** Shakl tekshiruvi (bo'sh emas, uzunlik, format) — presentationda, bloc'da, submitdan oldin.

**7.3** Biznes qoidasi (parol talablari, yosh chegarasi, summa limiti) — domainda, usecase yoki entityda.

Ajratish mezoni: **backend ham shu qoidani tekshiradimi?** Ha — domain. Yo'q — presentation.

**7.4** Login formasi parolning **borligini** tekshiradi, **shaklini** emas. Uzunlik/format qoidasi mavjud foydalanuvchini o'z akkauntidan qulflaydi.

**7.5** Kiritish xatosi va server xatosi state'da **alohida maydonlarda** saqlanadi va alohida joyda ko'rsatiladi.

---

## 8. Dependency Injection

**8.1** Barcha bog'liqliklar **konstruktor orqali** kiritiladi. Klass ichida `getIt<...>()` chaqirilmaydi — aks holda test mock qo'ya olmaydi.

**8.2** `getIt` faqat `core/di/injection.dart` da va `BlocProvider.create` da ishlatiladi.

**8.3** Ro'yxatdan o'tkazish:

- datasource, repository, usecase, service → `registerLazySingleton`;
- bloc va cubit → `registerFactory` (har ekran o'z nusxasini oladi).

**8.4** Repository interfeys tipi bilan ro'yxatga olinadi:

```dart
getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
```

**8.5** Har bir feature uchun alohida `_register<Feature>()` funksiyasi. Tartib: datasource → repository → usecase → bloc.

---

## 9. Testga tayyorlik

Yangi kod quyidagilarni buzmasligi kerak. Bular alohida ish emas — arxitektura qoidalarining natijasi.

**9.1** Domain sof Dart bo'ladi (2.1). Uni test qilish uchun Flutter ham, tarmoq ham kerak emas.

**9.2** Bog'liqlik konstruktordan kiradi (8.1). Testda o'rniga soxta obyekt qo'yiladi.

**9.3** Konkret klassga emas, abstraksiyaga bog'lanadi (3.4).

**9.4** `DateTime.now()`, `Random()`, `Platform`, to'g'ridan-to'g'ri storage o'qish — mantiq ichida chaqirilmaydi, tashqaridan beriladi. Aks holda test bugun o'tib, ertaga yiqiladi.

**9.5** Bloc'da UI ta'siri bo'lmaydi (6.2), shuning uchun bloc'ni widgetsiz test qilish mumkin.

---

## 10. SOLID — shu loyihada

**S — Single Responsibility.** Klassning o'zgarish sababi bitta bo'ladi.
Datasource endpoint o'zgarganda o'zgaradi. Repository xato tasnifi o'zgarganda. DTO backend shakli o'zgarganda. Bularni birlashtirsangiz — bitta faylda uchta sabab.

**O — Open/Closed.** Yangi xatti-harakat qo'shilganda mavjud kod tahrirlanmaydi.
Yangi `Failure` turi qo'shilsa, UI 5.6 dagi guruhlar bilan ishlagani uchun o'zgarmaydi. `sealed` tufayli qamrab olinmagan `switch` kompilyatsiyada xato beradi.

**L — Liskov.** Har qanday `AuthRepository` implementatsiyasi shartnomaga to'liq amal qiladi: `Result` qaytaradi, istisno otmaydi (4.8, 5.5). Soxta implementatsiya haqiqiysining o'rnini bemalol egallashi kerak.

**I — Interface Segregation.** Shartnoma faqat iste'molchiga kerak metodlarni o'z ichiga oladi. Bitta ulkan `AppRepository` o'rniga featurega tegishli kichik shartnomalar.

**D — Dependency Inversion.** Yuqori qatlam (usecase) quyi qatlamdan (datasource, Dio) emas, **abstraksiyadan** qaram bo'ladi. Shartnoma domainda turgani uchun bog'liqlik strelkasi ichkariga buriladi. Bu — 2-bo'limning butun asosi.

---

## 11. Nomlash va til

**11.1** Meros olinmaydigan klasslar — `final class`. Shartnomalar — `abstract interface class`. Statik yordamchilar — `abstract final class`.

**11.2** Ichki maydonlar `_` bilan boshlanadi, `State` klasslarida ham.

**11.3** Nom vazifasini aytadi: `AuthRemoteDataSource` (manba masofada), `AuthRepositoryImpl` (shartnoma bajarilishi), `LoginParams` (kirish obyekti).

**11.4** Kod izohlari va foydalanuvchi matnlari — o'zbek tilida. Izoh **nima uchun** shunday qilinganini yozadi, kod nima qilishini emas.

**11.5** Izoh kod bilan zid bo'lmasligi kerak. Kod o'zgarsa, izoh ham o'zgaradi.

---

## 12. Taqiqlar

- `domain/` ichida `dio`, `flutter/`, `data/` importi
- entityda `fromJson` / `toJson` / `Map<String, dynamic>`
- `LoginParams` va boshqa param obyektlariga `toJson()` qo'shish
- datasource ichida `try/catch`
- repositorydan yuqorida `try/catch`
- repository metodida oxirgi `catch (_)` ning yo'qligi
- majburiy maydonga `?? ''` / `?? 0` zaxira qiymati
- bloc ichida toast, dialog, `context`, navigatsiya
- bloc ichida qo'lda yozilgan xato matni
- klass ichida `getIt<...>()`
- `static` metodli servis klasslari (`LoginService.userLogin(...)` uslubi)
- `main.dart` ni biror servisdan import qilish
- global `Dio` nusxasi — faqat DI dagi yagona `Dio`
- `!` operatori bilan tip va'da qilish (`strict-casts` yoqilgan)
- `print` — loglash uchun tegishli xizmat ishlatiladi

---

## 13. `colloborator_flex` dan ko'chirish

**13.1** Flex'ning qatlamlari Clean Architecture emas, faqat nomi o'xshash:

- `flex/lib/domain/provider/*_service.dart` — Dio klientlari, ya'ni **data** qatlami;
- `flex/lib/domain/my_dio/` — HTTP klient;
- `flex/lib/domain/common/chuck_button.dart` — Flutter widget;
- `flex/lib/application/<feature>/` — bloclar.

**13.2** Fayldan faylga ko'chirish mumkin emas. Har bir fayl qayta joylashtiriladi va odatda bir nechtaga bo'linadi.

**13.3** Flex fayli bitta klassda bir nechta featureni saqlashi mumkin (`login_service.dart` ichida `userLogin()` va Firebase orqali versiya tekshiruvi `getUpdate()`). Ko'chirishdan oldin featurelar ajratiladi.

**13.4** Ko'chirilgan kod bilan birga flex'ning nuqsonlari ham kelmasligi kerak: `Map<String,dynamic>` parametrlar, backend matnini foydalanuvchiga chiqarish, `static` servislar, `dotenv`/`PackageInfo` ni mantiq ichida o'qish.

---

## 14. Tekshirish

```bash
flutter analyze
```

```bash
grep -rn "import.*data/\|package:dio\|package:flutter/" lib/features/*/domain lib/features/*/*/domain
```

```bash
grep -rn "getIt<" lib/features
```

```bash
flutter test
```

`analysis_options.yaml` da `strict-casts`, `strict-inference`, `strict-raw-types` yoqilgan. `flutter analyze` toza bo'lishi shart.

---

## 15. Hozirgi holat

*Yangilangan: 2026-09-03*

**Ish uslubi:** UI (`presentation/`, `core/widgets/`, `core/theme/`) — Claude yozadi. `bloc/`, `data/`, `domain/` va `core/` ning qolgani — loyiha egasi yozadi, Claude tekshiradi va birma-bir kamchilik ko'rsatadi.

**Nazorat majburiy va so'rashsiz bajariladi.** Har safar kod ko'rsatilganda yoki tegib o'tilganda quyidagilar tekshiriladi va topilgani **so'ralmasa ham** aytiladi:

1. Faqat berilgan savolga javob berish yetarli emas — yondosh fayllarda ko'ringan qoida buzilishi ham o'sha javobda aytiladi.
2. "Ishlayapti" degani "to'g'ri" degani emas. Jimgina yiqiladigan har bir yo'l ko'rsatiladi: zaxira qiymat, bo'sh `catch`, ulanmagan mexanizm, ko'rsatilmaydigan state maydoni.
3. Tekshiruv ro'yxati (12-bo'lim taqiqlari + quyidagilar): majburiy maydonga `?? ''`/`?? 0`/`?? {}`/`?? []`; `!` operatori; `print`/`debugPrint`; klass ichida `getIt<>`; datasource'da `try/catch`; repositorydan yuqorida `try/catch`; repository metodida oxirgi `catch (_)` yo'qligi; bloc'da matn to'qish; nomi ishiga zid metod; o'lik kod va hech qayerdan chaqirilmaydigan mexanizm; state'ga yozilib ekranga chiqmaydigan maydon; o'tgan zamonda bo'lmagan event nomi.
4. **Flex odatlari alohida nazoratda** (13.4): `Map<String,dynamic>` parametr, `static` servis, o'z `Dio` nusxasi, bo'sh xabarli `Failure`, sehrli satr/raqam, widget ichida qaror, bitta klassda bir nechta mas'uliyat.
5. Tekshiruv natijasi yumshatilmaydi. Xato bo'lsa — xato deyiladi, sababi va oqibati bilan.

---

### Tugallangan tizimlar

**Xatolar (5.x) — to'liq.** `FailureGroup` va `Failure.group` / `Failure.isReportable` getterlari `core/error` da. Barcha bloclar `Failure?` saqlaydi, birortasi matn to'qimaydi. `FailureView` guruhga qarab yo'naltiradi: `session` → dialog + chiqish, `connection` → banner + "Qayta urinish", `input` → maydon tagida, `internal` → umumiy matn. Foydalanuvchiga ko'rinadigan matn `FailureText` da — yagona manba. To'rtala ekran ham ulangan: mijozlar, shartnomalar, login, registratsiya.

**Telegram bot (5.7) — ishlayapti.** `TelegramErrorReporter` + `ErrorReportInterceptor`, `injection.dart` da ulangan. `JsonParser.reporter` ham shu kanalga ulandi — u loyiha boshidan beri o'lik turgan edi. Token va chat id `.env` da (git'da kuzatilmaydi). Takrorlar 10 daqiqalik oynada filtrlanadi.

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

### Ochiq ishlar

*A — ulanmagan tugmalar (5.8 buzilishi)*

Bosiladi, lekin hech nima qilmaydi — foydalanuvchi uchun bu jimgina yiqilish. 2026-09-03 holatiga 6 ta:

1. Menyu tugmasi — `customer_page.dart:101` va `contracts_page.dart:78` (`drawerPress: () {}`). Menyuning o'zi hali yo'q.
2. `pressContract` — `customer_page.dart:195`. Mahsulotlarga olib boradi, o'sha feature yo'q.
3. Shartnoma amallari — `contracts_page.dart:141`: `pressApprove`, `pressEdit`, `pressCancel`. `pressDetails` ulangan.

Oldingi A ro'yxatidagilar — `cache_data.dart`, `debugPrint`, `workpalce` imlosi, `FirebaseService` singletoni, face_id natijasi, mijoz amallari, shartnoma tafsiloti — **yopilgan**.

*A2 — backenddan javob kutayotganlar*

5. **`is_edit` har doim `true` ketadi.** Flex'da map literalida kalit ikki marta yozilgan va oxirgisi shartsiz `true` edi — ya'ni yangi mijozda ham `true` ketgan. v3 shu xatti-harakatni saqlaydi: backend `false` yo'lida sinalmagan. **So'ralishi kerak:** `is_edit` nima uchun kerak va yangi mijozda `false` bo'lishi kerakmi?
6. **`data:image/png;base64,`** — yuborilayotgan baytlar JPEG. Prefiks o'qiladimi?
7. **`client-search` `page: 1` da qotgan.** Flex sahifalash qilardi; 30 tadan ko'p natija jimgina kesiladi.
8. **Skoring DTO'sida 13 ta qat'iy tip.** Flex hammasiga zaxira qiymat qo'ygan. Bitta maydon kelmasa `ParseFailure` chiqadi va botga aynan qaysi maydon ekani yoziladi — shundan keyin aniq hal qilinadi.

*B — qaror kutayotganlar*

5. **Lokalizatsiya — ongli ravishda kechiktirilgan.** Uch til rejalashtirilgan: lotin o'zbek, kiril o'zbek va rus tili. `easy_localization` shuning uchun qoladi, lekin `tr()` ga o'tish **featurelar tugagandan keyin**, bitta o'tishda qilinadi — hozir har yangi ekran kalitlarni ikki marta yozishga majbur qiladi.

   O'sha ishni boshlaganda:
   - `main.dart` dagi `useOnlyLangCode: true` → **`false`** bo'lishi shart. U faqat til kodiga qaraydi, lotin va kiril o'zbek esa ikkalasi ham `uz` — bitta faylga tushib, bir-birini bosib ketadi.
   - Qo'lda ikkita fayl yoziladi (lotin o'zbek, rus). Kiril o'zbek — **transliteratsiya**, u skript bilan lotindan yaratiladi.

   Shu qaror tufayli UI'da hozirdan amal qiladigan qoida: matn qat'iy kenglikka bog'lanmaydi (`Flexible`/`Expanded`, bir qatorlida `maxLines: 1` + `ellipsis`), va foydalanuvchi matnlari har feature uchun bitta faylga yig'iladi. Kiril va rus matnlari lotindan 15–30% uzunroq.
   - **Ommaviy oferta ham tilga qarab tanlanadi.** `assets/offer/` da `offerUZ.html` va `offerRU.html` bor, `AppIcons.offerUz` / `AppIcons.offerRu` sifatida yozilgan. Hozir `OfferSheet` faqat o'zbekchasini ochadi — `offerRu` shu ishgacha chaqirilmaydi. Kiril o'zbek uchun uchinchi fayl kerak bo'ladi (transliteratsiya HTML ustida ishlamaydi — teglarni ham o'zgartirib yuboradi).
9. Contracts DTO'sida 25 + 8 zaxira qiymat — backend qaysi maydonlar `null` bo'lishi mumkinligini aytgach hal qilinadi.
10. Registratsiyadagi `successMessage` backenddan keladi va ekranga chiqadi. Backend har xil holatda har xil matn yuborsa, matn emas `code` kerak bo'ladi.

*C — ataylab qoldirilgan*

8. `auth_remote_datasource.dart` dagi qattiq yozilgan `device_id` — turli qurilmalarda sinov uchun. **Eslatilmaydi.** Relizdan oldin `AppConstants.isStaging` bilan ajratish tavsiya etilgan.

*D — hali boshlanmagan*

9. `invoices` va `outputs` — sahifalari `Center(Text(...))`, bloclari bo'sh shablon (`// TODO: implement event handler`).
10. **Testlar — ongli ravishda loyiha oxiriga qoldirilgan.** Hozircha 64 ta: `error_mapper`, `face_check_form`, `face_placement`, formatterlar. Ular qoida yozilganda birga yozilgan, alohida ish sifatida emas. Qolgan qamrov featurelar tugagandan keyin. **Eslatilmaydi.**

---

### Tekshirish buyruqlari

```bash
flutter analyze                                   # toza bo'lishi shart
grep -rn "import.*data/\|package:dio\|package:flutter/" lib/features/*/domain lib/features/*/*/domain
grep -rn "getIt<" lib/features                    # faqat BlocProvider.create da
flutter test                                      # 118 ta test
dart run tool/bot_test.dart                       # bot ulanishini tekshirish
```

`tool/` dagi skriptlar faqat sof Dart bo'ladi. Flutterga tegadigan tekshiruv (formatter, widget) `test/` ga yoziladi — `dart run` Flutter kutubxonalarini ko'tara olmaydi.

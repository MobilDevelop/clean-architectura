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

**Ish uslubi:** kodni loyiha egasi o'zi yozadi. Men tahlil qilaman, qoidaga zidligini ko'rsataman va tekshiraman — so'ralmagan holda kod yozmayman va tahrirlamayman.

**Nazorat majburiy va so'rashsiz bajariladi.** Har safar kod ko'rsatilganda yoki tegib o'tilganda quyidagilar tekshiriladi va topilgani **so'ralmasa ham** aytiladi:

1. Faqat berilgan savolga javob berish yetarli emas — yondosh fayllarda ko'ringan qoida buzilishi ham o'sha javobda aytiladi.
2. "Ishlayapti" degani "to'g'ri" degani emas. Jimgina yiqiladigan har bir yo'l ko'rsatiladi: zaxira qiymat, bo'sh `catch`, ulanmagan mexanizm, ko'rsatilmaydigan state maydoni.
3. Tekshiruv ro'yxati (12-bo'lim taqiqlari + quyidagilar): majburiy maydonga `?? ''`/`?? 0`/`?? {}`/`?? []`; `!` operatori; `print`/`debugPrint`; klass ichida `getIt<>`; datasource'da `try/catch`; repositorydan yuqorida `try/catch`; repository metodida oxirgi `catch (_)` yo'qligi; bloc'da matn to'qish; nomi ishiga zid metod; o'lik kod va hech qayerdan chaqirilmaydigan mexanizm; state'ga yozilib ekranga chiqmaydigan maydon; o'tgan zamonda bo'lmagan event nomi.
4. **Flex odatlari alohida nazoratda** (13.4). Ko'chirilgan har bir bo'lakda qidiriladi: `Map<String,dynamic>` parametr, `static` servis, o'z `Dio` nusxasi, bo'sh xabarli `Failure`, sehrli satr/raqam (`'psr'`, `type: 1`), widget ichida qaror (`hint == "..."` bo'yicha shart), bitta klassda bir nechta mas'uliyat.
5. Tekshiruv natijasi yumshatilmaydi. Xato bo'lsa — xato deyiladi, sababi va oqibati bilan. Maqtov faqat tekshirilgan narsaga beriladi.

**Ochiq ishlar ro'yxati** (2026-08-22 holatiga, tekshirilgan):

*A — hozir sinib turgan yoki sindirishi mumkin*

1. `PermissionsDto` (`user_dto.dart:78-81`) — `?? false` olib tashlangan. Ruxsat guruhi kelmagan foydalanuvchi umuman login qila olmaydi. Bu maydonlar haqiqatan ixtiyoriy, zaxira qiymat qaytarilishi kerak.
2. `auth_remote_datasource.dart:36` — `device_id` qo'lda yozilgan (`"aa2ad6bb11fcdefd"`), haqiqiysi izohga olingan.
3. `registration_page.dart:151` — `getIt<RegistrationBloc>()` `onPressed` ichida. Bloc `registerFactory`, ya'ni har bosishda yangi nusxa: UI javob ko'rmaydi, so'rov esa ketadi.

*B — `JsonParser` (1-bosqich)*

4. `object` da `reason: e.runtimeType.toString()` → `e.toString()`. Hozir login xatolari `_TypeError` bo'lib keladi va `fromJson` bitta ifoda bo'lgani uchun trace ham ikkala holatda bir xil qatorni ko'rsatadi.
5. `_report` himoyalanmagan — `reporter` otsa parse yiqiladi (sinovda tasdiqlangan).
6. Ikki qaror: `raw == null` bo'lganda xabar beriladimi; barcha elementlar buzuq bo'lganda repository buni qanday biladi (`({List<T> items, int failed})` taklif qilingan).

*C — DTO va backend savollari*

7. **Backend bilan aniqlanadi:** `user.company` / `company_id` va `organization` / `organization_id` `null` kelishi mumkin. Ular juft-juft bitta nullable qiymat obyektiga yig'iladi (`Company?`, `Organization?`). Login domaini registratsiyaning `Organization` ini import qilmaydi (1.3) — o'z tipini yozadi.
8. `UserDto` ning qolgan maydonlari ham shu ko'z bilan ko'rib chiqiladi: `User` hozir hech qayerda o'qilmaydi, ya'ni har bir qattiq cast ishlatilmaydigan ma'lumot uchun loginni to'sishi mumkin.
9. `CustomerInfoDto` da `workplace`, `province`, `region`, `village` majburiy qilingan. Ishsiz yoki manzili to'liq bo'lmagan mijoz bo'lsa, u qidiruvdan jimgina tushib qoladi. Alice orqali haqiqiy javobda tekshiriladi.

*D — bot va xatolar (2-bosqich)*

10. `JsonParser.reporter` hech qayerda ulanmagan — butun mexanizm o'lik. Manzil: flex'dagi `domain/common/bot_service.dart`.
11. `Failure` guruhlari (5.6) bajarilmagan; `'Server javobi kutilgan shaklda emas'` hozir toastda foydalanuvchiga ko'rinadi.
12. `AppRouter.errorBuilder` → `const SizedBox()`, marshrut xatosida oq ekran.

*E — qatlam qoidalari*

13. `try/catch` datasource ichida: `auth_remote_datasource._fcmToken()`, `registration_remote_datasource` (4.3).
14. `LoginBloc` `_auth.signIn` ni o'zi chaqiradi, `try/catch` bilan o'raydi va xato matnini o'zi yozadi (4.8, 6.3).
15. `app_manager_cubit` dagi `try/catch` — startup xatolari `Result` tizimidan tashqarida (6.4).

*F — mijozlar ekrani (state bo'shliqlari, UI chizmasini kutmaydi)*

16. `searchError` va `isLoading` state'da bor, ekranga chiqmaydi; "hali qidirilmagan" va "topilmadi" holatlari farq qilmaydi.
17. `ShowSearch` nomi o'tgan zamonda emas; tez yozganda eski javob yangisining ustiga tushishi; `page: 1, per_page: 30` qattiq yozilgan.

*G — mayda*

18. `!` operatori 29 joyda; ildizi bitta — `AppTheme.data.textTheme.X!`.
19. `debugPrint` 4 faylda.
20. `chuck_button` ichida `getIt<Alice>()`.
21. `workpalce_info*.dart` va `mainAdress` imlosi (10 joy).
22. `registration_page`: ochiq controller maydonlari, `super.initState()` oxirida.
23. `ParseFailure` izohi ikki o'lchovni aralashtiradi: shakl va ayb (11.5).

**Bajarilgan (shu sessiyada tekshirilgan):** iOS'da ishga tushirildi; login validatsiyasi to'liq zanjir bo'lib ulandi (`core/utils/validator/rules.dart` → event → state → `errorText`); mijoz qidiruvi turga qarab sozlanadi (`CustomerSearchParams` + datasource'da `switch`); `PassportFormatter` sof formatterga aylanib feature ichiga ko'chdi; DTO'lardagi zaxira qiymatlar 45 tadan 5 taga tushdi; `JsonParser` da `model` parametri `T` bilan almashtirildi va chaqiruv joylaridagi `?? []` olib tashlandi.

**Testlar:** `test/core/error/error_mapper_test.dart` (11 test) o'tadi. Usecase, repository va bloc testlari hali yozilmagan.

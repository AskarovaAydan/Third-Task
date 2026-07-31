# Meal Explorer — Flutter API App

TheMealDB açıq REST API-si ilə işləyən, yemək resepti axtaran mobil tətbiq. Siyahı + detal ekranı, pull-to-refresh, sonsuz scroll (pagination), şəkil keşləmə və düzgün loading/error/empty vəziyyətləri ilə hazırlanıb.

## İstifadə olunan API

- **TheMealDB** — https://www.themealdb.com/api.php
- Siyahı: `GET /search.php?s={query}`
- Detal: `GET /lookup.php?i={id}`
- API key tələb olunmur (test key: `1`)

## Texnologiyalar

| Paket | Məqsəd |
|---|---|
| `dio` | HTTP sorğuları (interceptor, timeout, xəta idarəetməsi) |
| `cached_network_image` | Şəkillərin diskdə keşlənməsi |
| Flutter SDK | UI (Material Design) |

## Layihə strukturu

```
lib/
 ├── main.dart                     # App giriş nöqtəsi
 ├── models/
 │    ├── meal.dart                # Meal data modeli (fromJson/toJson)
 │    └── view_state.dart          # Ekran vəziyyətləri üçün enum
 ├── services/
 │    └── meal_api_service.dart    # Yalnız API çağırışı (dio), UI-dan ayrı
 ├── repositories/
 │    └── meal_repository.dart     # Service ilə UI arasında əlaqə qatı
 ├── screens/
 │    ├── meal_list_screen.dart    # Siyahı, pagination, pull-to-refresh
 │    └── meal_detail_screen.dart  # Yemək detalı
 └── widgets/
      └── meal_card.dart           # Təkrar istifadə olunan siyahı kartı
```

## Arxitektura

Layihə **Repository Pattern** üzərində qurulub, üç aydın qatla:

1. **Service qatı** (`MealApiService`) — yalnız şəbəkə sorğuları ilə məşğuldur, UI haqqında heç nə bilmir.
2. **Repository qatı** (`MealRepository`) — service-i "wrap" edir, UI birbaşa API-yə yox, repository-yə müraciət edir.
3. **UI qatı** (`screens/`, `widgets/`) — yalnız repository ilə danışır, göstərilmə məntiqini idarə edir.

Bu ayrılıq sayəsində, məsələn `http`-dən `dio`-ya keçid yalnız `MealApiService` daxilində edildi — UI qatına heç toxunulmadı.

## Xüsusiyyətlər

### 1. API Service Layer
- `dio` ilə HTTP sorğuları, `BaseOptions` ilə mərkəzləşmiş timeout konfiqurasiyası
- `DioException` tutulur və istifadəçi-dostu mesajlara çevrilir (`_mapDioError`)

### 2. List + Detail ekranı
- Siyahıdan detal ekranına yalnız `mealId` ötürülür (data transfer)
- Detal ekranı özü `lookup.php` ilə tam məlumatı yenidən çəkir

### 3. Loading / Error / Empty vəziyyətləri
- `ViewStatus` enum-u ilə 4 vəziyyət idarə olunur: `loading`, `success`, `error`, `empty`
- Xəta zamanı "Yenidən cəhd et" düyməsi görünür və `_loadMeals()`-i təkrar çağırır

### 4. Pull-to-refresh + Pagination
- TheMealDB real pagination dəstəkləmədiyi üçün **client-side pagination** tətbiq olunub: bütün data bir dəfə çəkilir, ekranda hissə-hissə (6 element) göstərilir
- `ScrollController` ilə sonsuz scroll: siyahının sonuna yaxınlaşanda növbəti hissə əlavə olunur
- `_isLoadingMore` bayrağı ilə **eyni səhifə üçün təkrar sorğunun qarşısı alınır** (scroll listener tez-tez trigger olsa belə)
- `RefreshIndicator` ilə yuxarıdan aşağı çəkərək tam yenidən yükləmə

### 5. Image Caching
- `cached_network_image` ilə şəkillər diskdə keşlənir, təkrar göstərilərkən yenidən yüklənmir
- `placeholder` (yüklənərkən) və `errorWidget` (uğursuz olarsa) vəziyyətləri idarə olunur

### 6. JSON Model Parsing
- `Meal.fromJson()` — API cavabını Dart obyektinə çevirir
- `Meal.toJson()` — əks istiqamətdə serialization
- Bütün optional sahələr (`thumbnail`, `category`, `area`, `instructions`) `null-safe` şəkildə (`String?` + `??` operatoru) işlənir

### 7. Code Quality
- Repository pattern ilə aydın qat ayrılığı
- UI komponentləri (`MealCard`) təkrar istifadə oluna bilən şəkildə ayrılıb

## Quraşdırma

```bash
flutter pub get
flutter run
```

## Asılılıqlar (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  cached_network_image: ^3.3.1
```

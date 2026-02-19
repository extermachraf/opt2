# 📱 NutriVita App Structure Guide

## Quick Navigation Map

### 🗂️ Project Structure
```
nutrivita/
├── 📁 lib/                          # Main application code
│   ├── 📁 core/                     # Core utilities & providers
│   │   ├── app_export.dart          # Central exports
│   │   ├── theme_provider.dart      # Theme management
│   │   └── accessibility_provider.dart
│   │
│   ├── 📁 theme/                    # 🎨 STYLING SYSTEM
│   │   └── app_theme.dart           # ALL COLORS, FONTS, STYLES
│   │
│   ├── 📁 presentation/             # 📱 ALL SCREENS/PAGES
│   │   ├── 📁 splash_screen/
│   │   ├── 📁 login_screen/
│   │   ├── 📁 registration_screen/
│   │   ├── 📁 dashboard/            # Main home screen
│   │   ├── 📁 meal_diary/
│   │   ├── 📁 add_meal/
│   │   ├── 📁 body_metrics/
│   │   ├── 📁 reports/
│   │   ├── 📁 recipe_management/
│   │   ├── 📁 profile_settings/
│   │   └── ... (more screens)
│   │
│   ├── 📁 routes/                   # 🗺️ NAVIGATION
│   │   └── app_routes.dart          # All route definitions
│   │
│   ├── 📁 services/                 # 🔧 Business logic
│   │   ├── auth_service.dart
│   │   ├── meal_diary_service.dart
│   │   ├── dashboard_service.dart
│   │   └── ... (more services)
│   │
│   ├── 📁 widgets/                  # 🧩 Reusable components
│   │   ├── custom_icon_widget.dart
│   │   ├── custom_image_widget.dart
│   │   └── custom_error_widget.dart
│   │
│   └── main.dart                    # 🚀 App entry point
│
├── 📁 assets/                       # Images, icons, etc.
├── pubspec.yaml                     # Dependencies
└── STYLING_GUIDE.md                 # 📖 This guide!
```

---

## 🎯 How to Find What You Need

### Want to change colors or fonts?
```
👉 Go to: lib/theme/app_theme.dart
```

### Want to find a specific page?
```
1. Check: lib/routes/app_routes.dart (see all page routes)
2. Go to: lib/presentation/[page_name]/[page_name].dart
```

### Want to see all available pages?
```
👉 Go to: lib/routes/app_routes.dart
```

### Want to modify a page's components?
```
👉 Go to: lib/presentation/[page_name]/widgets/
```

---

## 📱 All Available Pages

| Page Name | Route | File Location |
|-----------|-------|---------------|
| Splash Screen | `/splash_screen` | `lib/presentation/splash_screen/splash_screen.dart` |
| Onboarding | `/onboarding_flow` | `lib/presentation/onboarding_flow/onboarding_flow.dart` |
| Login | `/login_screen` | `lib/presentation/login_screen/login_screen.dart` |
| Registration | `/registration_screen` | `lib/presentation/registration_screen/registration_screen.dart` |
| Dashboard | `/dashboard` | `lib/presentation/dashboard/dashboard.dart` |
| Meal Diary | `/meal-diary` | `lib/presentation/meal_diary/meal_diary.dart` |
| Add Meal | `/add-meal` | `lib/presentation/add_meal/add_meal.dart` |
| Body Metrics | `/body_metrics` | `lib/presentation/body_metrics/body_metrics.dart` |
| Reports | `/reports` | `lib/presentation/reports/reports.dart` |
| Recipe Management | `/recipe-management` | `lib/presentation/recipe_management/recipe_management.dart` |
| Recipe Detail | `/recipe-detail` | `lib/presentation/recipe_detail/recipe_detail_screen.dart` |
| Nutrition Database | `/nutrition-database` | `lib/presentation/nutrition_database/nutrition_database_screen.dart` |
| Patient Education | `/patient-education` | `lib/presentation/patient_education/patient_education.dart` |
| Questionnaire | `/questionnaire-page` | `lib/presentation/questionnaire_page/questionnaire_page.dart` |
| Quiz | `/quiz-page` | `lib/presentation/quiz_page/quiz_page.dart` |
| Profile Settings | `/profile-settings` | `lib/presentation/profile_settings/profile_settings.dart` |
| Dark Mode Settings | `/dark-mode-settings` | `lib/presentation/dark_mode_settings/dark_mode_settings.dart` |
| Accessibility | `/accessibility-settings` | `lib/presentation/accessibility_settings/accessibility_settings.dart` |

---

## 🎨 Styling System Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    lib/theme/app_theme.dart                  │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Color Definitions (Lines 10-34)                     │   │
│  │  • primaryLight, secondaryLight, etc.                │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Light Theme (Lines 50-341)                          │   │
│  │  • ColorScheme, AppBar, Buttons, Cards, etc.        │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Dark Theme (Lines 343-636)                          │   │
│  │  • Same structure as light theme                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                           ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Typography (Lines 640-744)                          │   │
│  │  • Text styles using Google Fonts Inter             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                      lib/main.dart                           │
│  • Applies theme to entire app via MaterialApp              │
│  • theme: ThemeProvider.instance.getCurrentThemeData()      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              All Pages & Widgets Use Theme                   │
│  • Theme.of(context).colorScheme.primary                    │
│  • Theme.of(context).textTheme.headlineMedium               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Example: Finding and Modifying the Dashboard

### Step 1: Find the Dashboard Route
```dart
// File: lib/routes/app_routes.dart
static const String dashboard = '/dashboard';

// Route mapping
dashboard: (context) => const Dashboard(),
```

### Step 2: Open Dashboard File
```
📁 lib/presentation/dashboard/dashboard.dart
```

### Step 3: Check Dashboard Widgets
```
📁 lib/presentation/dashboard/widgets/
  ├── kpi_card_widget.dart          # Nutrition KPI cards
  ├── meal_card_widget.dart         # Meal summary cards
  ├── body_card_widget.dart         # Body metrics card
  ├── achievement_badge_widget.dart # Achievement badges
  └── quick_action_sheet_widget.dart # Quick actions
```

### Step 4: Modify Styling
```dart
// In kpi_card_widget.dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface, // Uses theme color
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text(
    'Calories',
    style: Theme.of(context).textTheme.titleMedium, // Uses theme text style
  ),
)
```

---

## 🎯 Common Tasks

### Task 1: Change Primary Brand Color

**File:** `lib/theme/app_theme.dart`

```dart
// Line 10 - Change this color
static const Color primaryLight = Color(0xFF2E7D6A); // Current: Nutri green

// Change to blue:
static const Color primaryLight = Color(0xFF2196F3);

// Change to purple:
static const Color primaryLight = Color(0xFF9C27B0);
```

### Task 2: Change Button Style Globally

**File:** `lib/theme/app_theme.dart`

```dart
// Lines 142-157 - Modify ElevatedButton theme
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryLight,        // Button background
    foregroundColor: Colors.white,        // Button text color
    padding: EdgeInsets.symmetric(
      horizontal: 24,                     // Horizontal padding
      vertical: 12,                       // Vertical padding
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0), // Corner radius
    ),
  ),
),
```

### Task 3: Add a New Page

**Step 1:** Create page file
```
📁 lib/presentation/my_new_page/my_new_page.dart
```

**Step 2:** Add route in `lib/routes/app_routes.dart`
```dart
// Add route constant
static const String myNewPage = '/my-new-page';

// Add route mapping
static Map<String, WidgetBuilder> get routes => {
  // ... existing routes
  myNewPage: (context) => const MyNewPage(),
};
```

**Step 3:** Navigate to the page
```dart
Navigator.pushNamed(context, AppRoutes.myNewPage);
```

---

## 📚 Related Documentation

- **STYLING_GUIDE.md** - Complete styling guide with examples
- **README.md** - Project setup and overview
- **lib/theme/app_theme.dart** - Theme source code with comments

---

**Need more help? Check STYLING_GUIDE.md for detailed examples!** 📖


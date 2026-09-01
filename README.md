<div align="center">

# ⚡ Burn Think

**The ultra-minimalist, offline-first personal workspace & deep execution command center.**  
*Built with Flutter & SQLite. 100% local, zero latency, zero cloud tracking.*

---

[![Flutter](https://img.shields.io/badge/Flutter-3.12%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-000000?logo=windows&logoColor=white)](https://flutter.dev/desktop)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20Layered-blueviolet)](https://github.com/kareemxmhmd/Burn_shut)
[![Database](https://img.shields.io/badge/Database-SQLite%20FFI-003B57?logo=sqlite&logoColor=white)](https://sqlite.org)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local%20%26%20Private-2ea44f)](https://sqlite.org)
[![Theme](https://img.shields.io/badge/Design-Monochrome%20Glass-4A4A4A)](#-design--desktop-ergonomics)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

</div>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Core Philosophy](#-core-philosophy)
- [Specialized Workspaces](#-specialized-workspaces)
- [On-Device Personal Intelligence](#-on-device-personal-intelligence-100-local--private)
- [Design & Desktop Ergonomics](#-design--desktop-ergonomics)
- [Data Ownership & Portability](#-data-ownership--portability)
- [Architecture & Codebase Structure](#-architecture--codebase-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation & Running](#installation--running)
  - [Building for Production](#building-for-production)
- [Automated Testing](#-automated-testing)
- [Shortcuts & Desktop Interactions](#-shortcuts--desktop-interactions)
- [نظرة عامة باللغة العربية (Arabic Overview)](#-نظرة-عامة-باللغة-العربية-arabic-overview)
- [License](#-license)

---

## 🧭 Overview

**Burn Think** is a high-performance desktop application engineered to eliminate cognitive overload and digital fragmentation. Modern workflows often force individuals to scatter their focus across disconnected tools—to-do lists in one app, quick notes in another, content drafts in a browser tab, fitness routines in mobile trackers, and shopping lists in chat messages.

**Burn Think unifies your daily execution into a single, distraction-free command center.** Powered by a dark glassmorphic design and an on-device local intelligence engine, Burn Think provides instant capture, smart priority prediction, multi-token semantic search, and structured tracking—without sending a single byte of your data to the cloud.

---

## 💎 Core Philosophy

1. **⚡ Zero Network Latency**: Runs 100% locally with direct SQLite FFI bindings. Actions respond within milliseconds with zero network roundtrips.
2. **🔒 Absolute Privacy & Sovereign Data**: No tracking, no third-party telemetry, no cloud lock-in. Your data stays entirely on your device.
3. **🧠 Autonomous Local Intelligence**: Intelligent sorting, focus ranking, and duplicate detection using lightweight on-device heuristic algorithms and adaptive local feedback.
4. **🖤 Monochrome Glass Aesthetics**: High-contrast, typography-first frosted glass interface built for deep work and minimal visual strain.

---

## 🗂 Specialized Workspaces

| Workspace | Description & Capabilities |
| :--- | :--- |
| **🏠 Home Cockpit** | Real-time productivity cockpit featuring **Today's Focus**, daily activity momentum, active project progression, and workspace health metrics. |
| **📋 Tasks** | Priority-driven task management (`Urgent`, `High`, `Medium`, `Low`, `None`) with due date countdowns, inline completion toggles, and direct project linking. |
| **🚀 Projects** | Multi-step initiative tracker with nested milestone checklists, auto-calculated progress bars, and item reordering. |
| **🏋️ Workout** | Structured daily fitness routine builder with detailed exercise tracking (sets, reps, weights, target muscle groups, and custom notes). |
| **🎬 Content Pipeline** | Idea incubator and Kanban-style editorial workflow (`Idea` ➔ `Scripting` ➔ `In Production` ➔ `Published`) with multi-platform tags (*YouTube*, *X*, *TikTok*, *LinkedIn*, *Newsletter*, *Podcast*). |
| **📝 Notes & Scratchpad** | Distraction-free scratchpad for thoughts, memos, code snippets, and pinned reference notes with fast multi-token search. |
| **🛒 Shopping List** | Smart shopping list with item quantities, price estimation, automatic total calculation, category organization, and one-click purchase checkoff. |
| **📦 Completed Archive** | Unified audit trail and history of all finished tasks, shipped projects, and purchased items with instant one-click restoration. |
| **⚙️ Settings & Intelligence** | Control panel to toggle personal intelligence algorithms, inspect recorded local learning events, manage backups, or reset data. |

---

## 🧠 On-Device Personal Intelligence (100% Local & Private)

Burn Think embeds five heuristic and statistical intelligence algorithms running strictly on your local CPU:

```
                  ┌────────────────────────────────────────┐
                  │          User Input / Quick Add         │
                  └───────────────────┬────────────────────┘
                                      │
              ┌───────────────────────┼───────────────────────┐
              ▼                       ▼                       ▼
   ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐
   │ Smart Categorizer  │  │ Duplicate & Link   │  │  Semantic Search   │
   │ Keyword Heuristics │  │ Similarity Engine  │  │ Multi-Token Fuzzy  │
   └──────────┬─────────┘  └────────────────────┘  └────────────────────┘
              │
              ▼
   ┌────────────────────┐  ┌────────────────────┐
   │ Priority Predictor │  │ Behavior Analytics │
   │ Focus Score (0-100)│  │ Velocity & History │
   └────────────────────┘  └────────────────────┘
```

1. **🎯 Today's Focus Prediction (`PriorityPredictor`)**  
   Evaluates user-assigned priority, due date proximity (overdue, due today, upcoming), and parent project urgency to dynamically compute a composite score (0–100) and recommend the top high-impact tasks for today.
2. **🏷️ Smart Categorization (`SmartCategorizer`)**  
   Analyzes quick-input text against contextual keyword dictionaries (tasks, projects, workouts, content, notes, shopping) to pre-select the appropriate workspace module with confidence scoring.
3. **🔄 Adaptive Local Feedback Learning**  
   When you override an automated category recommendation, Burn Think stores the correction in local SQLite event tables to adjust future predictions for that phrase pattern without external model training.
4. **🔍 Semantic & Multi-Token Search (`SemanticSearchEngine`)**  
   Executes sub-millisecond keyword, token-cluster, and fuzzy matching across all workspace entities (titles, notes, descriptions, tags, and status).
5. **🔗 Related & Duplicate Item Detection (`RelatedItemsDetector`)**  
   Calculates token overlap between new entries and active tasks/projects, warning you of duplicates or suggesting project associations before creation.
6. **📊 Local Behavior Analytics (`BehaviorAnalyticsEngine`)**  
   Computes average completion duration, 7-day velocity momentum, longest active tasks, and category distributions—stored and calculated strictly on your machine.

---

## 🎨 Design & Desktop Ergonomics

- **Frosted Glassmorphism**: Multi-layered glass surfaces (`AppColors.glassSurface`, `glassBorderSubtle`, `metallicWhite`) with subtle borders and shadows.
- **Contextual Sliding Panels**: Non-intrusive drawers (`DetailDrawer`) and centered modals (`QuickAddModal`, `SearchModal`) that open smoothly over your active view without disrupting context.
- **Keyboard-First Controls**: Global `Esc` dismissals, auto-focused inputs, and rapid selection triggers.
- **Native Desktop Integration**: Custom title bar controls via `window_manager` with window constraint enforcement (`920x600` minimum).
- **Fluid Layout**: Responsive split-view architecture that scales effortlessly from compact laptop screens to ultra-wide desktop monitors.

---

## 💾 Data Ownership & Portability

- **SQLite FFI Engine**: Built on `sqflite_common_ffi` and `sqlite3_flutter_libs` with full transaction integrity, foreign keys enabled, and migration scripts.
- **Structured JSON Backup**:
  - **Export**: One-click generation of a single, human-readable JSON file containing your complete workspace state.
  - **Import (Merge)**: Combines imported items into your existing workspace without overwriting existing entries.
  - **Import (Replace)**: Completely replaces the workspace state with the imported backup file.
- **Safe Reset Workflow**: Double-confirmed database purge mechanism to erase local data securely when needed.

---

## 🏗 Architecture & Codebase Structure

Burn Think is structured around **Clean Architecture** principles, maintaining strict separation between presentation, domain entities, and data persistence:

```
lib/
├── app/                      # Application entry, global theme, and AppShell
│   ├── app.dart              # MaterialApp setup & MultiProvider initialization
│   └── app_shell.dart        # Desktop navigation frame, sidebar, and modals
├── core/
│   ├── constants/            # Design tokens (colors, typography, radii, spacing)
│   ├── database/             # SQLite FFI manager, schema migrations, and table definitions
│   ├── intelligence/         # Local ML & heuristic algorithms (categorizer, predictor, etc.)
│   ├── services/             # Backup Export/Import & Toast notification dispatchers
│   └── utils/                # Date formatting and helper utilities
├── data/
│   └── repositories/         # SQLite implementations of domain repository interfaces
├── domain/
│   ├── models/               # Pure Dart domain entities (Task, Project, Workout, Note, etc.)
│   └── repositories/         # Abstract repository contracts
└── presentation/
    ├── state/                # State management via Provider (WorkspaceController, SearchController)
    ├── views/                # Screen views (Home, Tasks, Projects, Content, Notes, Shopping, Settings)
    └── widgets/              # Reusable glassmorphic UI components, modals, and drawers
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`^3.12.2` or later)
- [Dart SDK](https://dart.dev/get-dart) (`^3.0.0`)
- **Platform Build Tools**:
  - **Windows**: [Visual Studio 2022](https://visualstudio.microsoft.com/) with the **"Desktop development with C++"** workload.
  - **macOS**: Xcode with Command Line Tools.
  - **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`.

### Installation & Running

1. **Clone the repository**:
   ```bash
   git clone https://github.com/kareemxmhmd/Burn_shut.git
   cd Burn_shut
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run in development mode**:
   ```bash
   # Windows Desktop
   flutter run -d windows

   # macOS Desktop
   flutter run -d macos

   # Linux Desktop
   flutter run -d linux
   ```

### Building for Production

#### Quick Build (Windows):
Double-click or run the included build script:
```cmd
build_windows_exe.bat
```

#### Manual Build (Flutter CLI):
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

Compiled Windows binary will be available at:
`build/windows/x64/runner/Release/burn_think.exe`

---

## 🧪 Automated Testing

Burn Think includes a test suite covering SQLite FFI persistence, intelligence algorithms, controller state transitions, and widget rendering.

```bash
# Run all automated tests
flutter test

# Run tests with detailed verbose output
flutter test --reporter expanded
```

### Test Coverage Highlights:
- **Persistence**: SQLite CRUD transactions, foreign key cascading, and database migrations.
- **Intelligence**: Keyword heuristics, category override feedback loops, priority scoring, token search, and similarity detection.
- **Controller & Undo**: Deletion and restoration lifecycles, project milestone recalculation, and search indexing.
- **UI & Navigation**: AppShell sidebar navigation, modal dialogs, and intelligence indicator rendering.

---

## ⌨️ Shortcuts & Desktop Interactions

| Action | Shortcut / Trigger | Description |
| :--- | :--- | :--- |
| **Quick Add Item** | `+` Button on Top Header | Opens the intelligent quick-capture modal with real-time categorization. |
| **Global Search** | `Search` Button on Top Header | Opens the multi-token search dialog across all workspace items. |
| **Dismiss Modal / Drawer** | `Esc` Key / Click Backdrop | Instantly closes any active dialog, quick-add modal, or detail drawer. |
| **Toggle Completion** | Click Checkbox / Status Icon | Marks task, project milestone, or shopping item as completed. |
| **Inspect Details** | Click any item card / row | Slides open the contextual detail drawer for in-depth editing. |
| **Restore Item** | Click `Restore` in Completed Archive | Returns archived items back to their active workspace. |

---

## 🌍 نظرة عامة باللغة العربية (Arabic Overview)

### ما هو تطبيق Burn Think؟
**Burn Think** هو تطبيق مكتبي متطور (Desktop Application) فائق السرعة والخفة، تم بناؤه باستخدام إطار عمل **Flutter** وقاعدة بيانات **SQLite** المحلية عبر واجهة FFI.

صُمم التطبيق خصيصاً للتخلص من التشتت والعبء الذهني (**Mental Clutter & Cognitive Overload**)، من خلال دمج كافة جوانب تنظيم حياتك اليومية وأفكارك في بيئة عمل موحدة وتفاعلية ذات تصميم زجاجي داكن مريح للعين أثناء جلسات العمل والتركيز الطويلة.

---

### 🌟 أبرز مميزات التطبيق

1. **⚡ سرعة واستجابة فورية (Zero Latency)**: يعمل التطبيق بالكامل على جهازك دون أي اتصال بسيرفرات خارجية أو تأخير شبكة.
2. **🔒 خصوصية تامة 100% (Local & Private)**: جميع بياناتك وملاحظاتك وخططك تُحفظ محلياً في قاعدة بيانات SQLite داخل جهازك فقط.
3. **🧠 محرك ذكاء اصطناعي محلي (On-Device Intelligence)**:
   - **التصنيف الذكي (Smart Categorization)**: يتعرف تلقائياً على نوع العنصر أثناء الإدخال السريع (مهمة، مشروع، تمرين، محتوى، ملاحظة، مشتريات).
   - **اقتراح أولويات اليوم (Today's Focus)**: يرتب المهام الأكثر إلحاحاً وأهمية لتبدأ بها يومك فوراً بناءً على معادلات تقييم متعددة العوامل.
   - **اكتشاف العناصر المكررة والمرتبطة (Duplicate & Related Detection)**: يمنع تكرار المهام ويقترح ربطها بالمشاريع الحالية.
   - **البحث الشامل والفوري (Semantic & Multi-Token Search)**: بحث سريع يبحث داخل العناوين والملاحظات والوسوم في أجزاء من الثانية.
   - **تحليلات الأداء والسلوك (Behavior Analytics)**: حساب معدلات الإنجاز الأسبوعية والزمن المستغرق للمهام محلياً.

---

### 📂 مساحات العمل المتخصصة

- **🏠 لوحة التحكم الرئيسية (Home Dashboard)**: تعرض مؤشرات التركيز اليومي، ملخص الأنشطة، والمشاريع النشطة ونسبة تقدمها.
- **📋 إدارة المهام (Tasks)**: جدولة المهام حسب الأولويات (`عاجل`، `مرتفع`، `متوسط`، `منخفض`) مع تواريخ الاستحقاق.
- **🚀 إدارة المشاريع (Projects)**: تفكيك المشاريع الكبيرة إلى خطوات تنفيذية ومراحل (Milestones) مع احتساب نسبة الإنجاز تلقائياً.
- **🏋️ التمارين الرياضية (Workouts)**: بناء جداول التمارين اليومية مع تتبع المجموعات (Sets)، التكرارات (Reps)، الأوزان، والعضلات المستهدفة.
- **🎬 مسار صناعة المحتوى (Content Pipeline)**: متابعة أفكار الفيديوهات والمنشورات عبر مراحل الإنتاج (`فكرة` ➔ `كتابة السكريبت` ➔ `قيد الإنتاج` ➔ `تم النشر`) مع وسوم المنصات (YouTube, X, TikTok, LinkedIn وغيرها).
- **📝 الملاحظات (Notes)**: مساحة سريعة لتدوين الأفكار والمقتطفات البرمجية وتثبيت الملاحظات الهامة.
- **🛒 قائمة المشتريات (Shopping)**: تتبع المنتجات والكميات والتكلفة التقديرية وتحديد ما تم شراؤه بنقرة واحدة.
- **📦 الأرشيف المكتمل (Completed Archive)**: سجل تدقيق موحد لكافة المهام والمشاريع والمشتريات المنجزة مع إمكانية الاستعادة الفورية.
- **⚙️ الإعدادات والنسخ الاحتياطي (Settings & Backup)**: تصدير واستيراد كامل بيانات مساحة العمل بصيغة JSON بأمان وسهولة (مع دعم الدمج Merge أو الاستبدال Replace).

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.
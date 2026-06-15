# Flutter UI Architecture & Optimization Guide
### Principal Architect Reference — Clean Architecture · BLoC · Material Design 3

---

## Table of Contents
1. [Strict UI Architectural Rules](#1-strict-ui-architectural-rules)
2. [Deep Widget Optimization Guidelines](#2-deep-widget-optimization-guidelines)
3. [SOLID & Clean Code in UI](#3-solid--clean-code-in-ui)

---

## 1. Strict UI Architectural Rules

### 1.1 The Absolute Boundary: Presentation vs. Business Logic

The presentation layer is a **pure, reactive function of state**. It renders state; it never owns, mutates, or derives it.

```
[ Domain Layer ]  →  [ Application Layer / BLoC ]  →  [ Presentation Layer ]
   Entities            Events, States, UseCases         Widgets (render only)
```

#### Smart vs. Dumb Widget Contract

| Concern | Smart Widget (`screen` / `Page`) | Dumb Widget (`Component` / `Widget`) |
|---|---|---|
| **Alias** | Feature Widget, Container | Presentational Widget, Leaf |
| **Knows about BLoC?** | ✅ Yes — reads & dispatches | ❌ Never |
| **Knows about GoRouter?** | ✅ Initiates navigation | ❌ Never |
| **Receives data via** | `BlocBuilder` / `context.read` | Constructor parameters only |
| **Has side effects?** | ✅ Via `BlocListener` | ❌ Never |
| **Is `const`-constructible?** | Rarely | Always aim for it |
| **File location** | `features/X/presentation/screens/` | `features/X/presentation/widgets/` or `core/widgets/` |
| **Testability** | Integration/widget tests | Pure widget unit tests |

---

### DO vs. DON'T — Architectural Boundaries

**❌ DON'T: Inject BLoC or BuildContext side-effects into a Dumb Widget**
```dart
// VIOLATION: Dumb widget reaching into the widget tree
class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 🔴 FORBIDDEN: A presentational widget must never read a BLoC.
    // This creates hidden coupling, makes testing impossible,
    // and pollutes the reusability contract.
    final bloc = context.read<CartBloc>();
    return ElevatedButton(
      onPressed: () => bloc.add(AddToCartEvent(productId)),
      child: const Text('Add to Cart'),
    );
  }
}
```

**✅ DO: Pass callbacks and data from Smart to Dumb via constructor**
```dart
// CORRECT: Dumb widget is a pure function of its inputs.
// The Smart widget owns the BLoC interaction; Dumb widget owns the UI.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart, // Callback injected from the Smart layer
  });

  final Product product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) { /* ... pure UI ... */ }
}
```

---

**❌ DON'T: Navigate from a Dumb Widget**
```dart
class SettingsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.go('/profile'), // 🔴 FORBIDDEN: navigation in a leaf widget
    );
  }
}
```

**✅ DO: Expose `onTap` and let the Smart View navigate**
```dart
class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label), onTap: onTap); // ✅ Pure UI
  }
}

// In the Smart View:
SettingsRow(
  label: 'Edit Profile',
  onTap: () => context.go(AppRoutes.profile), // ✅ Navigation owned by the View
)
```

---

**❌ DON'T: Perform business logic inside `build()`**
```dart
// 🔴 FORBIDDEN: Deriving state inside the widget — belongs in BLoC/UseCase
Widget build(BuildContext context) {
  final total = cartItems.fold(0.0, (sum, item) => sum + item.price * item.qty);
  final isEligibleForDiscount = total > 100 && user.isPremium;
  // ...
}
```

**✅ DO: Consume pre-computed state properties from the BLoC State class**
```dart
// In the BLoC State:
// class CartState { final double total; final bool isEligibleForDiscount; }

// In the widget — pure rendering:
Widget build(BuildContext context) {
  return BlocBuilder<CartBloc, CartState>(
    builder: (context, state) => Text('\$${state.total.toStringAsFixed(2)}'),
  );
}
```

---

## 2. Deep Widget Optimization Guidelines

### 2.1 Aggressive `const` Constructors

`const` widgets are instantiated **once** and reused from a compile-time constant pool. Flutter's reconciler will **skip diffing** them entirely if the parent rebuilds.

**❌ DON'T: Prevent `const` through runtime values or missing keywords**
```dart
// 🔴 Loses const eligibility — the Color literal is fine but the
// Text widget is not marked const, forcing re-instantiation on every rebuild.
class MyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Dashboard', style: TextStyle(fontSize: 24)), // 🔴 Not const
        SizedBox(height: 16),                              // 🔴 Not const
        Divider(),                                         // 🔴 Not const
      ],
    );
  }
}
```

**✅ DO: Mark every eligible widget and constructor `const`**
```dart
class MyHeader extends StatelessWidget {
  const MyHeader({super.key}); // ✅ const constructor

  @override
  Widget build(BuildContext context) {
    return const Column( // ✅ const propagates to all children
      children: [
        Text('Dashboard', style: TextStyle(fontSize: 24)),
        SizedBox(height: 16),
        Divider(),
      ],
    );
  }
}
```

> **Rule:** Run `dart fix --apply` and treat `prefer_const_constructors` and
> `prefer_const_literals_to_create_immutables` lint warnings as **errors**.

---

### 2.2 Widget Classes vs. Helper Methods

Helper methods (`_buildHeader()`) execute inside the parent's `build()` scope. They are **not** widgets — Flutter cannot independently track, cache, or skip them. Every parent rebuild calls every helper method, unconditionally.

**❌ DON'T: Use private helper methods for non-trivial UI fragments**
```dart
class ProductView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeader(),   // 🔴 Rebuilt unconditionally with ProductView
      _buildBody(),     // 🔴 Cannot be individually optimized
      _buildFooter(),   // 🔴 No independent lifecycle or key management
    ]);
  }

  Widget _buildHeader() => Text('Products'); // Part of ProductView's element
}
```

**✅ DO: Extract independent widget classes**
```dart
class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      _ProductHeader(), // ✅ Independent element in the tree
      _ProductBody(),   // ✅ Can be individually keyed, constified, and optimized
      _ProductFooter(), // ✅ Flutter can skip reconciliation independently
    ]);
  }
}

// Each is its own widget class — private to the file if needed
class _ProductHeader extends StatelessWidget {
  const _ProductHeader();
  @override
  Widget build(BuildContext context) => const Text('Products');
}
```

> **Exception:** Simple, stateless, inline expressions (e.g., a single `Text`)
> with no meaningful subtree are acceptable inline — but the moment a fragment
> has >2 children or any logic, extract it to a class.

---

### 2.3 Targeted Rebuilds with `buildWhen`

`BlocBuilder` without `buildWhen` rebuilds on **every state emission**, even if the widget only cares about one field.

**❌ DON'T: Let `BlocBuilder` rebuild on unrelated state changes**
```dart
BlocBuilder<OrderBloc, OrderState>(
  // 🔴 This entire subtree rebuilds when ANY field in OrderState changes,
  // including totalItems, filters, pagination, loading flags — everything.
  builder: (context, state) {
    return OrderStatusBadge(status: state.status);
  },
)
```

**✅ DO: Use `buildWhen` to gate rebuilds on relevant field changes**
```dart
BlocBuilder<OrderBloc, OrderState>(
  // ✅ This subtree ONLY rebuilds when `status` actually changes.
  // All other state mutations are invisible to this widget.
  buildWhen: (previous, current) => previous.status != current.status,
  builder: (context, state) {
    return OrderStatusBadge(status: state.status);
  },
)
```

**Advanced Pattern — Compose multiple scoped builders:**
```dart
// Instead of one large BlocBuilder wrapping the whole screen,
// scope each builder to the exact slice of state it needs.
class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Rebuilds ONLY when status changes
      BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (p, c) => p.status != c.status,
        builder: (_, s) => OrderStatusBadge(status: s.status),
      ),
      // Rebuilds ONLY when loading changes
      BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (p, c) => p.isLoading != c.isLoading,
        builder: (_, s) => s.isLoading
            ? const LinearProgressIndicator()
            : const SizedBox.shrink(),
      ),
      // This widget is const — never rebuilds at all
      const _StaticOrderInfo(),
    ]);
  }
}
```

## 🏁 Decision Rule

* Single field → `BlocSelector`
* Derived/simple UI → `BlocSelector`
* Complex condition → `buildWhen`
* Multiple unrelated UI parts → multiple `BlocSelector`

---

### 2.4 Advanced Render Optimization

#### `RepaintBoundary` — Isolate Expensive Subtrees

`RepaintBoundary` promotes its child to its own **compositor layer**. When that child repaints (e.g., an animation), the parent layer is **not composited again**.

```dart
// ✅ Use when: a child animates independently (lottie, shimmer, video thumbnail)
// and the parent is expensive to composite (long lists, complex overlays).
ListView.builder(
  itemBuilder: (context, index) {
    return RepaintBoundary(
      // ✅ Each card repaints in isolation. Scrolling one card doesn't
      // trigger repaint of its siblings' layers.
      child: ProductCard(product: products[index]),
    );
  },
)
```

> **Warning:** `RepaintBoundary` has a memory cost (one texture per layer).
> Profile with `flutter run --profile` and `DevTools > Repaint Rainbow`
> **before** adding them speculatively. Target widgets that repaint frequently
> and independently.

---

#### `CustomPaint` Optimization

```dart
// ❌ DON'T: Recalculate paths inside paint() — called every frame
class BadChart extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path(); // 🔴 Allocated every frame
    for (final point in dataPoints) {
      // 🔴 Heavy computation on the raster thread every frame
      path.lineTo(computeX(point, size), computeY(point, size));
    }
    canvas.drawPath(path, _paint);
  }
}

// ✅ DO: Pre-compute paths; use shouldRepaint to guard re-paints
class OptimizedChart extends CustomPainter {
  OptimizedChart({required this.dataPoints, required this.color})
      : _path = _buildPath(dataPoints); // ✅ Computed once on construction

  final List<DataPoint> dataPoints;
  final Color color;
  final Path _path; // ✅ Cached path

  // ✅ Only accepts a new path when data actually changes
  static Path _buildPath(List<DataPoint> points) {
    final path = Path();
    // ... build path from points
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ✅ paint() only draws — no computation
    canvas.drawPath(_path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(OptimizedChart old) =>
      old.dataPoints != dataPoints || old.color != color; // ✅ Fine-grained guard
}
```

---

#### Slivers for Complex Scrolling

Never nest `ListView` inside `SingleChildScrollView`. Use a unified `CustomScrollView` with Slivers.

```dart
// ✅ Production-grade scrolling architecture
CustomScrollView(
  slivers: [
    // Collapsing app bar — zero cost when not visible
    SliverAppBar.large(
      title: const Text('Discover'),
      floating: true,
      pinned: true,
    ),

    // Static header section — rendered as a single sliver box
    const SliverToBoxAdapter(child: _FeaturedBanner()),

    // Section title
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Text('Popular', style: Theme.of(context).textTheme.titleMedium),
      ),
    ),

    // Lazily built grid — only builds visible items
    SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => RepaintBoundary( // ✅ Independent repaint per card
          child: ProductCard(product: products[index]),
        ),
        childCount: products.length,
      ),
    ),

    // Loading footer
    const SliverToBoxAdapter(child: _PaginationFooter()),

    // Bottom safe area
    const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
  ],
)
```

---

## 3. SOLID & Clean Code in UI

### 3.1 Single Responsibility Principle (SRP)

> *A widget class should have one reason to change.*

Each widget has **one job**: render one logical UI concept. If you find yourself naming a widget `ProfileHeaderAndStatsAndBadgeRow`, it violates SRP.

```
ProfileScreen (Smart — owns BLoC integration)
├── ProfileHeader (Dumb — renders avatar + name)
├── ProfileStatRow (Dumb — renders a single stat metric)
│   └── _StatChip (private — renders one chip)
└── ProfileBadgeGrid (Dumb — renders badge collection)
    └── BadgeItem (Dumb — renders one badge)
```

**Practical rule:** If a widget's `build()` method exceeds ~40 lines, it almost certainly violates SRP and should be decomposed.

---

### 3.2 Open-Closed Principle (OCP)

> *Widgets should be open for extension (via parameters/slots) but closed for modification.*

Instead of modifying a `AppCard` widget every time you need a variant, design it with **slot parameters** (`leading`, `trailing`, `footer`) that accept `Widget?`. New consumers extend behavior without touching the base class.

```dart
// ❌ DON'T: Hard-code variants with conditionals — forces modification
class AppCard extends StatelessWidget {
  final bool showDeleteButton; // 🔴 Every new feature adds another flag
  final bool showShareIcon;
  final bool hasImageHeader;
  // This class has infinite reasons to change — violates OCP
}

// ✅ DO: Use widget slots — consumers extend without modifying
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.leading,   // ✅ Extension point — any widget
    this.trailing,  // ✅ Extension point — any widget
    this.footer,    // ✅ Extension point — any widget
    this.onTap,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;
  // ...
}

// Usage — extended without modifying AppCard:
AppCard(
  leading: const ProductThumbnail(),
  trailing: const WishlistToggle(),
  footer: const PriceRow(),
  child: ProductDescription(),
)
```

---

## Quick Reference — Rules Summary

### Architecture

| ✅ DO | ❌ DON'T |
|---|---|
| Keep BLoC interactions in Smart Views only | Access BLoC from Dumb/reusable widgets |
| Pass data and callbacks via constructors | Pass `BuildContext` into Dumb widgets |
| Navigate via GoRouter in Smart Views | Call `context.go()` from leaf widgets |
| Derive state in BLoC State classes | Compute derived values inside `build()` |
| Register BLoCs at route level | Create BLoCs inside `build()` |

### Optimization

| ✅ DO | ❌ DON'T |
|---|---|
| Mark every eligible widget `const` | Leave `const` as an afterthought |
| Extract non-trivial UI to widget classes | Use `_buildX()` helper methods |
| Use `buildWhen` on all `BlocBuilder`s | Let `BlocBuilder` rebuild freely |
| Use `MediaQuery.sizeOf` for layout | Use `MediaQuery.of` for size alone |
| Scope `RepaintBoundary` with profiling | Add `RepaintBoundary` speculatively |
| Pre-compute paths in `CustomPainter` | Allocate paths in `paint()` |
| Use `CustomScrollView` + Slivers | Nest `ListView` in `SingleChildScrollView` |

### Code Quality

| ✅ DO | ❌ DON'T |
|---|---|
| Design widgets with slot parameters | Add variant booleans to base classes |
| One widget class = one UI concept | Build God widgets with 200+ line `build()` |
| Co-locate private helpers with their owner | Share implementation details across files |
| Read BLoC before async gaps in listeners | Use `context` after `await` without guard |
| Run `dart fix --apply` in CI | Ignore `prefer_const_*` lint warnings |

---

*Flutter Principal Architect Reference · Material Design 3 · Clean Architecture · BLoC*

# Entity & Model Separation

## Overview

To preserve Clean Architecture boundaries, **Entities and Models must always be separate classes**.

The Domain layer should never receive or depend on Data layer implementations. All conversions between Models and Entities must happen inside the Repository layer.

---

# Architecture

```
Presentation
      │
      ▼
    Domain
      │
      ▼
 Repository
      │
      ▼
 Data Source
```

```
Domain
└── UserEntity

Data
└── UserModel
```

The `UserModel` is a data representation responsible for serialization and deserialization, while the `UserEntity` represents the business object used by the Domain layer.

---

# Rules

## 1. Models MUST NOT extend Entities

✅ Correct

```dart
class UserEntity extends Equatable {
  ...
}

class UserModel extends Equatable {
  ...
}
```

❌ Incorrect

```dart
class UserModel extends UserEntity {
  ...
}
```

Inheritance allows Data layer implementations to leak into the Domain layer and breaks architectural isolation.

---

## 2. Models are responsible for external data mapping

Models may contain:

* `fromJson()`
* `toJson()`
* `fromDocument()`
* `toEntity()`
* `fromEntity()`
* Other external data mapping logic

Example:

```dart
class UserModel extends Equatable {
  factory UserModel.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson();
}
```

---

## 3. Models MUST provide Entity mapping

Every Model should expose conversion methods:

```dart
UserEntity toEntity()
factory UserModel.fromEntity(UserEntity entity);
```

Example:

```dart
class UserModel extends Equatable {
  factory UserModel.fromEntity(UserEntity entity);

  UserEntity toEntity() {
    ...
  }
}
```

---

## 4. Repository is the mapping boundary

Repositories are responsible for converting Models into Entities.

```
DataSource
    │
    ▼
 UserModel
    │
Repository
    │ toEntity()
    ▼
 UserEntity
    │
 Domain
```

Example 1:

✅ Correct

```dart
final model = await remote.signIn();
return Right(model.toEntity());
```

❌ Incorrect

```dart
final model = await remote.signIn();
return Right(model);
```

---

Example 2:

✅ Correct

```dart
Stream<UserEntity?> watchAuthState() {
  return remote.watchAuthState().map(
    (model) => model?.toEntity(),
  );
}
```

❌ Incorrect

```dart
Stream<UserEntity?> watchAuthState() {
  return remote.watchAuthState();
}
```

---

# Dependency Direction

```
Presentation
      │
      ▼
Domain (Entity)
      ▲
      │
Repository
      │
      ▼
Data (Model)
```

* Domain knows only Entities.
* Data knows both Models and Entities.
* Presentation knows only Domain objects.
* Models never leave the Data layer.

---

# Benefits

* Strong layer isolation
* No Data layer leakage
* Easier testing and mocking
* Safer refactoring
* Better maintainability
* Predictable dependency flow
* Full compliance with Clean Architecture principles

---

# Checklist

Before creating a new feature, verify the following:

* [ ] Entity and Model are separate classes.
* [ ] Model does not extend Entity.
* [ ] Model contains serialization logic only.
- [ ] Model exposes `toEntity()` and `fromEntity()`.
- [ ] Data Sources expose Models only.
* [ ] Repository performs all Model → Entity mapping.
* [ ] No Model is returned outside the Data layer.
* [ ] All Streams are mapped from Model to Entity before leaving the Repository.

---

# Guiding Principle

> **Entities represent business concepts. Models represent external data structures.**
>
> **Repositories are the only place where conversion between them is allowed.**

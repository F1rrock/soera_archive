# SOERA archive

## Description

This module cause a gateway, which provides Linux OS Shell look like API to get access for company resources, that stored in archive realization.

## Usage

first, you have to opt the bus, which provides API for required resource. Example, if you want access MySQL DB resources: 
```dart
final Bus<AppConfig> appBus = MySqlViaArchiveExampleClass();
```

Then, you have to achive config of the application
```dart
final AppConfig config = appBus.config();
```

now, you can access to existing console implementation and implementations of directives and exes via the entity type.
```dart
final Console console = config.console;

try {
    final Executable ls = config.executable<LS>();
} catch (_) {
    ...
}

try {
    final Directive cd = config.directive<CD>();
} catch (_) {
    ...
}
```

`executable` and `directive` methods can throw an `EntityNotFound` exception, which you have to handle every time, that you try to access resource by type.
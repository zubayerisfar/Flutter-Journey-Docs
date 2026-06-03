# Object-Oriented Programming in Dart: Core Concepts

---

## 1. Encapsulation

**Concept:** Encapsulation means bundling data (variables) and methods that work with that data into a single unit, while hiding the internal details. You control what's visible from outside and what's hidden. In Dart, private variables (with `_` prefix) and getter/setter methods achieve this.

**What it solves:** You have a bank account. You can't directly change the balance—you use withdraw() and deposit() methods so the bank can validate and log every transaction.

**Scenario:** Your user's profile has an age. You want to ensure no one accidentally sets it to -5 or 500. Without encapsulation, any part of your code could break this.

```dart
class UserProfile {
  int _age = 0;  // Private - hidden from outside

  int get age => _age;

  set age(int value) {
    if (value >= 0 && value <= 120) {
      _age = value;  // Only valid values allowed
    }
  }
}

void main() {
  var user = UserProfile();
  user.age = 25;      // Works - uses setter with validation
  print(user.age);    // 25 - uses getter
  // user._age = -5;  // ERROR - cannot access private variable
}
```

**Why it matters:** You can add validation, logging, or side effects in the setter without changing external code. Tomorrow, if you need to log age changes, modify only the setter.

---

## 2. Static Keyword

**Concept:** The `static` keyword declares members that belong to the class itself, not to individual instances. There's only one copy shared across all objects. If 100 users exist, they all share the same static variable—it's not duplicated 100 times in memory.

**What it solves:** You're building an app and need to count how many users have been created across the entire application.

**Scenario:** Every time you create a new User, the total count increases globally. This count belongs to the User class itself, not to individual user objects.

```dart
class User {
  static int totalUsers = 0;  // Shared across ALL instances
  String name;

  User(this.name) {
    totalUsers++;  // Increment whenever a user is created
  }
}

void main() {
  User user1 = User('Alice');
  User user2 = User('Bob');
  User user3 = User('Charlie');

  print(User.totalUsers);  // 3 - accessed via class name, not instance
}
```

**Key difference:**
- Instance variable: Each object has its own copy
- Static variable: All objects share the same copy (only one in memory)

---

## 3. Factory Constructor

**Concept:** A factory constructor is a special constructor that doesn't always create a new object. It can return an existing object, apply custom logic before creation, or even return a different type. It uses the `factory` keyword and has more flexibility than a regular constructor.

**What it solves:** Creating students in your app. Some students are real users, others are guests. You want different initialization logic for each case.

**Scenario:** Instead of forcing everyone to write `Student('Guest', 18)` manually, provide a shortcut: `Student.guest()`.

```dart
class Student {
  String name;
  int age;

  Student(this.name, this.age);

  // Factory constructor - custom creation logic
  factory Student.guest() {
    return Student('Guest User', 18);
  }
}

void main() {
  var realStudent = Student('Ahmed', 20);
  var guestStudent = Student.guest();  // Shortcut - returns pre-filled student

  print(realStudent.name);     // Ahmed
  print(guestStudent.name);    // Guest User
}
```

**When to use:**
- Multiple ways to create an object
- Need to return an existing instance instead of creating new
- Complex initialization logic

---

## 4. Singleton Pattern

**Concept:** The Singleton pattern ensures that a class has exactly one instance throughout the app's lifetime. No matter how many times you request it, you get the same object. It combines a private constructor, a static instance, and a factory constructor to enforce this rule.

**What it solves:** Your app has a database. You don't want 10 different database connections running simultaneously—that's wasteful and causes inconsistency.

**Scenario:** No matter how many times you request `Database()`, the app returns the same single instance.

```dart
class Database {
  static final Database _instance = Database._create();

  Database._create() {
    print("Database instance created (only once)");
  }

  factory Database() {
    return _instance;  // Always returns the same instance
  }

  void connect() => print('Connected to database');
}

void main() {
  var db1 = Database();
  var db2 = Database();
  var db3 = Database();

  print(db1 == db2);  // true - same object
  print(db2 == db3);  // true - same object
  // Output: "Database instance created (only once)" - printed once, not 3 times
}
```

**When to use:**
- Database connections
- Logger service
- Configuration manager
- Authentication service

---

## 5. Mixins

**Concept:** A mixin is a class that provides methods to be used by other classes without requiring inheritance. Think of it as adding capabilities to a class. Multiple mixins can be combined with `with` keyword. Unlike inheritance (is-a relationship), mixins express has-capability relationships.

**What it solves:** You have UserService, PaymentService, and EmailService. All need logging. Without mixins, you'd duplicate logging code in each, or create an awkward inheritance chain.

**Scenario:** Mix the Logger functionality into any class that needs it.

```dart
mixin Logger {
  void log(String message) => print("LOG: $message");
}

class UserService with Logger {
  void createUser(String name) {
    log("Creating user: $name");  // Can use log() directly
  }
}

class PaymentService with Logger {
  void processPayment(double amount) {
    log("Processing payment: \$$amount");  // Same method, different service
  }
}

void main() {
  UserService().createUser('Ahmed');
  PaymentService().processPayment(99.99);
  // Output:
  // LOG: Creating user: Ahmed
  // LOG: Processing payment: $99.99
}
```

**Comparison with Inheritance:**

| | Inheritance | Mixins |
|---|---|---|
| Relationship | Dog **is-a** Animal | Dog **has-capability** to bark |
| Multiple | Single parent only | Multiple mixins allowed |
| Use case | Related classes (hierarchy) | Shared behavior (cross-cutting) |

---

## 6. Extension Methods

**Concept:** Extension methods let you add new methods to existing classes without modifying their source code. You can extend built-in types like `int`, `String`, `List`, or even third-party classes. They're purely compile-time features—Dart converts them to static function calls.

**What it solves:** The built-in `int` class doesn't have an `isEven()` method. Instead of creating wrapper classes, add the method directly.

**Scenario:** You want to check if a number is even: `4.isEven()` instead of `isEven(4)`.

```dart
extension NumberCheck on int {
  bool isEvenNumber() => this % 2 == 0;
  bool isOdd() => this % 2 != 0;
}

void main() {
  print(4.isEvenNumber());   // true
  print(5.isOdd());          // true
  print(10.isEvenNumber());  // true
}
```

**Key point:** You're not modifying the `int` class—you're adding utility methods that feel natural to use. Only available where you import this extension.

---

## 7. Operator Overloading

**Concept:** Operator overloading allows you to define custom behavior for operators like `==`, `+`, `-`, `[]` when applied to your classes. By overriding operator methods, you make objects work naturally with standard operators. The most commonly overridden is `==` for value comparison.

**What it solves:** You created a Student class. Two students with the same name and age should be considered equal, but by default `==` checks object identity, not values.

**Scenario:** Compare students by their data, not memory address.

```dart
class Student {
  String name;
  int age;

  Student(this.name, this.age);

  @override
  bool operator ==(Object other) {
    return other is Student && name == other.name && age == other.age;
  }

  @override
  String toString() => "Student($name, $age)";
}

void main() {
  var studentA = Student('Reduan', 22);
  var studentB = Student('Reduan', 22);

  print(studentA == studentB);  // true - same name & age
  print(studentA);              // Student(Reduan, 22)
}
```

**Common operators to override:**

| Operator | Use |
|---|---|
| `==` | Compare objects by value |
| `+` | Add two objects |
| `<` | Compare for sorting |
| `[]` | Index access |
| `toString()` | String representation |

---

## 8. Copy Constructor Pattern

**Concept:** A copy constructor is a named constructor that creates an independent copy of an existing object. It uses an initializer list (`:` syntax) to copy properties. This creates a new object with the same data, not a reference to the original.

**What it solves:** You have a task object and want to create a modified copy without affecting the original. Simple assignment creates a reference, not a copy.

**Scenario:** Create a task draft for editing while keeping the original safe.

```dart
class Base {
  String name;
  int age;

  Base(this.name, this.age);

  // Copy constructor - create independent copy
  Base.copyWith(Base obj) : name = obj.name, age = obj.age;
}

void main() {
  var base1 = Base('Zubayer', 30);
  var base2 = Base.copyWith(base1);

  // Modify copy without affecting original
  base2.name = 'Ahmed';

  print(base1.name);  // Zubayer (unchanged)
  print(base2.name);  // Ahmed (changed)
}
```

**Comparison:**

| | Simple Assignment | Copy Constructor |
|---|---|---|
| Creates new object | No (reference) | Yes (duplicate) |
| Modifying affects original | Yes | No |
| Syntax | `var copy = original;` | `var copy = Base.copyWith(original);` |

---

## Quick Decision Guide

| Need | Use |
|---|---|
| Hide internal data & add validation | Encapsulation |
| Count/share data across all objects | Static |
| Multiple ways to create an object | Factory Constructor |
| Single shared resource (DB, Logger) | Singleton |
| Shared behavior across unrelated classes | Mixins |
| Add method to existing type | Extension |
| Make `==` or `+` work naturally | Operator Overloading |
| Create safe copy of object | Copy Constructor |

---

## How They Work Together

These concepts layer on top of each other:

1. **Foundation:** Encapsulation (always) + Static (when needed)
2. **Creation:** Regular or Factory Constructor, plus Copy if needed
3. **Behavior:** Operator Overloading for intuitive operations
4. **Code reuse:** Mixins for cross-cutting, Extensions for utilities
5. **Patterns:** Singleton for shared resources

The best code uses the right tool for the job. A complex app might use all of them—each solving a specific problem.
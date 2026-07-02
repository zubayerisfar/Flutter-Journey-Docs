# Flutter SQLite Task Manager

A local task management app built with Flutter and `sqflite`. Tasks are stored on-device using SQLite — no backend, no internet required. Supports full CRUD: create, read, update, and delete tasks, with a checkbox to mark them done.

---

## Screenshots / Demo

| Consistent Storage | Update Task | Delete Task |
|----------|-------------|-------------|
| ![Consistent Storage](asset/consistant_storage.gif) | ![Update Task](asset/update_task.gif) | ![Delete Task](asset/delete_task.gif) |

---

## Project Structure

```
lib/
├── main.dart
├── my_app.dart
├── db/
│   └── database.dart
├── model/
│   └── task_model.dart
└── pages/
    └── home_page.dart
```

---

## How It Works

The app has three layers:

- **Model** (`task_model.dart`) — defines what a task looks like and how it converts to/from a database row.
- **Database layer** (`database.dart`) — owns the single SQLite connection and exposes CRUD methods.
- **UI layer** (`home_page.dart`) — calls those database methods in response to user actions and rebuilds the screen.

There's also an **entry point** (`main.dart`) and a small **app shell** (`my_app.dart`) that wire everything together. Each file is shown in full below, followed by a walkthrough of what it does and how it connects to the others.

---

## `main.dart` — Entry Point

```dart
import 'package:flutter/material.dart';
import 'my_app.dart';

void main() {
  runApp(const MyApp());
}
```

This is the smallest possible Flutter entry point. `main()` is where every Dart program starts execution. `runApp()` takes a widget and makes it the root of the entire widget tree — everything you see on screen is a descendant of whatever is passed here. In this project that's `MyApp`, defined in `my_app.dart`.

`const MyApp()` uses a `const` constructor because `MyApp` doesn't take any arguments that change at runtime — this lets Flutter skip rebuilding it unnecessarily, a small performance win.

---

## `my_app.dart` — App Shell

```dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}
```

`MyApp` is a `StatelessWidget` because it never needs to change after it's built — it just configures the app once and hands off to `HomePage`, which is where all the actual state and logic live.

`MaterialApp` is the standard Flutter wrapper that gives you Material Design defaults: theming, navigation, text direction, and so on. Three things are configured here:

- `title` — used by the OS (e.g. in the app switcher), not shown inside the app itself.
- `theme` — sets a blue color scheme app-wide via `ThemeData`.
- `home` — the first screen shown when the app launches, set to `HomePage()`.

Everything below this point is really about what happens inside `HomePage`.

---

## `task_model.dart` — The Model

```dart
class TaskModel {
  final int? id;
  final String title;
  final bool isDone;

  TaskModel({this.id, required this.title, required this.isDone});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'isDone': isDone ? 1 : 0};
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
    );
  }
}
```

`TaskModel` is a plain Dart class representing a single task, with three fields:

- `id` — `int?` (nullable), because a task created in memory before being saved doesn't have a database-assigned id yet. SQLite assigns it once the row is inserted.
- `title` — the task text.
- `isDone` — whether the task is checked off.

All three fields are `final`, meaning a `TaskModel` is immutable once created. Instead of mutating a task in place, the app builds a brand-new `TaskModel` with the changed value (you'll see this pattern repeatedly in `home_page.dart`).

SQLite doesn't have a native boolean type — it only understands integers — so `isDone` needs a translation step in both directions:

- **`toMap()`** turns the object into a `Map<String, dynamic>` that `sqflite` can write to disk. `isDone` becomes `1` or `0`.
- **`fromMap()`** is a **factory constructor** that takes a raw row (a `Map`, as returned by a SQL query) and reconstructs a `TaskModel` from it, converting `1`/`0` back into `true`/`false` via `map['isDone'] == 1`.

`fromMap` has to be a `factory` constructor rather than a normal one because it doesn't just assign fields directly from its parameters — it receives a `Map` and has to extract and transform values out of it before calling the real constructor. This is the standard Dart pattern for deserializing from JSON or database rows.

**Where these are used:** `toMap()` is called inside every write operation in `database.dart` (`insertTask`, `updateTask`). `fromMap()` is called inside `getTasks()` to convert each raw row back into a `TaskModel` the UI can render.

---

## `database.dart` — The Database Layer

```dart
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../model/task_model.dart';

class TaskDatabase {
  static Database? _database;

  static Future<Database> getDB() async {
    if (_database != null) return _database!;

    String dbPath = await getDatabasesPath();
    String fullPath = path.join(dbPath, 'tasks.db');
    _database = await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)',
        );
      },
    );
    return _database!;
  }

  static Future<void> insertTask(TaskModel task) async {
    final db = await getDB();
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<TaskModel>> getTasks() async {
    final db = await getDB();
    final List<Map<String, dynamic>> tasks = await db.query('tasks');
    return List.generate(tasks.length, (i) => TaskModel.fromMap(tasks[i]));
  }

  static Future<void> deleteTask(int id) async {
    final db = await getDB();
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateTask(TaskModel task) async {
    final db = await getDB();
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
```

`TaskDatabase` holds only `static` methods, so it's never instantiated — you call methods directly on the class, like `TaskDatabase.getTasks()`. This matters because there should only ever be **one** open database connection for the whole app; making everything static enforces that without needing to pass a `TaskDatabase` instance around every widget.

### `getDB()` — lazy, cached connection

```dart
static Database? _database;

static Future<Database> getDB() async {
  if (_database != null) return _database!;
  ...
}
```

`_database` starts as `null`. The first time `getDB()` is called, it's `null`, so the method opens the database with `openDatabase()` and stores the result in `_database`. Every call after that sees `_database` is no longer `null` and returns it immediately, skipping `openDatabase` entirely. This pattern — "create it once, on first use, then reuse it" — is called **lazy initialization**.

`getDatabasesPath()` and `path.join()` together build a platform-correct file path for `tasks.db` on the device. The `onCreate` callback only ever runs the *first* time the app runs on a device — i.e. only when the database file doesn't already exist — and it's where the `tasks` table is created:

```sql
CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)
```

`id` auto-increments so SQLite assigns it automatically on insert; `title` is plain text; `isDone` is stored as an integer since SQLite has no boolean type.

Note that `getDB()` is never called directly from the UI — it's called at the top of every *other* method in this class to fetch the connection before doing anything with it.

### Create — `insertTask`

```dart
static Future<void> insertTask(TaskModel task) async {
  final db = await getDB();
  await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}
```

`task.toMap()` turns the `TaskModel` into the map shape SQLite expects. `ConflictAlgorithm.replace` means that if a row with the same primary key already exists, it gets overwritten instead of the insert throwing an error — in practice this rarely triggers here since new tasks don't have an `id` yet, but it's a safe default.

### Read — `getTasks`

```dart
static Future<List<TaskModel>> getTasks() async {
  final db = await getDB();
  final List<Map<String, dynamic>> tasks = await db.query('tasks');
  return List.generate(tasks.length, (i) => TaskModel.fromMap(tasks[i]));
}
```

`db.query('tasks')` with no arguments returns every row in the table as a list of raw maps. `List.generate` then walks that list and runs `TaskModel.fromMap()` on each entry, turning raw rows into typed `TaskModel` objects the rest of the app can work with.

### Update — `updateTask`

```dart
static Future<void> updateTask(TaskModel task) async {
  final db = await getDB();
  await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
}
```

The `where: 'id = ?'` clause scopes the update to a single row. `whereArgs: [task.id]` passes the actual id value separately from the query string rather than concatenating it in — this is what prevents SQL injection, and is the standard `sqflite` way of parameterizing a query.

### Delete — `deleteTask`

```dart
static Future<void> deleteTask(int id) async {
  final db = await getDB();
  await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
}
```

Takes just the `id` rather than a full `TaskModel`, since deleting a row doesn't require knowing anything else about it.

---

## `home_page.dart` — The UI Layer

```dart
import 'package:flutter/material.dart';
import '../db/database.dart';
import '../model/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskModel> tasks = [];
  TextEditingController taskController = TextEditingController();

  Future<void> refreshTask() async {
    tasks = await TaskDatabase.getTasks();
    setState(() {});
  }

  Future<void> addTask() async {
    if (taskController.text.isEmpty) return;
    await TaskDatabase.insertTask(
      TaskModel(title: taskController.text, isDone: false),
    );
    taskController.clear();
    refreshTask();
  }

  Future<void> deleteTask(int id) async {
    await TaskDatabase.deleteTask(id);
    refreshTask();
  }

  Future<void> updateTask(TaskModel task) async {
    await TaskDatabase.updateTask(task);
    refreshTask();
  }

  Future<void> showUpdateDialog(TaskModel task) async {
  // Create a controller pre-filled with the current task title
  final editController = TextEditingController(text: task.title);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Update Task'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: "Enter updated task",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close without saving
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isEmpty) return;

              // Call your update function with the modified title
              updateTask(
                TaskModel(
                  id: task.id,
                  title: editController.text.trim(),
                  isDone: task.isDone,
                ),
              );

              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
  @override
  void initState() {
    super.initState();
    // Example of inserting a task
    refreshTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite Task Manager')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: 'Enter task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: addTask, icon: Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: tasks[index].isDone,
                    onChanged: (_) {
                      updateTask(
                        TaskModel(
                          id: tasks[index].id,
                          title: tasks[index].title,
                          isDone: !tasks[index].isDone,
                        ),
                      );
                    },
                  ),
                  // Removed unnecessary curly braces around index
                  title: Text('Task-${tasks[index].title}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showUpdateDialog(tasks[index]);
                        },
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: () => deleteTask(tasks[index].id!),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

`HomePage` is a `StatefulWidget` because the list of tasks and the text field's content both change while the app is running — a `StatelessWidget` couldn't hold that mutable state. The actual state lives in `_HomePageState`.

### State fields

```dart
List<TaskModel> tasks = [];
TextEditingController taskController = TextEditingController();
```

`tasks` is the in-memory copy of whatever is currently in the database — it's what `ListView.builder` reads from to draw the list. `taskController` drives the text field where new task titles are typed; it exposes the current text (`taskController.text`) and lets the code clear it programmatically after a task is added.

### `initState()` — loading on startup

```dart
@override
void initState() {
  super.initState();
  refreshTask();
}
```

`initState()` runs exactly once, right when the widget is first inserted into the tree — before the first `build()`. Calling `refreshTask()` here is what makes the task list populate as soon as the screen opens, instead of starting empty until the user does something.

### `refreshTask()` — the pattern every write follows

```dart
Future<void> refreshTask() async {
  tasks = await TaskDatabase.getTasks();
  setState(() {});
}
```

This re-fetches the full task list from the database and calls `setState(() {})`. `setState` tells Flutter "something changed, rebuild this widget" — without it, updating the `tasks` variable alone wouldn't cause the UI to redraw, since Flutter has no way to know the data changed otherwise.

Every CRUD action in this file follows the same shape: **do the database operation, then call `refreshTask()`** so the on-screen list reflects the new database state. Rather than trying to manually patch the `tasks` list in memory, the app always just re-reads the source of truth (the database) and redraws from that. It's simpler and less error-prone, at the cost of one extra query per action — a reasonable trade-off at this scale.

### `addTask()` — Create

```dart
Future<void> addTask() async {
  if (taskController.text.isEmpty) return;
  await TaskDatabase.insertTask(
    TaskModel(title: taskController.text, isDone: false),
  );
  taskController.clear();
  refreshTask();
}
```

Guards against inserting an empty task, then builds a fresh `TaskModel` with no `id` (SQLite will assign one) and `isDone: false` (a new task always starts unchecked). It's wired to the add button:

```dart
IconButton(onPressed: addTask, icon: Icon(Icons.add)),
```

### The task list — `ListView.builder`

```dart
Expanded(
  child: ListView.builder(
    itemCount: tasks.length,
    itemBuilder: (context, index) {
      return ListTile(...);
    },
  ),
),
```

`ListView.builder` only builds the tiles currently visible on screen (plus a small buffer), rather than all of them at once — important once the list grows long. `itemCount` tells it how many items exist; `itemBuilder` is called once per visible index to produce that row's widget.

Each row is a `ListTile` with a checkbox on the left, the title in the middle, and edit/delete buttons on the right.

### The checkbox — Update (toggle done)

```dart
leading: Checkbox(
  value: tasks[index].isDone,
  onChanged: (_) {
    updateTask(
      TaskModel(
        id: tasks[index].id,
        title: tasks[index].title,
        isDone: !tasks[index].isDone,
      ),
    );
  },
),
```

Because `TaskModel` is immutable, toggling "done" means building a brand-new `TaskModel` that copies the existing `id` and `title` but flips `isDone`. That new object is passed to `updateTask()`, which saves it and refreshes the list. The `id` is what lets `updateTask` know *which* row to overwrite — without it, `where: 'id = ?'` in `database.dart` would have nothing to match.

### The edit button — Update (change title)

```dart
IconButton(
  onPressed: () {
    showUpdateDialog(tasks[index]);
  },
  icon: const Icon(Icons.edit, color: Colors.orange),
),
```

This opens `showUpdateDialog()`:

```dart
Future<void> showUpdateDialog(TaskModel task) async {
  final editController = TextEditingController(text: task.title);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Update Task'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: "Enter updated task",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (editController.text.trim().isEmpty) return;
              updateTask(
                TaskModel(
                  id: task.id,
                  title: editController.text.trim(),
                  isDone: task.isDone,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
```

A new `TextEditingController` is created and pre-filled with the task's current title (`TextEditingController(text: task.title)`), so the dialog opens showing what's already there rather than a blank field. `showDialog` displays an `AlertDialog` on top of the current screen.

- **Cancel** just calls `Navigator.pop(context)`, closing the dialog with no side effects.
- **Save** first guards against an empty/whitespace-only title with `.trim().isEmpty`, then builds a new `TaskModel` that keeps the original `id` and `isDone` but swaps in the edited title, passes it to `updateTask()`, and closes the dialog.

Same principle as the checkbox: nothing is mutated in place — a new `TaskModel` is constructed and the database is the single source of truth that gets updated and re-read.

### The delete button — Delete

```dart
IconButton(
  onPressed: () => deleteTask(tasks[index].id!),
  icon: const Icon(Icons.delete, color: Colors.red),
),
```

```dart
Future<void> deleteTask(int id) async {
  await TaskDatabase.deleteTask(id);
  refreshTask();
}
```

`tasks[index].id!` uses the null-assertion operator (`!`). `id` is typed `int?` in `TaskModel` because a task can theoretically exist in memory without an id (before it's ever been saved) — but by the time a task shows up in the rendered list, it has already come back from `getTasks()`, meaning SQLite has already assigned it a real id. So asserting it's non-null here is safe in practice.

---

## Understanding `Future<void>` and `async`/`await`

Every database method returns a `Future`, Dart's representation of "a value that will exist eventually" — the mechanism for doing asynchronous work (like disk I/O) without freezing the UI while it happens.

- `Future<void>` — the operation will finish at some point but doesn't hand back a value. Used for writes (`insertTask`, `updateTask`, `deleteTask`), where only completion matters.
- `Future<List<TaskModel>>` — the operation eventually produces a list of tasks. Used by `getTasks()`, since the UI needs the actual data.

`async` marks a function as asynchronous; `await` inside it pauses execution of *that function* until the awaited `Future` resolves, then continues with the result — without blocking the rest of the app:

```dart
static Future<void> insertTask(TaskModel task) async {
  final db = await getDB();                     // pause until the DB connection is ready
  await db.insert('tasks', task.toMap(), ...);   // pause until the insert finishes
}
```

Without `async`/`await`, the same logic would need chained `.then()` callbacks, which gets harder to follow as more steps stack up. `async`/`await` lets the code read top-to-bottom like ordinary synchronous code, even though nothing is actually blocking.

---

## Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.0
```

Run `flutter pub get` after adding them.

---

## Getting Started

```bash
git clone <your-repo-url>
cd <project-folder>
flutter pub get
flutter run
```

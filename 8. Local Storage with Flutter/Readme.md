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

The app has three layers: the model (`task_model.dart`) defines what a task looks like, the database layer (`database.dart`) handles all SQLite operations, and the UI layer (`home_page.dart`) calls those database methods in response to user actions. Each layer is covered below, and where relevant, it is shown exactly where the code from one layer gets used in the next.

---

### The Model — `task_model.dart`

`TaskModel` is a plain Dart class that represents a single task. It has three fields: `id` (nullable, auto-assigned by SQLite), `title` (a string), and `isDone` (a boolean).

SQLite does not store booleans natively — it only understands integers. So `isDone` is converted to `1` (true) or `0` (false) when writing to the database, and converted back to a Dart `bool` when reading. This is handled by two methods:

**`toMap()`** — converts the object into a `Map<String, dynamic>` that SQLite can accept:

```dart
Map<String, dynamic> toMap() {
  return {'id': id, 'title': title, 'isDone': isDone ? 1 : 0};
}
```

**`fromMap()`** — a factory constructor that takes a raw database row (a `Map`) and builds a `TaskModel` back from it:

```dart
factory TaskModel.fromMap(Map<String, dynamic> map) {
  return TaskModel(
    id: map['id'],
    title: map['title'],
    isDone: map['isDone'] == 1,
  );
}
```

`fromMap` is declared as a factory constructor (instead of a regular constructor) because it receives an existing map and decides how to construct the object from it — it does not directly initialize fields like a normal constructor would. This is the standard Flutter/Dart pattern for deserializing from JSON or database rows.

**Where these are used:** `toMap()` is called inside every write operation in `database.dart` (`insertTask`, `updateTask`) to convert a `TaskModel` into something SQLite can store. `fromMap()` is called inside `getTasks()` to convert each raw database row back into a `TaskModel` that the UI can display.

---

### The Database Layer — `database.dart`

`TaskDatabase` is a class with only `static` methods. This means you never create an instance of `TaskDatabase` — you call its methods directly by the class name, like `TaskDatabase.insertTask(...)` or `TaskDatabase.getTasks()`.

**Why static?** Because there should only ever be one database connection in the app. Making the methods static enforces this and removes the need to pass a `TaskDatabase` object around.

**`getDB()`** manages the single database connection using a cached instance:

```dart
static Database? _database;

static Future<Database> getDB() async {
  if (_database != null) return _database!;   // already open, return it
  // otherwise, open it for the first time
  _database = await openDatabase(fullPath, version: 1, onCreate: ...);
  return _database!;
}
```

This is called lazy initialization — the database is only opened the first time it is needed. Every subsequent call skips the `openDatabase` call and returns the cached `_database` directly.

`onCreate` runs only once, when the database file does not yet exist on disk. It creates the `tasks` table:

```sql
CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)
```

`getDB()` is not called directly from the UI — it is called at the top of every other database method to get the connection before doing anything with it.

---

### CRUD Operations

All four operations follow the same structure: call `getDB()` to get the connection, then call the appropriate `sqflite` method.

#### Create — `insertTask`

```dart
static Future<void> insertTask(TaskModel task) async {
  final db = await getDB();
  await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}
```

`task.toMap()` converts the `TaskModel` into the map format SQLite expects. `ConflictAlgorithm.replace` means if a row with the same primary key already exists, it replaces it rather than throwing an error.

**Where it is called in the UI:** `addTask()` in `home_page.dart` calls this when the user presses the add button:

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

A new `TaskModel` is built from the text field with `isDone` set to `false` (a new task is always unchecked). After inserting, the field is cleared and `refreshTask()` is called so the list updates.

---

#### Read — `getTasks`

```dart
static Future<List<TaskModel>> getTasks() async {
  final db = await getDB();
  final List<Map<String, dynamic>> tasks = await db.query('tasks');
  return List.generate(tasks.length, (i) => TaskModel.fromMap(tasks[i]));
}
```

`db.query('tasks')` returns every row as a list of raw maps. `List.generate` walks over that list and calls `TaskModel.fromMap()` on each entry to convert it back into a typed Dart object.

**Where it is called in the UI:** `refreshTask()` in `home_page.dart` calls this, and `refreshTask()` itself is called from `initState` (so tasks load when the page opens) and after every write operation:

```dart
Future<void> refreshTask() async {
  tasks = await TaskDatabase.getTasks();
  setState(() {});
}

@override
void initState() {
  super.initState();
  refreshTask();
}
```

`setState(() {})` tells Flutter to rebuild the widget tree. The `ListView.builder` in `build` uses the updated `tasks` list to render the tiles.

---

#### Update — `updateTask`

```dart
static Future<void> updateTask(TaskModel task) async {
  final db = await getDB();
  await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
}
```

The `where` clause ensures only the row with the matching `id` is changed. `whereArgs` passes the actual value separately from the query string — this is intentional and prevents SQL injection.

**Where it is called in the UI — two places:**

1. The checkbox toggles `isDone` while keeping everything else the same:

```dart
onChanged: (_) {
  updateTask(TaskModel(
    id: tasks[index].id,
    title: tasks[index].title,
    isDone: !tasks[index].isDone,  // flip the boolean
  ));
},
```

2. `showUpdateDialog()` opens an `AlertDialog` with the current title pre-filled. On save, it builds a new `TaskModel` with the same `id` and `isDone` but the new title, then calls `updateTask`:

```dart
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
```

In both cases, the `id` field is what connects the updated object to the right row in the database. Without passing `id`, the `where: 'id = ?'` clause in `updateTask` would have nothing to match against, and no row would be updated.

---

#### Delete — `deleteTask`

```dart
static Future<void> deleteTask(int id) async {
  final db = await getDB();
  await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
}
```

Takes only the `id`, not the full task, because deleting does not need any other field.

**Where it is called in the UI:** The delete `IconButton` in each list tile calls it, passing the task's `id`:

```dart
IconButton(
  onPressed: () => deleteTask(tasks[index].id!),
  icon: const Icon(Icons.delete, color: Colors.red),
),
```

The `!` after `tasks[index].id` is the null-assertion operator. `id` is declared as `int?` (nullable) in `TaskModel` because a task created in memory before being inserted does not have an id yet. By the time it appears in the list, SQLite has assigned it one — so the `!` is safe here.

---

### Understanding `Future<void>` and `async/await`

Every database method returns a `Future`. A `Future` represents a value that will be available at some point — it is Dart's way of handling asynchronous work (like disk I/O) without blocking the UI thread.

`Future<void>` means the operation will complete eventually but produces no return value. It is used for write operations (insert, update, delete) where you only care that the work finished.

`Future<List<TaskModel>>` means the operation will eventually produce a list of tasks. It is used by `getTasks`, since the UI needs the actual data back.

`async` marks a function as asynchronous. `await` inside it pauses that function until the `Future` resolves, then continues with the result:

```dart
static Future<void> insertTask(TaskModel task) async {
  final db = await getDB();                          // pause until DB is ready
  await db.insert('tasks', task.toMap(), ...);       // pause until insert finishes
}
```

Without `async/await`, you would need to chain `.then()` callbacks, which becomes harder to read as operations stack up. With `async/await`, the code reads top-to-bottom like synchronous code even though it is not blocking anything.

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
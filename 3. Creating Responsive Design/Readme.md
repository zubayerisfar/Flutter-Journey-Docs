# Creating Responsive Design
![Target Image](images/target_image.png)

## Problem

When you rotate the phone, the layout breaks. If we look at what we had before in the <a href="../2. Building Structure from Scratch/Readme.md">Tutorial</a>, when you tilt the phone sideways, everything just overflows:

![Titled Responsive Issue](images/current_issue.png)

## Solution 1: Add Scrolling with SingleChildScrollView

Wrap the Column with `SingleChildScrollView` to make content scrollable when it goes off-screen:

```dart
body: SingleChildScrollView(
    child: Column(
      children: [...]
    )
)
```

This works for both Column (vertical scroll) and Row (horizontal scroll):

![Scrolling Elements](images/scrolling_enable.png)

But now there's still a problem - the layout looks cramped when you rotate the phone. Widgets are too big, text is everywhere.

## Solution 2: Different Layout for Portrait vs Landscape

Better approach: show widgets in a single column for portrait mode, but place them side-by-side in landscape mode.

To do this, we need to:

1. Store all widgets in a List instead of hardcoding them
2. Check the phone orientation
3. Arrange widgets differently based on orientation

### Step 1: Create a Widget List

Instead of copying widgets over and over, store them in a List:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> habitTiles = [
      HabitTile(
        habitName: "Drinking Water",
        progress: "Progress: 33%",
        streak: "Streak: 2 days",
        icon: Icons.local_drink,
        tileColor: const Color.fromARGB(255, 218, 215, 215),
      ),
      HabitTile(
        habitName: "Exercise",
        progress: "Progress: 50%",
        streak: "Streak: 5 days",
        icon: Icons.fitness_center,
        tileColor: const Color.fromARGB(255, 100, 200, 150),
      ),
      // ... more widgets
    ];

    return MaterialApp(
      // ... rest of code
    );
  }
}
```

Instead of hardcoding each widget, we now have a `habitTiles` list that holds everything.

### Step 2: Use OrientationBuilder to Check Orientation

Use `OrientationBuilder` and `MediaQuery` to detect if the phone is in portrait or landscape:

```dart
child: OrientationBuilder(
  builder: (context, orientation) {
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    if (isPortrait) {
      // Portrait mode: stack widgets vertically
      return Column(spacing: 16, children: habitTiles);
    }

    // Landscape mode: show 2 widgets side-by-side
    return Column(
      spacing: 16,
      children: [
        for (var i = 0; i < habitTiles.length; i += 2)
          Row(
            spacing: 16,
            children: [
              Expanded(child: habitTiles[i]),
              if (i + 1 < habitTiles.length)
                Expanded(child: habitTiles[i + 1]),
            ],
          ),
      ],
    );
  },
)
```

### How the Landscape Layout Works

The landscape layout pairs up widgets. Here's how the loop works:

- If you have 5 widgets: `[W1, W2, W3, W4, W5]`
- Loop iteration 1 (i=0): Shows `Row(W1, W2)`
- Loop iteration 2 (i=2): Shows `Row(W3, W4)`
- Loop iteration 3 (i=4): Shows `W5` alone (because there's no W6)

The `i += 2` means we jump by 2 each time. The `if (i + 1 < habitTiles.length)` check prevents errors when you have an odd number of widgets - it makes sure we don't try to display a widget that doesn't exist.

The `Expanded` widget makes each tile take equal space in the row.

Result:

![Horizontal Proper Output](images/list_printing_horizontal.png)

## Step 3: Add Dark Mode

Lastly, add nice dark mode support with `darkTheme`:

```dart
return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Habit Tracker',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 2,
      backgroundColor: Colors.white,
    ),
    textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
  ),
  darkTheme: ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 2,
      backgroundColor: const Color.fromARGB(255, 50, 50, 50),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
    ),
  ),
  // ...
);
```

The `darkTheme` parameter defines colors specifically for dark mode. When you turn on dark mode on your phone, these colors will be used instead of the regular theme.

![Dark Mode](images/dark_mode.png)

## Complete Code

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> habitTiles = [
      HabitTile(
        habitName: "Drinking Water",
        progress: "Progress: 33%",
        streak: "Streak: 2 days",
        icon: Icons.local_drink,
        tileColor: const Color.fromARGB(255, 218, 215, 215),
      ),
      HabitTile(
        habitName: "Exercise",
        progress: "Progress: 50%",
        streak: "Streak: 5 days",
        icon: Icons.fitness_center,
        tileColor: const Color.fromARGB(255, 100, 200, 150),
      ),
      HabitTile(
        habitName: "Reading",
        progress: "Progress: 75%",
        streak: "Streak: 10 days",
        icon: Icons.book,
        tileColor: const Color.fromARGB(255, 150, 150, 200),
      ),
      HabitTile(
        habitName: "Saving Money",
        progress: "Progress: 75%",
        streak: "Streak: 10 days",
        icon: Icons.wallet,
        tileColor: const Color.fromARGB(255, 193, 200, 100),
      ),
      HabitTile(
        habitName: "Meditation",
        progress: "Progress: 75%",
        streak: "Streak: 10 days",
        icon: Icons.phone,
        tileColor: const Color.fromARGB(255, 165, 105, 123),
      ),
    ];

    return MaterialApp(
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.white,
        ),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: const Color.fromARGB(255, 50, 50, 50),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Habit Tracker")),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: OrientationBuilder(
              builder: (context, orientation) {
                final isPortrait =
                    MediaQuery.orientationOf(context) == Orientation.portrait;
                if (isPortrait) {
                  return Column(spacing: 16, children: habitTiles);
                }

                return Column(
                  spacing: 16,
                  children: [
                    for (var i = 0; i < habitTiles.length; i += 2)
                      Row(
                        spacing: 16,
                        children: [
                          Expanded(child: habitTiles[i]),
                          if (i + 1 < habitTiles.length)
                            Expanded(child: habitTiles[i + 1]),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HabitTile extends StatelessWidget {
  final String habitName;
  final String progress;
  final String streak;
  final IconData icon;
  final Color tileColor;

  const HabitTile({
    super.key,
    required this.habitName,
    required this.progress,
    required this.streak,
    required this.icon,
    required this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: tileColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: Icon(icon, color: Colors.black),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habitName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text("1/3 Glasses", style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Text(
                progress,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(streak, style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
```

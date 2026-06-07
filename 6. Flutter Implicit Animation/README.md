# Flutter Implicit Animations — Practical Examples

A hands-on collection of 4 examples that demonstrate how **implicit animations** work in Flutter. Each example is self-contained, progressively builds on concepts, and is designed to be easy to read and learn from.

---

## What Are Implicit Animations?

In Flutter, animations fall into two categories:

| Type | Who controls the animation? | Examples |
|---|---|---|
| **Implicit** | Flutter handles it automatically | `AnimatedContainer`, `AnimatedScale`, `TweenAnimationBuilder` |
| **Explicit** | You control it with `AnimationController` | `AnimationController` + `AnimatedBuilder` |

With implicit animations, you just **change a value** and Flutter animates to the new value on its own. No `AnimationController`, no `Ticker`, no manual `dispose` needed.

```
You change a value  →  Flutter detects old value and new value  →  Flutter animates between them
```

---

## When to Use Implicit vs Explicit

Use **implicit** when:
- Animation is triggered by a state change — a tap, a toggle, a data update
- You don't need to loop, reverse, or control the timeline manually
- You want something working quickly without boilerplate

Use **explicit** when:
- Animation needs to loop forever (a spinner, a pulse, a breathing effect)
- Animation is driven by a gesture in real time — like a drag position following a finger
- You need full control: pause, rewind, speed up, chain sequences

---

## Project Structure

```
lib/
├── button_animation.dart       # AnimatedContainer — multiple properties at once
├── container_animation.dart    # AnimatedContainer — simplest possible example
├── pulsating_animation.dart    # TweenAnimationBuilder — custom value + looping
└── tap_drag_animation.dart     # AnimatedScale + real-time drag with GestureDetector
```

---

## Examples

---

### 1. Button Animation — `button_animation.dart`

![Button Animation](assets/button_animation.gif)

#### What It Does

A button that expands in size, changes color, and reshapes its border radius when tapped — all animated simultaneously with a single `AnimatedContainer`.

#### Understanding `AnimatedContainer`

`AnimatedContainer` works exactly like a regular `Container` but watches every property you give it. The moment any property value changes, it smoothly animates from the old value to the new one. You don't have to do anything extra — the animation is automatic.

```
Old state:  width=100, height=100, color=blue, radius=10
                         ↓  setState called
New state:  width=300, height=200, color=green, radius=50
                         ↓
        AnimatedContainer animates ALL of these at the same time
```

#### Code — with explanation

```dart
// This single bool drives every animated property below.
// When it flips, AnimatedContainer re-reads all the values
// and starts animating toward the new ones.
bool isClicked = false;

AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  // Curves.fastOutSlowIn feels natural for UI — it moves fast at
  // the start (responsive) and decelerates gently at the end (smooth).
  curve: Curves.fastOutSlowIn,

  // Every property here will animate when isClicked changes.
  // AnimatedContainer internally lerps between old and new values.
  width: isClicked ? 300 : 100,
  height: isClicked ? 200 : 100,

  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: isClicked ? Colors.green : Colors.blue,
      shape: RoundedRectangleBorder(
        // Even the border radius animates — it goes from a
        // slight rounding (10) to a pill shape (50).
        borderRadius: BorderRadius.circular(isClicked ? 50 : 10),
      ),
    ),

    onPressed: () {
      // Why setState here?
      // Flutter's StatefulWidget only redraws the UI when setState is called.
      // Without setState, isClicked would change in memory but the widget
      // would never know — the screen stays frozen.
      // setState tells Flutter: "something changed, rebuild this widget."
      // AnimatedContainer then sees the new values and kicks off the animation.
      setState(() {
        isClicked = !isClicked;
      });
    },

    child: Text(
      isClicked ? 'THE BUTTON HAS BEEN JUST CLICKED!' : 'Click',
      overflow: TextOverflow.ellipsis,
    ),
  ),
)
```

#### About Curves

A `Curve` controls the *feel* of an animation — how fast or slow it moves at different points within its duration. Same duration, completely different character:

- `Curves.linear` — constant speed all the way through. Feels mechanical and robotic.
- `Curves.fastOutSlowIn` — jumps quickly at the start (feels responsive to your tap), then glides to a stop. Most natural for UI interactions.
- `Curves.easeOutBack` — overshoots the target slightly before snapping back. Gives a bouncy, playful feel.
- `Curves.slowMiddle` — slow at both ends, fastest in the middle. Good for color transitions that need a smooth, deliberate feel.
- `Curves.bounceOut` — physically bounces like a ball hitting the floor when it arrives.

Think of `duration` as *how long* and `curve` as *how it feels*.

---

### 2. Container Animation — `container_animation.dart`

![Container Animation](assets/container_animation.gif)

#### What It Does

The most stripped-down implicit animation possible — a container that smoothly transitions between two colors when a button is pressed. No size changes, no shape changes. Just color.

This is a good starting point because there is almost no noise — you can see exactly how the state → animation loop works with nothing else getting in the way.

#### Code — with explanation

```dart
// currentColor is the single source of truth.
// Whatever value this holds, the AnimatedContainer will match it —
// and animate whenever it changes.
Color currentColor = Colors.blue;

void changeColorofContainer() {
  // setState is used here because this is a method called from a button press.
  // The button lives outside the AnimatedContainer, so we need Flutter to
  // rebuild the whole widget and pass the new color down.
  // Without setState, currentColor updates but the screen never redraws.
  setState(() {
    currentColor = currentColor == Colors.blue ? Colors.red : Colors.blue;
  });
}

AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  // Curves.slowMiddle makes the color linger at both the start and end,
  // with the fastest transition happening in the middle.
  // For color changes this feels organic — like the color is breathing.
  curve: Curves.slowMiddle,
  color: currentColor, // AnimatedContainer watches this. When it changes, it animates.
  width: 100,
  height: 100,
  child: const Center(
    child: Text('Animated Container', style: TextStyle(color: Colors.white)),
  ),
)
```

#### Why a Separate Function Instead of Inline?

`changeColorofContainer` is its own method rather than an inline lambda on the button — mostly for readability, but also because if the color logic grows (more conditions, more colors), you have one place to update it. Either approach works fine here.

---

### 3. Pulsating Animation — `pulsating_animation.dart`

![Pulsating Animation](assets/pulsating_animation.gif)

#### What It Does

A blue circle that continuously scales up and down, creating a breathing/pulse effect with a glowing shadow. It loops indefinitely by reversing direction each time the animation completes.

#### Understanding `TweenAnimationBuilder`

`AnimatedContainer` animates its own built-in properties — size, color, padding. But what if you want to animate something it doesn't cover, like the scale of a `Transform`, or a custom value you compute yourself?

That is what `TweenAnimationBuilder` is for. It animates **any value you define** — a `double`, a `Color`, an `Offset`, anything — and hands it to you inside a `builder` function so you can use it however you want.

```dart
TweenAnimationBuilder(
  tween: Tween<double>(begin: 0.5, end: 1.5),
  duration: Duration(milliseconds: 1500),
  builder: (context, value, child) {
    // `value` is a double that smoothly goes from 0.5 → 1.5.
    // You decide what to do with it. Here we use it as a scale factor.
    return Transform.scale(scale: value, child: child);
  },
)
```

`Transform.scale` is used instead of changing `width`/`height` because it scales the widget visually without affecting the layout — neighboring widgets don't shift around.

#### Looping — How the Direction Toggle Works

`TweenAnimationBuilder` plays once and stops. To loop, we flip a bool each time it ends, which swaps the `begin` and `end` of the tween, causing it to animate in the opposite direction:

```dart
// _forward controls which direction the tween runs.
// true  → growing  (0.5 to 1.5)
// false → shrinking (1.5 to 0.5)
bool _forward = true;

TweenAnimationBuilder(
  tween: Tween<double>(
    begin: _forward ? 0.5 : 1.5,
    end:   _forward ? 1.5 : 0.5,
    // When _forward is true:  begin=0.5, end=1.5 → grows
    // When _forward is false: begin=1.5, end=0.5 → shrinks
  ),
  duration: const Duration(milliseconds: 1500),
  builder: (context, scale, child) {
    return Transform.scale(scale: scale, child: child);
  },
  onEnd: () {
    // onEnd fires when the animation reaches its `end` value.
    // We flip _forward, which triggers a rebuild with a reversed tween.
    // That rebuild starts the animation in the opposite direction.
    // This repeats forever — creating the loop.
    setState(() => _forward = !_forward);
  },
)
```

```
_forward = true  →  0.5 ──────────► 1.5   (circle grows)
                                      onEnd fires
_forward = false →  1.5 ──────────► 0.5   (circle shrinks)
                                      onEnd fires
_forward = true  →  0.5 ──────────► 1.5   (repeats forever)
```

> **Worth knowing:** For production looping animations, `AnimationController` with `repeat(reverse: true)` is more efficient — it doesn't need `setState` or a rebuild to loop, it just runs on its own ticker. The direction toggle here is a clean way to learn the concept using only implicit tools.

---

### 4. Tap & Drag Animation — `tap_drag_animation.dart`

![Tap and Drag Animation](assets/pan_drag_animation.gif)

#### What It Does

Two interactive elements on the same screen:
- **Blue square** — tap it to toggle between normal and larger size using `AnimatedScale`
- **Red circle** — drag it freely anywhere on the screen using `GestureDetector` + `Positioned`

This example exists to show both patterns side by side — one that uses implicit animation, and one that intentionally does not.

#### Part A — Tap to Grow (`TapToGrow`)

```dart
// _isBig is the only state this widget holds.
// AnimatedScale reads it and decides what scale to animate toward.
bool _isBig = false;

GestureDetector(
  // onTap fires once when the finger lifts.
  // setState is used because _isBig needs to change AND the widget
  // needs to rebuild so AnimatedScale sees the new scale value.
  // Without setState, the tap happens but nothing visually changes.
  onTap: () => setState(() => _isBig = !_isBig),

  child: AnimatedScale(
    // AnimatedScale is a focused version of AnimatedContainer for scale only.
    // It watches `scale` — when _isBig flips, it animates to the new value.
    scale: _isBig ? 1.5 : 1.0,
    duration: Duration(milliseconds: 300),

    // Curves.easeOutBack goes slightly past the target before snapping back.
    // That tiny overshoot is what gives it the bouncy, alive feeling.
    // Without it, the scale would just stop flatly at 1.5 — feels dead.
    curve: Curves.easeOutBack,

    child: Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  ),
)
```

#### Part B — Draggable Circle (`DraggableElement`)

```dart
// x and y track the circle's center position on screen.
// They start at (100, 100) — near the top-left.
double x = 100;
double y = 100;

Positioned(
  // We subtract 50 (half the widget's 100px size) so the widget
  // centers on the finger instead of its top-left corner sitting on it.
  left: x - 50,
  top: y - 50,

  child: GestureDetector(
    // onPanUpdate fires continuously while the finger is moving.
    // `details.delta` is how many pixels the finger moved since the last frame.
    // We add that delta to x and y — so the widget moves exactly as far
    // as the finger moved. No animation, no easing — pure 1:1 tracking.
    onPanUpdate: (details) {
      setState(() {
        // Why setState on every frame here?
        // Because Positioned needs to rebuild with new left/top values
        // on every single finger movement to keep up with the drag.
        // This is fine — setState is cheap, and the rebuild is tiny.
        x += details.delta.dx;
        y += details.delta.dy;
      });
    },

    child: Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(50),
      ),
    ),
  ),
)
```

#### Why Drag Does Not Use Implicit Animation

This is an important distinction. Implicit animations work by animating *from* one value *to* another over a set duration. But during a drag, there is no destination — the position is just wherever the finger is right now. If you used `AnimatedContainer` for the position, it would always be chasing the finger with a delay, creating a floaty lag instead of direct tracking.

Drag position must follow the finger **instantly**, frame by frame. That means plain `setState` with no animation — the position just snaps to wherever the math says it should be.

#### How `Stack` Enables This

```
Stack
├── TapToGrow widget        →  sits at center (wrapped in Center())
└── DraggableElement widget →  floats at (x, y) via Positioned, above everything
```

`Stack` layers its children on top of each other. Without `Stack`, widgets flow in a line and can't overlap. With `Stack`, `Positioned` can place the red circle at any absolute coordinate and move it freely — completely independent of any other widget on screen.

---

## Implicit Animation Widgets — Quick Reference

| Widget | Animates | Use When |
|---|---|---|
| `AnimatedContainer` | width, height, color, padding, decoration, and more | Multiple properties changing together |
| `AnimatedScale` | scale | Only scale needs to change — cleaner than AnimatedContainer |
| `AnimatedOpacity` | opacity | Fading elements in or out |
| `AnimatedAlign` | alignment within parent | Sliding a child between positions |
| `AnimatedPadding` | padding | Spacing changes |
| `AnimatedDefaultTextStyle` | text style properties | Text size, color, or weight transitions |
| `TweenAnimationBuilder` | any value you define | Custom properties not covered by the widgets above |

---

## Core Pattern — How Every Example Works

Every implicit animation here follows the exact same 3-step loop:

```
Step 1 — Hold state in a variable
         bool isClicked = false;
         Color currentColor = Colors.blue;

Step 2 — Change the state on an interaction, always inside setState()
         setState(() => isClicked = !isClicked);
         // setState tells Flutter to rebuild the widget.
         // Without it, the variable changes but the screen never updates.

Step 3 — Pass the state into an animated widget property
         AnimatedContainer(width: isClicked ? 300 : 100, ...)
         // The widget compares old value to new value after the rebuild
         // and animates between them automatically.
```

`setState` is not optional. It is the signal to Flutter that something changed and the UI needs to be redrawn. The animated widget only runs its animation because it sees a new value after a rebuild — and rebuilds only happen when `setState` is called.
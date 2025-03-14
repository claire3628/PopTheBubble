# PopTheBubble

## Game Instructions

PopTheBubble is a fun and interactive game where the objective is to pop as many bubbles as possible within a given time limit. The game is designed for iOS devices and utilizes touch gestures to pop the bubbles.

## How to Play

1. Launch the game on your iOS device.
2. Bubbles will start appearing on the screen.
3. Tap on the bubbles to pop them.
4. Each popped bubble will increase your score.
5. The game ends when the time runs out.
6. Try to achieve the highest score possible!

## Program Architecture

The PopTheBubble game is structured into several key components:

### 1. Model

- **Bubble**: Represents a bubble object with properties such as position, size, and status (popped or not).
- **Score**: Keeps track of the player's score.

### 2. View

- **MainView**: The main game screen where bubbles appear and the player interacts with them.
- **ScoreView**: Displays the current score and time remaining.

### 3. Controller

- **GameController**: Manages the game logic, including bubble generation, score updates, and game timer.
- **TouchController**: Handles touch events to detect when a bubble is popped.

### 4. Utilities

- **BubbleGenerator**: Generates bubbles at random positions and intervals.
- **Timer**: Manages the countdown timer for the game.

### File Structure

```
/PopTheBubble
|-- Models
|   |-- Bubble.swift
|   |-- Score.swift
|
|-- Views
|   |-- MainView.swift
|   |-- ScoreView.swift
|
|-- Controllers
|   |-- GameController.swift
|   |-- TouchController.swift
|
|-- Utilities
|   |-- BubbleGenerator.swift
|   |-- Timer.swift
|
|-- Assets
|   |-- Images
|       |-- bubble.png
|
|-- readme.md
```

This structure ensures a clear separation of concerns, making the codebase easier to manage and extend.

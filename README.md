# TODO App

## Project Overview

This is a Flutter-based mobile application designed to manage tasks efficiently. It allows users to create, track, and organize their daily to-dos with a clean and intuitive user interface. The application adheres to modern architectural principles, ensuring scalability, maintainability, and testability.

## Features

The application includes the following core functionalities:

*   **Task Management**: List, add, edit, delete, and undo deleted tasks.
*   **Task Details**: Add due dates and set task priority (high/medium/low).
*   **Task Status**: Mark tasks as completed/incomplete.
*   **Filtering & Sorting**: Filter tasks by status (All, Active, Completed) and sort tasks by date.
*   **Search Functionality**: Search for tasks.
*   **Drag and Drop**: Reorder tasks using drag and drop.
*   **Undo Delete**: Provides an option to undo a deleted task within 5 seconds.
*   **Dark Mode**: Supports a dark theme for improved user experience in low-light conditions.
*   **Animations**: Includes animations in the splash screen for a polished feel.

## Architecture

The project follows a **Clean Architecture** approach, separating the application into distinct layers: `data`, `domain`, and `presentation`. This separation promotes a modular, scalable, and testable codebase.

*   **Data Layer**: Responsible for data sources, models, and repository implementations for persistence and retrieval. This project utilizes **Drift** for local data persistence.
*   **Domain Layer**: Contains business entities, repository contracts, and use cases that encapsulate the application's business logic.
*   **Presentation Layer**: Handles UI screens, widgets, and **BLoC/Cubit** for state management and user interactions.

## Technical Details

*   **Local Persistence**: **Drift** (formerly `moor`) is used for local data storage, providing a robust and type-safe way to interact with a SQLite database.
*   **Dependency Injection**: **GetIt** is employed for managing dependencies, ensuring a loosely coupled and testable architecture.
*   **State Management**: The presentation layer leverages **BLoC** for reactive state management, with **bloc_test** used for unit testing the BLoC layer.
*   **Testing**: Unit tests are implemented for the BLoC layer to ensure the reliability and correctness of the application's business logic.

## Getting Started

To run this project locally, follow these steps:

1.  **Clone the repository**:
    ```bash
    git clone git@github.com:shreeecreation/flutter-todo-eb.git
    cd todo_app
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs      
    ```
3.  **Run the application**:
    ```bash
    flutter run
    ```
4.  **Test the application**:
    ```bash
    flutter test
    ```
5.  **Test specific features**:
    ```bash
    flutter test/features/tasks/bloc/task_bloc_test.dart 
    ```
    

## Screenshots & Demo

*(Placeholder for screenshots or a short video demonstrating the app's functionality.)*

## Future Enhancements

*   Implement custom theming options.
*   Add cloud synchronization for tasks.
*   Integrate notifications for due tasks.

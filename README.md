# Map Runner - Robot Navigation Test App

## Overview

Map Runner is a Flutter-based utility application designed to test and control robot navigation functionalities. It provides a simple user interface to connect to a robot's API, fetch available maps, and command a specific robot to navigate a series of locations on a selected map.

The application serves as a testing and debugging tool for robot navigation tasks.

## Features

- **Dynamic API Key Configuration**: Allows the user to input and apply an API key at runtime, removing the need for hardcoded keys.
- **Map Fetching**: Fetches a list of all available navigation maps from the backend server.
- **Robot Selection**: Allows specifying a target robot by its Serial Number (SN).
- **Automated Navigation Sequence**:
  - Initiates a "New Task" with the API.
  - Iterates through all predefined locations (`rLocations`) on the selected map.
  - Sends a "Navigation" command for each location.
  - Polls the robot's `moveStatus` to wait for its arrival at each location.
  - Completes the task once all locations have been visited.
- **Real-time Logging**: Displays a detailed log of all operations, API calls, and robot statuses in a scrollable, copyable text view.
- **Robust API Handling**:
  - Gracefully handles API responses where map data is still being processed, with an automatic retry mechanism.
  - Safely parses potentially `null` or malformed data from the API to prevent crashes.

## How to Use

1.  **Launch the Application**.
2.  **Set the API Key**:
    -   Enter your `Basic` authentication token into the "輸入 API 金鑰" (Enter API Key) text field.
    -   Press the "套用" (Apply) button.
    -   The application will use this key to fetch the list of available maps. Check the log window for success or failure messages.
3.  **Enter Robot SN**:
    -   Input the Serial Number of the target robot into the "輸入 SN" (Enter SN) text field.
4.  **Select a Map**:
    -   Choose a map from the "選擇 MapName" (Select MapName) dropdown menu. This list is populated based on the data fetched with your API key.
5.  **Start Navigation**:
    -   Press the "開始循環導航" (Start Loop Navigation) button.
    -   The robot will begin its navigation sequence.
6.  **Monitor Progress**:
    -   Observe the log window for real-time updates on the robot's progress, including which location it is navigating to and its current `moveStatus`.

## Project Structure

The project follows a standard Flutter application structure, with all Dart source code located in the `lib/` directory.

```
lib/
├── main.dart                  # Main application entry point and UI for the navigation page.
├── api_service.dart           # Handles all HTTP requests to the backend APIs.
├── navigation_controller.dart # Contains the core business logic for the navigation sequence.
│
├── models/
│   ├── location_model.dart    # Data models for Fields and Maps (`Field`, `MapInfo`).
│   └── robot_info_model.dart  # Data model for robot status (`RobotInfo`).
│
└── widgets/
    └── log_console.dart       # A simple, reusable widget for displaying logs.
```

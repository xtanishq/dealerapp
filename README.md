



# Flutter Dealer App

This is a simple Flutter application created as part of  assignment.

---

## Features

- Splash screen
- Login & Register
- Token based authentication
- Dealer notification list
- Pagination 
- Pull to refresh
- Filter notifications
- Logout
- BLoC state management
- Basic error handling

---

## How to Run the Project


1. Get dependencies
   flutter pub get

2. Run the app
   flutter run

---

## API Details

Base url:
https://interview.krishivikas.com/api

### APIs Used

- POST /user-login
- POST /user-register
- POST /dealer-notification-list

---

## App Flow

- App starts with Splash Screen
- Checks if token is saved
- If token exists → opens Notification List
- If not → opens Login screen
- User can logout anytime

---

## Token Handling

- Token is stored using SharedPreferences
- Token is sent in API header
- If API returns 401, user is logged out

---

## Test Data

You can register a new user using this sample data:

{
"name": "Test User",
"email": "test@krishivikas.com",
"gender": "male",
"phone": "9230931015",
"password": "123456"
}

---

## Packages Used

- flutter_bloc
- equatable
- http
- shared_preferences

---



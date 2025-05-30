# Manual Testing Scenarios for AksumFit

This document outlines key manual testing scenarios for the AksumFit application after the major refactoring phases.

## 1. Onboarding & Authentication

**Scenario 1.1: New User Registration**
*   **Steps:**
    1.  Open the app for the first time.
    2.  Observe Splash Screen, then automatic navigation to Login Screen.
    3.  On Login Screen, tap "Sign Up" text button.
    4.  Verify navigation to Registration Screen.
    5.  Enter valid Full Name, Email, Password, and Confirm Password.
    6.  Tap "Create Account" button.
*   **Expected Outcome:**
    *   Registration successful (mocked API).
    *   User is navigated to the Login Screen.
    *   A success message (e.g., SnackBar "Registration successful! Please login.") is shown.

**Scenario 1.2: Registration with Invalid Data**
*   **Steps:**
    1.  Navigate to Registration Screen.
    2.  Attempt to submit with empty fields. Verify validation messages.
    3.  Enter an invalid email format. Verify validation message.
    4.  Enter a short password (e.g., "123"). Verify validation message.
    5.  Enter mismatching password and confirm password. Verify validation message.
*   **Expected Outcome:**
    *   Appropriate validation error messages are displayed for each case.
    *   Registration is prevented.

**Scenario 1.3: Existing User Login - Success**
*   **Steps:**
    1.  Navigate to Login Screen.
    2.  Enter valid credentials (e.g., "demo@axumfit.com" / "demo123").
    3.  Tap "Login" button.
*   **Expected Outcome:**
    *   Login successful.
    *   User is navigated to the Home Screen (`/main`).
    *   User's name is displayed on the Home Screen.

**Scenario 1.4: Existing User Login - Failure**
*   **Steps:**
    1.  Navigate to Login Screen.
    2.  Enter invalid credentials (e.g., "wrong@example.com" / "wrongpass").
    3.  Tap "Login" button.
*   **Expected Outcome:**
    *   Login fails.
    *   An error message (e.g., "Authentication failed. Please login again.") is displayed on the Login Screen.
    *   User remains on the Login Screen.

**Scenario 1.5: Accessing Protected Route While Logged Out**
*   **Steps:**
    1.  Ensure user is logged out.
    2.  (If possible via deeplink or modified initial route for testing) Attempt to navigate directly to a protected route (e.g., `/progress` or `/nutrition`).
*   **Expected Outcome:**
    *   User is redirected to the Login Screen (`/login`).

**Scenario 1.6: Accessing Auth Routes While Logged In**
*   **Steps:**
    1.  Log in successfully.
    2.  (If possible via browser bar or test deeplink) Attempt to navigate to `/login` or `/register`.
*   **Expected Outcome:**
    *   User is redirected to the Home Screen (`/main`).

**Scenario 1.7: Logout**
*   **Steps:**
    1.  Log in successfully.
    2.  Navigate to Profile -> Settings.
    3.  Tap the "Logout" button.
    4.  Confirm logout in the dialog.
*   **Expected Outcome:**
    *   User is logged out.
    *   User is navigated to the Login Screen (`/login` or your app's root if different).
    *   Attempting to access a protected screen should redirect to login.

## 2. Workout Feature

**Scenario 2.1: View Workout Plans**
*   **Steps:**
    1.  Log in. Navigate to the "Workout" tab (WorkoutPlansScreen).
*   **Expected Outcome:**
    *   Screen displays "My Workout Plans".
    *   If no plans created, an empty state message is shown.
    *   FAB to "Create Plan" is visible.

**Scenario 2.2: Create a New Workout Plan**
*   **Steps:**
    1.  On WorkoutPlansScreen, tap "Create Plan" FAB.
    2.  Enter a Plan Name and Description.
    3.  Tap "Add Exercise". Navigate to Exercise Library.
    4.  Select an exercise from the library.
    5.  Verify the exercise is added to the plan creation screen.
    6.  Expand the exercise tile, enter sets, reps, weight (if applicable). Tap "Update Exercise Details".
    7.  Add another exercise.
    8.  Tap "Save Workout Plan".
*   **Expected Outcome:**
    *   Plan is saved (mocked API).
    *   User is navigated back to WorkoutPlansScreen.
    *   The new plan appears in the list.
    *   A success message is shown.

**Scenario 2.3: Start and Log a Workout Session**
*   **Steps:**
    1.  On WorkoutPlansScreen, tap an existing workout plan.
    2.  Verify navigation to WorkoutScreen (active session).
    3.  For each exercise:
        *   If strength: Enter weight/reps for each set in `WeightRepLoggerWidget`, tap "Log Set".
        *   If timed: Observe `ExerciseTimerWidget` countdown.
    4.  Navigate using "Next" and "Previous" buttons.
    5.  After the last exercise, tap "Finish" (or it auto-navigates if "Next" is tapped).
    6.  Enter optional workout notes in the dialog.
    7.  Tap "Save Notes" (or "Skip").
*   **Expected Outcome:**
    *   Workout session UI is interactive and updates correctly.
    *   Workout log is saved (mocked API).
    *   User is navigated to WorkoutSummaryScreen.
    *   WorkoutSummaryScreen displays correct summary of the logged workout (plan name, exercises, sets/reps/duration logged).

**Scenario 2.4: Edit an Existing Workout Plan**
*   **Steps:**
    1.  On WorkoutPlansScreen, tap the menu (ellipsis) on a plan and select "Edit".
    2.  Modify plan name, add/remove an exercise, or change exercise parameters.
    3.  Tap "Update Workout Plan".
*   **Expected Outcome:**
    *   Plan changes are saved (mocked API).
    *   User returns to WorkoutPlansScreen, sees updated plan details.

**Scenario 2.5: Delete a Workout Plan**
*   **Steps:**
    1.  On WorkoutPlansScreen, tap the menu (ellipsis) on a plan and select "Delete".
    2.  Confirm deletion in the dialog.
*   **Expected Outcome:**
    *   Plan is deleted (mocked API).
    *   Plan is removed from the list on WorkoutPlansScreen.

## 3. Nutrition Feature

**Scenario 3.1: Log a Meal (New Log for Day)**
*   **Steps:**
    1.  Log in. Navigate to the "Nutrition" tab (NutritionScreen).
    2.  Verify today's date is shown.
    3.  Tap the "Log Meal" FAB. Select "Breakfast".
    4.  On LogMealScreen:
        *   Search for "Apple". Select it.
        *   In the dialog, enter quantity "1", unit "piece". Tap "Add to Meal".
        *   Search for "Oats". Select it.
        *   In the dialog, enter quantity "50", unit "g". Tap "Add to Meal".
        *   Tap "Add Custom Food". Enter details for a custom item (e.g., "My Special Coffee"). Save.
    5.  Verify items appear in "Current Meal Items" with calculated calories/macros.
    6.  Verify "Meal Totals" update.
    7.  Tap "Save" (check mark icon).
*   **Expected Outcome:**
    *   Meal is logged successfully (mocked API).
    *   User returns to NutritionScreen.
    *   NutritionScreen updates to show the logged "Breakfast" with its total calories and macros.
    *   Daily Summary on NutritionScreen updates.

**Scenario 3.2: Add to Existing Meal Type for the Day**
*   **Steps:**
    1.  Follow steps for 3.1 to log a Breakfast.
    2.  Tap "Log Meal" FAB again. Select "Breakfast" again.
    3.  Search for "Banana". Add 1 piece.
    4.  Tap "Save".
*   **Expected Outcome:**
    *   New items are added to the existing "Breakfast" meal for the day.
    *   NutritionScreen updates, showing "Breakfast" with combined items and updated totals.

**Scenario 3.3: View Previous/Next Day's Nutrition Log**
*   **Steps:**
    1.  On NutritionScreen, use the date chevrons or calendar icon to select a different date.
*   **Expected Outcome:**
    *   Nutrition data (summary, meals) updates to reflect the selected date's log (or empty state if no log).

## 4. Progress Tracking Feature

**Scenario 4.1: Log Weight**
*   **Steps:**
    1.  Log in. Navigate to the "Progress" tab (ProgressScreen).
    2.  Tap "Log Weight" button.
    3.  Select date (defaults to today), enter weight, add optional notes.
    4.  Tap "Save".
*   **Expected Outcome:**
    *   Weight entry is saved (mocked API).
    *   Weight chart on ProgressScreen updates/re-renders to include the new data point.
    *   "Current Value" for any active weight goal updates.

**Scenario 4.2: Set a New Goal (Weight)**
*   **Steps:**
    1.  On ProgressScreen, tap "Set New Goal" button.
    2.  Enter Goal Name (e.g., "Reach Target Weight").
    3.  Select Metric: "Weight".
    4.  Starting Value should prefill if weight data exists; otherwise, enter manually.
    5.  Enter Target Value (e.g., 70 kg). Unit should prefill to "kg".
    6.  Optionally select Target Date.
    7.  Tap "Set Goal".
*   **Expected Outcome:**
    *   Goal is saved (mocked API).
    *   New goal appears in the "Active Goals" list on ProgressScreen with a progress bar.

**Scenario 4.3: Change Chart Time Range**
*   **Steps:**
    1.  On ProgressScreen, select different time ranges (1M, 3M, 6M, All) using the segmented button.
*   **Expected Outcome:**
    *   Weight chart updates to display data for the selected time range.

## 5. Profile & Settings Feature

**Scenario 5.1: View Profile Information**
*   **Steps:**
    1.  Log in. Navigate to the "Profile" tab (ProfileScreen).
*   **Expected Outcome:**
    *   User's name, email, profile picture (placeholder if none) are displayed.
    *   Streak count is displayed.
    *   Summary of active goals is shown.

**Scenario 5.2: Edit Profile (Name and Units)**
*   **Steps:**
    1.  On ProfileScreen, tap the "Edit Profile" action (e.g., pencil icon in AppBar).
    2.  On EditProfileScreen:
        *   Change user's name.
        *   Change "Weight Unit" (e.g., to lbs).
        *   Change "Distance Unit" (e.g., to miles).
    3.  Tap "Save Changes".
*   **Expected Outcome:**
    *   Profile information is updated (mocked API, AuthManager updated).
    *   User is navigated back to ProfileScreen.
    *   Updated name is displayed on ProfileScreen.
    *   Units preference is saved in SettingsService. (Manual check: relevant data elsewhere in app should eventually use these units, though this might require further refactoring in other features).

**Scenario 5.3: Change App Settings (Theme)**
*   **Steps:**
    1.  On ProfileScreen, tap "Settings".
    2.  On SettingsScreen, change "Theme Mode" (e.g., to Light or Dark).
*   **Expected Outcome:**
    *   Theme preference is saved. (Visual change might require app restart or ThemeProvider integration, as noted in code).

**Scenario 5.4: Change Password (Mocked)**
*   **Steps:**
    1.  Navigate to SettingsScreen. Tap "Change Password".
    2.  Enter mock data for current, new, and confirm password fields.
    3.  Tap "Change Password".
*   **Expected Outcome:**
    *   A success message (mocked) is shown. User is navigated back from ChangePasswordScreen.

## 6. General UI/UX

**Scenario 6.1: Theme Consistency**
*   **Steps:**
    1.  Navigate through all major screens of the app (Home, Workout Plans, Create Workout, Active Workout, Nutrition, Log Meal, Progress, Profile, Settings, Edit Profile, Auth screens).
*   **Expected Outcome:**
    *   Consistent application of the dark theme (colors, fonts using GoogleFonts.inter, button styles, card styles, input field styles).
    *   No jarring deviations from the defined theme in `main.dart`.

**Scenario 6.2: Responsiveness (Conceptual)**
*   **Steps:**
    1.  If using a device/emulator that allows changing orientation or display size, try on a few key screens (Home, forms like Log Meal, charts on Progress).
*   **Expected Outcome:**
    *   No major UI overflows or elements becoming unusable. Content should reflow or scroll appropriately.

**Scenario 6.3: Error Handling and Loading States**
*   **Steps:**
    1.  Observe screens that load data (Home, Nutrition, Progress, Workout Plans).
    2.  Intentionally trigger errors if possible (e.g., disconnect internet if testing against a live mock server, though current mocks are in-memory).
    3.  Observe form submissions with invalid data (Login, Register, Log Weight, Set Goal, etc.).
*   **Expected Outcome:**
    *   Loading indicators (`CircularProgressIndicator`) are shown during data fetching.
    *   User-friendly error messages are displayed for API errors (mocked) or validation failures.
    *   App remains stable.
---

This list covers the main functionalities and provides a good basis for manual testing.

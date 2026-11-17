## Capstone Technical Roadmap & Checklist

### 1. Data Models & Persistence (`Models.swift` & `WheelStorageManager.swift`)
- [ ] **Custom `Codable` Model:** Create `SavedWheel` struct (`id`, `question`, `choices`, `lastWinner`, `createdAt`) conforming to `Codable` and `Equatable`.
- [ ] **Enums:** Implement `HapticIntensity` (`off`, `light`, `medium`, `heavy`) for user preferences and `WheelSpinState` (`ready`, `spinning`, `completed`) to manage wheel animations.
- [ ] **`UserDefaults` Persistence:** Build `WheelStorageManager` to encode/decode `[SavedWheel]` and `HapticIntensity` locally so saved wheels and settings persist across app launches.

### 2. Public API Integration (`MealAPIService.swift`)
- [ ] **`URLSession` & Escaping Closure:** Connect to [TheMealDB API](https://www.themealdb.com/api.php) using `URLSession.shared.dataTask` with an `@escaping` completion handler (no `async/await`).
- [ ] **JSON Parsing (`Codable`):** Parse API responses into `MealResponse` and `MealItem` structs.
- [ ] **"Inspire Me" Feature:** Add an **Inspire Me** button on `MainNavigationViewController` to fetch random meal ideas and auto-populate the question and choice fields.

### 3. Saved Wheels List (`UITableView`)
- [ ] **Table View Integration:** Add a `UITableView` to `MainNavigationViewController` displaying previously created `SavedWheel` items and their last winning option.
- [ ] **Selection & Deletion:** Support tapping a saved wheel row to load it directly into `DecisionWheelViewController` and swipe-to-delete to remove old wheels from `UserDefaults`.

### 4. Wheel Interaction & Custom Protocol (`DecisionWheelViewController` & `SelectionViewController`)
- [ ] **Roulette Wheel Rendering & Spin:** Draw dynamic wheel slices for each choice and animate a randomized spin using `WheelSpinState`.
- [ ] **Custom Delegate Protocol:** Define `SelectionViewControllerDelegate` (`didTapSpinAgain()`, `didTapClearWheel()`) so `SelectionViewController` communicates back to `DecisionWheelViewController` when dismissed.
- [ ] **Data Passing & Typecasting:** Pass `SavedWheel` and winning choice data across segues and modal presentations using safe optionals and typecasting (`as?`).

### 5. Settings & Polish (`SettingsViewController`)
- [ ] **Haptic Feedback:** Trigger `UIImpactFeedbackGenerator` during wheel spins based on the user's saved `HapticIntensity` selection.
- [ ] **Submission Deliverables:** Record a screen capture demo of the app running in the simulator/device and prepare a 4-minute presentation walkthrough.

 ## Progress & Features Implemented

### Architecture & Navigation Setup
- **Tab Bar & Navigation Flow:** Configured `MainTabBarController` with a `UINavigationController` root flow separating the **Create Wheel** tab (`circle.grid.cross`) and **Settings** tab.
- **Storyboard Scene Mapping:** Created and linked all five core view controller scenes to their corresponding Swift subclasses (`MainTabBarController`, `MainNavigationViewController`, `DecisionWheelViewController`, `SelectionViewController`, and `SettingsViewController`).

### Create Wheel Screen (`MainNavigationViewController`)
- **Question & Dynamic Choice Input UI:** Built the main entry interface with a question text field, a vertical `UIStackView` container configured with `Fill` alignment and `Fill Equally` distribution for dynamic option rows, and **+ Add Choice** / **Build Wheel** buttons.
- **Auto Layout Constraints:** Configured responsive edge-to-edge constraints so the choice list fills the center of the screen cleanly across device sizes.

<div>
    <a href="https://www.loom.com/share/53e83810e6fc48e2ad79c05846f10397">
    </a>
    <a href="https://www.loom.com/share/53e83810e6fc48e2ad79c05846f10397">
      <img style="max-width:300px;" src="https://www.loom.com/v1/videos/53e83810e6fc48e2ad79c05846f10397/thumbnail.gif">
    </a>
  </div>

## Overview

**Description**
- An app that allows the user to create a question with a series of options to choose from. A wheel that is similiar to a roulette wheel will be created with the options displayed on it. The user will be able to spin the wheel and have a decision made for them depending on the outcome.

**App Evaluation**
- Mobile: Could trigger haptics feedback as the wheel spins to mimic a real physical roulette wheel
Maybe also a shake to randomize features?
- Story: I feel like this app would be really popular with indecisive people. I have seen a lot of couples use flashcards to decide on a place to go, so this app could be used instead as a substitution.
- Market: I don't think this app has a well defined audience. Anyone could use it, but I envision indecisive individuals using this app more.
- Habit: The average person could open this app daily or once in a while. It depends on how indecisive they are.
The average user would have to add their own question and possible outcomes.
- Scope: I believe I could complete this app by its due date. I would be interested in building a stripped down version of this app.
- Product specs:
    - Required: A box that allows the user to input a question and a series of options. 
    - Required: A wheel containing the options. 
    - Required: A box that appears when an option is selected. A try again or clear option will appear after every spin. 
    - Optional: The wheel will trigger haptics feedback to mimic a real roulette wheel
    
**1. User Stories (Required and Optional)**
    Required Must-have Stories
- "As an indecesive dinner guest, I want to spin a wheel with restaurant options so that my group can quickly pick a place to eat."

**2. Screen Archetypes**
- Main Screen: Allows user to enter their question and build the list of choices.
- Decision wheel screen: Displays the customized roulette wheel and handles the spinning interaction.
 - Selection: Displays the winning option once the wheel stops spinning

**3. Navigation**

Tab Navigation (Tab to Screen)
- Create Wheel: Where user can enter a question, add options, and build a wheel
- Settings: Preferences for haptic feedback intensity
    
Flow Navigation (Screen to Screen) 
- Screen 1: Main Navigation:
    - Decision wheel screen
    - Settings screen
- Screen 2: Decision Wheel Screen Navigation:
    - Selection (Overlay appears when wheel finishes spinning)
    - Main
- Screen 3: Selection (Overlay) Navigation:
    - Decision wheel screen(Try again/Spin again)
    - Main (Clear)

**Wireframes**
<img width="1818" height="1263" alt="IMG_1479" src="https://github.com/user-attachments/assets/18142956-9a1e-41de-86e0-839abe41f58c" />

<div>
    <a href="https://www.loom.com/share/2b16ffc21d0149d28703f89e6f3499f1">
    </a>
    <a href="https://www.loom.com/share/2b16ffc21d0149d28703f89e6f3499f1">
      <img style="max-width:300px;" src="https://www.loom.com/v1/videos/2b16ffc21d0149d28703f89e6f3499f1/thumbnail.gif">
    </a>
  </div>
  

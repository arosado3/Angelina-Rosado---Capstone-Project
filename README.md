Overview

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
        - Selection (Overlay appears when wheel finishes spinning )
        - Main
    - Screen 3: Selection (Overlay) Navigation:
        - Decision wheel screen(Try again/Spin again)
        - Main (Clear)
...
Wireframes
<img width="1818" height="1263" alt="IMG_1479" src="https://github.com/user-attachments/assets/18142956-9a1e-41de-86e0-839abe41f58c" />

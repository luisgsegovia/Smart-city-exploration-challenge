# Implementation Strategy

## Techonologies, frameworks and dependencies
* **Programming language:** Swift
* **UI Framework**: SwiftUI
* **Networking:** `URLSession` is used for making network requests. No third party libraries needed.
* **Local persistence framework:** Core Data or UserDefaults (Core Data recommended for scalability and large data sets which is the main solution for this case, `UserDefaults` highly discouraged unless data is small and non-sensitive)

## Technical Quality

### Test Driven Development
A high use of TDD is essential to create a quality feature free of bugs. Every feature part implementation is created with the help of the TDD workflow. With this, we ensure we have a high code coverage throughout the whole application and that every possible case (inclusing edge cases) can be identified and covered early.

### Code integration workflow
In order to integrate new changes into the project, the following workflow and rules must be followed:

#### Branching
The branch naming must follow this format:
* [FEAT]|[BUG] [Ticket number]: Brief description of changes

#### Commits format

- API or UI relevant changes
    - `feat` Commits, that add or remove a new feature to the API or UI
    - `fix` Commits, that fix a API or UI bug of a preceded `feat` commit
- `refactor` Commits, that rewrite/restructure your code, however do not change any API or UI behaviour
    - `perf` Commits are special `refactor` commits, that improve performance
- `style` Commits, that do not affect the meaning (white-space, formatting, missing semi-colons, etc)
- `test` Commits, that add missing tests or correcting existing tests
- `docs` Commits, that affect documentation only
- `build` Commits, that affect build components like build tool, ci pipeline, dependencies, project version, ...
- `ops` Commits, that affect operational components like infrastructure, deployment, backup, recovery, ...
- `chore` Miscellaneous commits e.g. modifying `.gitignore`

##### Description
The `description` contains a concise description of the change.
- It is a **mandatory** part of the format
- Use the imperative, present tense: "change" not "changed" nor "changes"
  - Think of `This commit will...` or `This commit should...`
- Don't capitalize the first letter
- No dot (`.`) at the end

##### Body
The `body` should include the motivation for the change and contrast this with previous behavior.
- Is an **optional** part of the format
- Use the imperative, present tense: "change" not "changed" nor "changes"
- This is the place to mention issue identifiers and their relations

##### Examples

- ```
  feat: add API call on screen display
  ```
- ```
  fix(api): fix wrong calculation of request body checksum
  ```
- ```
  fix: add missing parameter to service call

  The error occurred due to <reasons>.
  ```
- ```
  perf: decrease memory footprint for determine uniqe visitors by using Logger
  ```
- ```
  build: update dependencies
  ```
- ```
  build(release): bump version to 1.0.0
  ```
- ```
  refactor: implement fibonacci number calculation as recursion
  ```
- ```
  style: remove empty line
  ```

---

#### Pull Request format
The PR should be filled with the requested information from the repo template, such as:
* Describe deeply the changes implemented with Screenshots or videos that support it
* Commits should be succint and written in and if needed, can have a deep explanation written in the secondary line
* Confirming every change has unit tests
* The app works as expected
* Switlint was run to ensure no code/typo errors are present

## Team workload organization
The workload is divided as follows taking into account modules, every one using the Test Driven Development approach:
* **Team Member 1:** Focus on the retrieval of Cities information from network, with models parsing and mapping
* **Team Member 2:** Create the Local Storage implementation with Core Data making sure the context and operations are executed in a background thread.
* **Team Member 3:** Develop the View Model logic and orchestration of inyected dependencies to execute operations as needed, such as the search functionality, remote and local retrieving, as well as formatting information to be used in the UI
* **Team member 4:** Create search helper implementation to be used for quick searches 
* **Team member 5:** Implement the UI as required by the design team, taking into account the layoutfor each orientation of the screen (portrait and landscape) and ensuring a consistent user experience
* **Team member 6:** Ensure a proper connection between modules and integration testing. Create the composition architecture when executing the app in the SceneDelegate code.




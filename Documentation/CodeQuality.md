# Code Quality

* **Technical Quality:**
	* **Code review:** This reviews are mandatory to be performed for every change to be integrated into the project to ensure a high code quality and coding standards.
	* **Unit tests:** Naturally, these are covered in a comprenhensive way with the TDD approach, as every new code change integrated in to the project is already tested alongside.
	* **Static analysis:** Use of tools such as SwiftLint and SonarQube help to enforce code quality both locally and remotely as Pull Request to avoid any potential issues.

* **Performance:**
	* **Memory Management:** Paying close attention to avoid memory leaks, specially with large datasets in memory or while searching to avoid bottlenecks, UI freezes or unexpected stuttering or even worse, app crashes
* **UX/UI**
	* **Intuitive UI:** Design a simple yet intuitive user interface for the user to interact with
	* **Real-time updates:** Ensuring dynamic UI updates as the user types or deletes characters in the seatch text field for smooth user experience
	* **Responsiveness:** UI should adapt correctly to diffent screen sizes and orientations
	* **Accesibility:** Sometimes understimated, making sure an app is highly accessible (e.g VoiceOver) can broaden the spectrum of users that can take advantage of this app.

## Code Quality Guardrails

The following code quality guardrails are enforced:

* **Meaningful Naming:** Use clear and descriptive names for variables, functions, and classes.
* **Code Comments:** Properly document complex logic and non-obvious code sections.
* **Avoid Magic Strings/Numbers:** Use constants for frequently used string literals and numerical values.
* **Error Handling:** Implement robust error handling for network requests and data parsing.
* **Dependency Injection:** Dependencies should be instantiated outside and injected by constructor or property to avoid tight coupling between modules. Also, this ensures testability, modularity and scalability.
* **Single Responsibility Principle:** Ensure that each class or function has a single, well-defined responsibility.
* **Test-Driven Development (TDD) Principles:** Encourage writing tests before or alongside the implementation code. As mentioned before, this is our north star
* **Adherence to MVVM:** Strictly follow the MVVM pattern to maintain a clean and organized codebase.

## CI/CD process
### Code quality checks: 
* **SwiftLint:** Tools like SwiftLint are integrated to automatically check our codebase for compliance to our defined coding standards and style guidelines. Any failures in validation will fail the build, forcing developers to fix them.
* **Static analyzer:** Tools such as SonarQube is used to identify potential code smells or defects, security vulnerabilities and maintainability issues. Reports will also include code coverage.

### Automated Testing:
* **Unit Tests:** The CI pipeline will execute all unit tests to verify the functionality of individual components (View Models, Services, etc.). If any unit test fails, the build will be marked as failed, preventing the integration of faulty code. We aim for high unit test coverage. 
* **UI Tests:** Automated UI tests will be executed to ensure the correct behavior of the user interface and user interactions within the feature. Failures in UI tests will also result in a failed build. This coulc become optional if changes do not affect UI to reduce build time when needed, otherwise they will run.

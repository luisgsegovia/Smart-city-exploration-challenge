# Delivery Strategy

## Continuous Delivery Method

Our CI/CD pipeline relies heavilty on the following tools:

* **CI/CD Platform:** GitHub actions is used to orchestrate the entire pipeline and trigger `fastlane` actions at the appropriate stages.
* **fastlane:** A suite of tools that automate common tasks for iOS app deployment. Some key `fastlane` tools we use are the following:
    * `match`: Synchronizing code signing certificates and profiles across the team.
    * `pilot`: Manages TestFlight testers and builds as well as build information
    * `upload_to_testflight`: Uploads builds to TestFlight.
    * `increment_build_number`: Incrementing the build number.
* **TestFlight:** Apple's platform for beta testing iOS, iPadOS, macOS, tvOS, and watchOS apps with internal and external testers.

## CI/CD for Code Quality and Delivery

As mentioned in the Code Quality section, we use the CI/CD workflow to check for code quality and automated testing. Here is a brief explanation of this strategy:

* **Linting:** The CI/CD will execute `fastlane` lanes configured to run linters like SwiftLint.
* **Static Analysis:** Similarly, `fastlane` can be used to trigger static analysis tools like SonarQube/SonarCloud
* **Unit Tests:** The CI/CD platform will execute `fastlane` lanes that run our unit tests
* **UI Tests:** `fastlane` will also be used to execute UI tests, ensuring the user interface behaves as expected.

## Building and Packaging
* **Code Signing:** `fastlane`'s `match` action is used to manage code signing certificates and provisioning profiles securely, allowing proper signing of the application which is highly important.
* **Version and Build Numbering:** `fastlane` actions `increment_build_number` and `increment_version_number` are used to automatically manage the application's version and build numbers during the CI process.
* **Building Artifacts:** `fastlane`'s `gym` action is used to build the iOS application (`.ipa` file) with the correct build configuration.

## Rollout strategy

A phased rollout strategy is implemented to production users, leveraging **TestFlight** for early feedback and App Store Connect's gradual release feature. The process is briefly described as follows:

1.  **Internal Testing:** Thorough testing by the development and QA teams on internal builds deployed via **TestFlight**.
2.  **Beta Testing (through TestFlight):** Release the feature to a small group of external beta testers via **TestFlight** (testers must apply via code by receiving an invitatin email) to gather feedback and identify any potential issues/bugs in a real-world environment.
3.  **Percentage Rollout (via App Store Connect):** Once we are confident in the stability and performance, we use App Store Connect's gradual release feature to roll out the application to a small percentage of our production users (for example, 5%, then 10%, then 25%, and so on). This allows us to monitor performance and identify any critical issues in the production environment before a full release.
4.  **Full Rollout:** After monitoring the performance and stability during the percentage rollout and addressing any issues, we proceed with the full rollout to all users via the App Store.

## Rollback Strategy

In case of critical issues detected after a production release, we have a rollback strategy in place as follows:

* **Quick Hotfix Release:** If the issue is minor and can be quickly resolved, we will prioritize a hotfix release through the CI/CD pipeline. We perform the same strategy as a common release/update, but in a quicker way.
* **Reverting to Previous Version:** If the issue is severe, we may need to revert to the previous stable version of the application. This process will also be automated as much as possible through the CI/CD pipeline.

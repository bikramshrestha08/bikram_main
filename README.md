# Development Setup

1. Install VSCode
2. For VSCode setting, tick `Format on save`

# Environment Setup

This project is using flutter. Please intall flutter with the version specified in the `.fvmrc` file.

After you have installed flutter successfully, use the following commands to run the project locally:

```
dart pub get
```

then

```
flutter run -d chrome
```

Using flutter version manager (`fvm`) is recommended because some other projects require a different flutter version. `fvm` allows you to swich flutter version easily.

To install `fvm`, see: https://fvm.app/documentation/getting-started/installation.

If you decide to use fvm, install `fvm` according to the above link, and then run the following commands at the project root folder

```
fvm install
```

This command will automatically install flutter with the version specified in the `.fvmrc` file.

Then, run the following command to run the project locally:

```
fvm flutter run -d chrome
```

# Git Workflow

1. Pull the latest code and create a new branch from `version-<latest_version>` branch. The new branch should be named as `<your_name>-<function>`.
2. Do all your works in `<your_name>-<function>` branch. Commit the changes regularly with message that introduce what you have done in each commit.
3. After you finished all your work, rebase your own `<your_name>-<function>` branch with `version-<latest_version>`. Resolve the potential conflicts (discuss with others if needed) and test your function again.
4. In the description part of your pull requests, use bullet points to briefly describe your changes. Open pull request to version-<latest_version> and ask member from Developer team to review your code.

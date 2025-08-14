# phpmodcompare

Bash script that compares mods installed for multiple PHP versions on the same system.

## Features
- Compares loaded PHP modules between two installed PHP versions
- Automatically detects and includes core modules for each version
- Reports missing and extra modules for each version

## Usage

```bash
./phpmodcompare.sh <version1> <version2>
# Example:
./phpmodcompare.sh 8.1 8.3
```

## Core Modules
The script automatically detects modules included in the PHP core for each version provided. There is no need to manually maintain exceptions arrays. This ensures accurate comparison for any PHP version installed on your system.

## Output
The script will show missing and extra modules between the two versions, including all core modules automatically.

# pubcat
Sample dart project - parse pubspec for each tag of given repo

## Usage:

1. Clone the repo:

    `git clone https://github.com/yashlamba/pubcat`

2. Switch Directory:

    `cd pubcat`

3. Run pub get:

    `dart pub get`

4. Run pubcat:

    `dart pubcat.dart <repo url> <pubspec path (optional)>`

5. Run `pubcat -h` for more options.
    ```console
    ~\..\pubcat ❯❯❯ dart .\pubcat.dart -h
    dart pubcat.dart <repo url> <pubspec path>
    -b, --branch     Clone specific branch of the repo.
    -c, --clean      Clean cloned repositories after use.
    -v, --verbose    Print pubspec.yaml contents
    -h, --help       pubcat help
    ```

Example: `dart pubcat.dart https://github.com/dart-lang/http`




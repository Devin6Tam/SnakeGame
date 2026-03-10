# AGENTS.md - Agent Guidelines for This Repository

## Project Overview

This is a Swift project (sampleExercise) for learning Swift language features. It uses Swift Package Manager and has an Xcode project for IDE support.

## Build, Run, and Test Commands

### Building the Project

```bash
# Using Swift Package Manager
swift build

# Using Xcode
# Open sampleExercise.xcodeproj in Xcode and build (Cmd+B)
```

### Running the Project

```bash
# Using Swift Package Manager
swift run

# Run a specific executable (if multiple targets exist)
swift run sampleExercise
```

### Testing

```bash
# Run all tests
swift test

# Run a single test (by test function name)
swift test --filter testFunctionName

# Run tests in a specific file
swift test --filter MyTests

# Run tests with verbose output
swift test -v
```

### Additional Commands

```bash
# Check Swift version
swift --version

# Package management
swift package init        # Initialize new package
swift package update      # Update dependencies
swift package resolve     # Resolve dependencies
```

## Code Style Guidelines

### General Principles

- Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use Swift 6.0+ features: `consuming`, `borrowing`, `actor`, `nonisolated`, `@retroactive`
- Prefer value types (`struct`, `enum`) over reference types (`class`) unless reference semantics are needed
- Use `actor` for thread-safe shared state (modern Swift concurrency)

### Formatting

- Use 4 spaces for indentation (not tabs)
- Maximum line length: 100 characters (soft guideline)
- Add trailing commas for multi-line arrays/dictionaries
- Use trailing closure syntax when appropriate
- Enable SwiftFormat or use Xcode's built-in formatting (Ctrl+I)

### Naming Conventions

- **Types/Classes/Structs/Enums**: PascalCase (`MyClass`, `AccountManager`)
- **Functions/Methods**: camelCase, verb prefix (`fetchData()`, `calculateTotal()`)
- **Variables/Properties**: camelCase (`userName`, `isValid`)
- **Constants**: camelCase with meaningful names (`maxRetries`, `defaultTimeout`)
- **Acronyms**: Keep uppercase if 2 letters (`URL`, `API`, `ID`), lowercase if 3+ (`Http`, `Wifi`)
- **Enums**: Use PascalCase for type, lowercase for cases (`Color.red`, `Result.success`)

### Imports

- Group imports: Standard library first, then third-party, then local
- Use specific imports when possible (`import Foundation` not `import UIKit` unless needed)
- Remove unused imports

### Types and Annotations

- Always specify types for function parameters and return types
- Use type inference for local variables when type is obvious
- Prefer protocol types over concrete types in function signatures
- Use `some Type` for opaque return types
- Mark functions as `throws` for error-prone operations
- Use `async`/`await` for asynchronous operations (not completion handlers)

### Error Handling

- Use `throws` and `try`/`try?`/`try!` for recoverable errors
- Use `Result<T, Error>` for operations with multiple failure cases
- Avoid `try!` in production code
- Create custom error enums conforming to `Error` for domain-specific errors

### Memory Management

- Use `weak` and `unowned` for delegate/retain cycles
- Prefer value types to avoid memory issues
- Use `defer` for cleanup code
- For unsafe operations, follow Swift's memory management guidelines

### Access Control

- Use `private` as default for implementation details
- Use `fileprivate` for shared implementation within a file
- Use `internal` for package-internal APIs
- Use `public` for library APIs
- Use `private(set)` for properties that should be read-only externally

### Concurrency

- Use `actor` for shared mutable state
- Use `@MainActor` for UI-related code
- Mark functions as `nonisolated` when they don't need actor isolation
- Use `Task` for spawning async work
- Use `TaskGroup` for parallel operations

### Documentation

- Use `///` for single-line documentation comments
- Use `/** ... */` for multi-line documentation
- Document public APIs, especially complex ones
- Include parameter and return value descriptions

### Testing

- Name test files: `<ClassName>Tests.swift`
- Name test functions: `test<Description>()` or `test<Description>_<Condition>()`
- Use XCTest or Swift Testing (@Test, @Suite)
- Use `#expect()` for assertions in Swift Testing
- Use `XCTAssert*` functions for XCTest

### Common Patterns

```swift
// Property wrappers for configuration
@propertyWrapper
struct Atomic<T> {
    var wrappedValue: T
}

// Actor for thread-safe state
actor DataManager {
    private var cache: [String: Data] = [:]
    
    func store(_ data: Data, forKey key: String) {
        cache[key] = data
    }
    
    func retrieve(forKey key: String) -> Data? {
        cache[key]
    }
}

// Use defer for cleanup
func processFile() throws {
    let file = try FileHandle(...)
    defer { try? file.close() }
    // process file
}

// Use guard for early exit
func process(data: Data?) {
    guard let data = data else { return }
    // process data
}
```

### What to Avoid

- Avoid force unwrapping (`!`) in production code
- Avoid implicit unwrapping (`!` for optionals)
- Avoid `as!` type casting
- Avoid global mutable state
- Avoid retain cycles (check for `[weak self]` in closures)
- Avoid blocking the main thread with synchronous operations

## Xcode Project Notes

- The project includes both `sampleExercise.xcodeproj` and `Package.swift`
- For Xcode development, open the `.xcodeproj` file
- For SPM-based workflows, use command-line tools

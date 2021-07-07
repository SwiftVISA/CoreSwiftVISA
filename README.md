<img src="https://github.com/SwiftVISA/CoreSwiftVISA/blob/master/SwiftVISA%20Logo.png" width="512" height="512">

# CoreSwiftVISA

This package defines base types and functionality that is used by both NISwiftVISA and SwiftVISASwift. Alone, CoreSwiftVISA does not provide any useful functionality; it does not provide any means to communicate with VISA instruments. Instead, it defines the base types and protocols that are used by NISwiftVISA and SwiftVISASwift which *do* allow for communiction with VISA instruments. CoreSwiftVISA makes it simpler to abstract away implementation details, which allows for easily migration between different VISA backends. CoreSwiftVISA can even be used to create custom backends for VISA instruments or other types of instruments.

## Requirements

- Swift 5.5+

Although the only hard requirement is Swift 5.5+, backends may have additional requirements.

## Installation

Installation can be done through the [Swift Package Manager](https://swift.org/package-manager/). To use the CoreSwiftVISA package in your project, include the following dependency in your `Package.swift` file.
```swift
dependencies: [
    .package(url: "https://github.com/SwiftVISA/CoreSwiftVISA.git", branch: "actor")
]
```

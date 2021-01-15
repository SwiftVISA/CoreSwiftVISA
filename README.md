<img src="https://github.com/SwiftVISA/CoreSwiftVISA/blob/master/SwiftVISA%20Logo.png" width="512" height="512">

# CoreSwiftVISA

This package defines base types and functionality that is used by both NISwiftVISA and SwiftVISASwift. Alone, CoreSwiftVISA does not provide any useful functionality; it does not provide any means to communicate with VISA instruments. Instead, it defines the base types and protocols that are used by NISwiftVISA and SwiftVISASwift which *do* allow for communiction with VISA instruments. CoreSwiftVISA makes it simpler to abstract away implementation details, which allows for easily migration between different VISA backends. CoreSwiftVISA can even be used to create custom backends for VISA instruments or other types of instruments.

## Requirements

- Swift 5.0+

Although the only hard requirement is Swift 5.0+, most backends have additional requirements.

## Installation

Installation can be done through the [Swift Package Manager](https://swift.org/package-manager/). To use the CoreSwiftVISA package in your project, include the following dependency in your `Package.swift` file.
```swift
dependencies: [
    .package(url: "https://github.com/SwiftVISA/CoreSwiftVISA.git", .upToNextMinor(from: "0.1.0"))
]
```

Both NISwiftVISA and SwiftVISASwift export this package so that this package doesn't need to be manually added as a dependency to projects using them. If you are using either NISwiftVISA or SwiftVISASwift, you don't need to add this package to your dependencies or import CoreSwiftVISA.

## Backends

The main purpose of this package is to be used as the base package for backends communicating with VISA instruments (although it can also be used for backends communicating with other instruments as well). We provide two such backends:

1. NISwiftVISA: A package which uses NI's C VISA backend (closed source). This package is only available for intel macOS devices, as NI only provides binaries for intel macOS devices and Windows (Windows is not yet supported).
2. SwiftVISASwift: A package which provides a custom backend written in Swift foc communicating with VISA instruments. Currently communicaiton is only supported over TCPIP.

## Custom Backends

If NISwiftVISA and SwiftVISASwift don't fit your needs, you can use this package to create a custom backend to communicate with insturments. By using CoreSwiftVISA as the base for your backend, it will allow users to easily transition from one of our backends to yours. Additionally, it will allow users to use multiple backends at once without difficulty if they need to do so. A custom backend defines one or several types to communicate with instruments. Follow these steps to create custom instruments:

1. Create a class conforming to the `Session` protocol. You will need to implement the following two functions in order to adopt the `Session` protocol:
```swift
/// Close the sesssion's connection (end the connection to the instrument).
public func close() throws

/// Reconnect the session (re-establish the conneciton to the instrument).
public func reconnect(timeout: TimeInterval) throws
```

2. Create one or more classes conforming to the `Instrument` protocol. You will need to add a (gettable) property of type `Session`. 

3. If your instrument is intended to be communicated with via strings of text, adopt the `MessageBasedInstrument` protocol. You will need to implement the following methods and properties:
```swift
/// Instrument attributes, such as terminators and encodings.
var attributes: MessageBasedInstrumentAttributes { get set }

/// Reads string data from the device until the terminator is reached.
/// - Parameters:
///   - terminator: The string to end reading at.
///   - strippingTerminator: If `true`, the terminator is stripped from the string before being returned, otherwise the string is returned with the terminator at the end.
///   - encoding: The encoding used to encode the string.
///   - chunkSize: The number of bytes to read into a buffer at a time.
/// - Throws: If the device could not be read from.
/// - Returns: The string read from the device.
func read(
  until terminator: String,
  strippingTerminator: Bool,
  encoding: String.Encoding,
  chunkSize: Int
) throws -> String

/// Reads the given number of bytes from the device.
/// - Parameters:
///   - length: The number of bytes to read.
///   - chunkSize: The number of bytes to read into a buffer at a time.
/// - Throws: If the device could not be read from.
/// - Returns: The bytes read from the device.
func readBytes(length: Int, chunkSize: Int) throws -> Data

/// Reads bytes from the device until the given sequence of data is reached.
/// - Parameters:
///   - maxLength: The maximum number of bytes to read.
///   - terminator: The byte sequence to end reading at.
///   - strippingTerminator: If `true`, the terminator is stripped from the data before being returned, otherwise the data is returned with the terminator at the end.
///   - chunkSize: The number of bytes to read into a buffer at a time.
/// - Throws: If the device could not be read from.
/// - Returns: The bytes read from the device.
func readBytes(
	maxLength: Int?,
	until terminator: Data,
	strippingTerminator: Bool,
	chunkSize: Int
) throws -> Data

/// Writes a string to the device.
/// - Parameters:
///   - string: The string to write to the device.
///   - terminator: The terminator to add to the end of `string`.
///   - encoding: The method to encode the string with.
/// - Throws: If the device could not be written to.
/// - Returns: The number of bytes that were written.
@discardableResult
func write(
	_ string: String,
	appending terminator: String?,
	encoding: String.Encoding
) throws -> Int

/// Writes bytes to the device.
/// - Parameters:
///   - bytes: The data to write to the device.
///   - terminator: The sequence of bytes to append to the end of `bytes`.
/// - Throws: If the device could not be written to.
/// - Returns: The number of bytes that were written.
@discardableResult
func writeBytes(_ data: Data, appending terminator: Data?) throws -> Int
```
If your instrument is intended to be communicated through a custom interface, implement your interface on your `Instrument` types. If you are making multiple instruments with the same interface, consider creating a protocol `protocol MyCustomInstrument: Instrument` that defines the interface; then have your types conform to `MyCustomInstrument`. If you believe that others may want to create their own instrument types conforming to `MyCustomInstrument`, consider creating your own package containing the protocol, and have your package containing the implementation of your instrument types in another package. This will allow others to create additional instruments using the same interface without requiring users to include unneeded instrument types.

4. Make a public extension to `InstrumentManager` containing methods to create instances of your instruments. No initializers for you instrument types should be public.

5. Create a file named "\_Exported.swift". In this file add the following:
```swift
@_exported import CoreSwiftVISA
```
This will automatically import CoreSwiftVISA when users import your package. This will allow the user to use types defined in CoreSwiftVISA such as `Instrument` without having to manually import CoreSwiftVISA.

Consider looking through the source code for NISwiftVISA and SwiftVISASwift for understanding how to implement backends.

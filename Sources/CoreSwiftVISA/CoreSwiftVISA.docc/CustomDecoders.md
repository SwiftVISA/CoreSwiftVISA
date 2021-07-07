# Custom Decoders

Customize the decoding of types from instruments.

## Overview

`CoreSwiftVISA` includes default decoding of `String`, `Int`, `Bool`, and `Double` types. However, it is possible to define decodes for other types, or to define decoders for customizing decoding of the included types.

## Decoding Custom Type

To make a new type decodable, you will have to create a new decoder type that conforms to either ``MessageDecoder`` or ``ByteDecoder``. Instruments that receive data as strings should implement ``MessageDecoder`` and instruments that receive data as bytes should implement ``ByteDecoder``. The following defines a decoder for `CGPoint`:

```swift
struct CGPointDecoder: MessageDecoder {
  // This determines the type that your decoder will decode to. In this case CGPoint.
  typealias DecodingType = CGPoint

  // We define a custom error type to throw if we cannot decode
  enum Error: Swift.Error {
    case wrongNumberOfComponents
    case componentNotANumber
  }
  
  // Here is where we write our decoding logic:
  func decode(_ message: String) throws -> DecodingType {
    // Split the message into components separated by the "," character
    let components = message.split(",")
    // There should be two components (x and y)
    guard components.count == 2 else { throw Error.wrongNumberOfComponents }
    let coordinates = try components.map { component in 
      // Convert each component into a Double
      if let coordinate = Double(component) {
        return coordinate
      } else {
        throw Error.componentNotANumber
      }
    }
    
    return CGPoint(x: coordinates[0], y: coordinates[1])
  }
}
```

We can now use this decoder:

```swift
let point = try await instrument.query(
  "LOCATION?", 
  as: CGPoint.self,
  using: CGPointDecoder()
)
```

We can go further and make this the default decoder, so we don't have to manually specify the decoder to use each time. Instead we would be able to simple specify the type `CGPoint` and this decoder would be used. To do this, we need to add an extension conforming `CGPoint` to ``MessageDecodable`` (or ``ByteDecodable`` if our instrument sent messages as bytes):

```swift
extension CGPoint: MessageDecodable {
  // This static property will return the decoder we would like to use as default.
  static var defaultMessageDecoder: CGPointDecoder {
    return CGPointDecoder()
  }
}
```

Now when decoding to `CGPoint`, the `CGPointDecoder` will be used unless otherwise specified:

```swift
// Will implicitly use CGPointDecoder() to decode
let point = try await instrument.query(
  "LOCATION?",
  as: CGPoint.self
)

// We can still specify another decoder if we had made another decoder:
let otherPoint = try await instrument.query(
  "RADIALLocation?",
  as: CGPoint.self,
  using: RadialCGPointDecoder()
)
```

## Customizing Decoding for Built-ins

`CoreSwiftVISA` defines default decoders for `String`, `Int`, `Bool`, and `Double`. However, it may sometimes be preferable to decode these types in a custom manor. To do so, we can declare a new decoder type that conforms to ``MessageDecoder`` (or to ``ByteDecoder`` if using instruments that communicate over bytes). The following defines a decoder for `Int` which rounds any floating-point numbers it receives:

```swift
struct RoundingIntDecoder: MessageDecoder {
  // Here we put the type we want to decode to. In this case, Int
  typealias DecodingType = Int

  // We define a custom error type to throw if we cannot decode
  enum Error: Swift.Error {
    case notANumber
    case magnitudeTooLarge
  }

  func decode(_ message: String) throws -> DecodingType {
    guard let number = Double(message) else {
      // If the message can't be converted to a Double, it isn't a number at all
      throw Error.notANumber
    }

    guard !number.isNaN else {
      throw Error.notANumber
    }

    let rounded = round(number)
    
    guard let integer = Int(exactly: rounded) else {
      // If the number can't be expressed exactly as an integer after rounding, it's magnitude is too large
      throw Error.magnitudeTooLarge
    }

    return integer
  }
}
```

We can now use this decoder instead of the default one:

```swift
let voltage = try await instrument.decode(
  "VOLTage?", 
  as: Int.self,
  using: RoundingIntDecoder()
)
```

If you would like to replace the default decoder to use for `String`, `Int`, `Bool`, or `Double`, you can set the `customDecode` property on the respective default decoder type:

```swift
DefaultIntDecoder.customDecode = RoundingDecoder().decode(_:)

// Will now use the DefaultIntDecoder() decoding unless specified
let rounded = try await instrument.query(
  "VALUE?",
  as: Int.self
)
```

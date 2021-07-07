# MessageBasedInstrument Guide

Write to, read from, and query instruments.

## Overview

The primary way to communicate with modern instruments over VISA is via string or byte messages. ``MessageBasedInstrument`` defines an interface for writing to and reading from these types of instruments. `SwiftVISA` provides a number of customization options to make it easy to work with instruments that use nonstandard newlines, terminators, separators, encodings, etc.

## Writing

Writing commands to instruments is achieved using the following commands:
- ``MessageBasedInstrument/write(_:appending:encoding:)-8gl3a``
- ``MessageBasedInstrument/writeBytes(_:appending:)-48oql``

``MessageBasedInstrument/write(_:appending:encoding:)-8gl3a`` is used to write a string command to your instrument. The following writes the SCPI command `"OUTPUT ON"` to an instrument:
```swift
try await instrument.write("OUTPUT ON")
```

You can optionally provide a terminating character and the encoding to use:
```swift
try await instrument.write("OUTPUT ON", appending: "\n", encoding: .ascii)
```

``MessageBasedInstrument/writeBytes(_:appending:)-48oql`` is used to write raw bytes to your instrument. The following writes the contents at the given file to the instrument:
```swift
let url = URL(fileURLWithPath: "~/Documents/Data/example.dat"
let data = try Data(contentsOf: url)
try await instrument.writeBytes(data)
```

You can optionally provide a terminating sequence of data:
```swift
try await instrument.writeBytes(data, appending: Data(repeating: 0, count: 8)
```

By default the terminating character and encoding are set to `nil`, which fetches the default terminator and encoding from the instrument's ``MessageBasedInstrument/attributes``. You can set ``MessageBasedInstrumentAttributes/writeTerminator`` or ``MessageBasedInstrumentAttributes/encoding`` to change the defaults for the instrument.

Both functions return a discardable `Int`, which represents the number of bytes that were written.

## Reading

Reading data from instruments is achieved using the following commands:
- ``MessageBasedInstrument/read(until:strippingTerminator:encoding:chunkSize:)-6poq6``
- ``MessageBasedInstrument/readBytes(length:chunkSize:)-1wtxp``
- ``MessageBasedInstrument/readBytes(maxLength:until:strippingTerminator:chunkSize:)-2pguy``

``MessageBasedInstrument/read(until:strippingTerminator:encoding:chunkSize:)-6poq6`` is used to read string data from your instrument. The following reads the current string data from the instrument:
```swift
let stringData = try await instrument.read()
```

This function reads data until the instrument's terminating sequence is reached. You can specify a custom terminating character to read until, whether or not to strip the terminating sequence, the string encoding, and the chunk size to use when reading the data
```swift
let stringData = try await instrument.read(
  until: "\n"
  strippingTerminator: false,
  encoding: .utf8,
  chunkSize: 4096
)
```

``MessageBasedInstrument/readBytes(length:chunkSize:)-959i5`` is used to read raw data from your instrument of the specified length. The following reads 16 bytes of data from the instrument:
```swift
let data = try await instrument.readBytes(length: 16)
```

You can specify the chunk size to use when reading the data:
```swift
let data = try await instrument.readBytes(length: 16, chunkSize: 2048)
```

``MessageBasedInstrument/readBytes(maxLength:until:strippingTerminator:chunkSize:)-2pguy`` is used to read raw data from your instrument until the terminator is reached:
```swift
let data = try await instrument.readBytes()
```

You can specify the maximum number of bytes to read, the terminator to read until, whether to strip the terminator, and the chunk size to use when reading the data:
```swift
let data = try await instrument.readBytes(
  maxLength: 4096, 
  until: Data(repeating: 0, count: 32
  strippingTerminator: false,
  chunkSize: 1024
)
```

By default the terminating character, encoding, and chunk size are set to `nil`, which fetches the default values from the instrument's ``MessageBasedInstrument/attributes``. You can set ``MessageBasedInstrumentAttributes/readTerminator``, ``MessageBasedInstrumentAttributes/encoding``, and ``MessageBasedInstrumentAttributes/chunkSize`` to change the defaults for the instrument.

## Query

Often, it is desirable to read back information from an instrument directly after writing a command to it. This can be accomplished with query commands. Query commands also support decoding the received data into other types. Querying is achieved with the following commands:
- ``MessageBasedInstrument/query(_:)``
- ``MessageBasedInstrument/query(_:as:)``
- ``MessageBasedInstrument/query(_:as:using:)``
- ``MessageBasedInstrument/queryBytes(_:length:as:)``
- ``MessageBasedInstrument/queryBytes(_:length:as:using:)``
- ``MessageBasedInstrument/queryBytes(_:maxLength:as:)``
- ``MessageBasedInstrument/queryBytes(_:maxLength:as:using:)``

``MessageBasedInstrument/query(_:)`` is used to write a string command to your instrument and receive its data back as a string:
```
let voltageString = try await instrument.query("VOLTAGE?")
```

``MessageBasedInstrument/query(_:as:)`` is used to write a string command to your instrument, receive its data back as a string and decode the string into the given data type using the type's default decoder. The data type much conform to ``MessageDecodable``. `SwiftVISA` adds ``MessageDecodable`` conformance to `String`, `Int`, `Bool`, and `Double`:
```swift
let voltage = try await instrument.query("VOLTAGE?", as: Double.self)
```

``MessageBasedInstrument/query(_:as:using:)`` is used to write a string command to your instrument, receive its data back as a string and decode the string into the given data type using a custom decoder. The decoder must conform to ``MessageDecoder``, and its ``MessageDecoder/DecodingType`` must be equal to the value passed to `type` (see <doc:CustomDecoders>):
```swift
let voltage = try await instrument.query("VOLTAGE?", as: Int.self, using: RoundingIntDecoder())
```

``MessageBasedInstrument/queryBytes(_:length:as:)`` is used to write bytes to your instrument, receive the given number of bytes back and decode the data into the given data type using the type's default decoder. The data type much conform to ``ByteDecodable``. `SwiftVISA` adds ``ByteDecodable`` conformance to no types. You will need to define your own.

``MessageBasedInstrument/queryBytes(_:length:as:using:)`` is used to write bytes to your instrument, receive the given number of bytes back and decode the data into the given data type using a custom decoder. The decoder must conform to ``ByteDecoder``, and its ``ByteDecoder/DecodingType`` must be equal to the value passed to `type` (see <doc:CustomDecoders>).

``MessageBasedInstrument/queryBytes(_:maxLength:as:)`` is used to write bytes to your instrument, receive bytes back (you can specify the maximum number of bytes as well) and decode the data into the given data type using the type's default decoder. The data type much conform to ``ByteDecodable``. `SwiftVISA` adds ``ByteDecodable`` conformance to no types. You will need to define your own.

``MessageBasedInstrument/queryBytes(_:maxLength:as:using:)`` is used to write bytes to your instrument, receive bytes back (you can specify the maximum number of bytes as well) and decode the data into the given data type using a custom decoder. The decoder must conform to ``ByteDecoder``, and its ``ByteDecoder/DecodingType`` must be equal to the value passed to `type` (see <doc:CustomDecoders>).

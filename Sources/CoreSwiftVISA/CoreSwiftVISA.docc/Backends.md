# Backends

CoreSwiftVISA by itself does not provide a way to communicate with any instruments. Instead, communication with instruments is implemented by VISA backends. All backends export this package, so unless you are creating a custom backend, it is unlikely that you will manually need to add this package as a dependency or import this package.

## SwiftVISA Backends

The SwiftVISA team provides two backends:

### NISwiftVISA

[NISwiftVISA](https://github.com/SwiftVISA/NISwiftVISA) is a package which uses NI's official C VISA backend (closed source). This package relies on the user having  [NI C VISA](https://www.ni.com/en-us/support/downloads/drivers/download.ni-visa.html#346210) installed. `NISwiftVISA` has support for more instruments, but also requires a background process to be running.

### SwiftVISASwift

[SwiftVISASwift](https://github.com/SwiftVISA/SwiftVISASwift) is a package which does *not* require the use of NI's C VISA backend. It is fully open sourced. `SwiftVISASwift` currently only supports communication with instruments over TCPIP.

## Custom Backends

If `NISwiftVISA` and `SwiftVISASwift` don't fit your needs, you can use this package to create a custom backend to communicate with instruments. By using `CoreSwiftVISA` as the base for your backend, it will allow users to easily transition from one of our backends to yours. Additionally, it will allow users to use multiple backends at once without difficulty if they need to do so. A custom backend defines one or several types to communicate with instruments. Follow these steps to create custom instruments:

1. Create a class conforming to the ``Session`` protocol. You will need to implement the following two functions in order to adopt the ``Session`` protocol:
    - ``Session/close()``
    - ``Session/reconnect(timeout:)``

2. Create one or more classes conforming to the ``Instrument`` protocol. You will need to implement ``Instrument/session``. 

3. If your instrument is intended to be communicated with via strings of text, adopt the ``MessageBasedInstrument`` protocol. You will need to implement the following methods and properties:
    - ``MessageBasedInstrument/attributes``
    - ``MessageBasedInstrument/read(until:strippingTerminator:encoding:chunkSize:)-4pofu``
    - ``MessageBasedInstrument/readBytes(length:chunkSize:)-959i5``
    - ``MessageBasedInstrument/readBytes(maxLength:until:strippingTerminator:chunkSize:)-2f4b1``
    - ``MessageBasedInstrument/write(_:appending:encoding:)-8gl3a``
    - ``MessageBasedInstrument/writeBytes(_:appending:)-g9tz``
    - If your instrument is intended to be communicated through a custom interface, implement your interface on your ``Instrument`` types. If you are making multiple instruments with the same interface, consider creating a protocol `protocol MyCustomInstrument: Instrument` that defines the interface; then have your types conform to `MyCustomInstrument`. If you believe that others may want to create their own instrument types conforming to `MyCustomInstrument`, consider creating your own package containing the protocol, and have your package containing the implementation of your instrument types in another package. This will allow others to create additional instruments using the same interface without requiring users to include unneeded instrument types.

4. Make a public extension to ``InstrumentManager`` containing methods to create instances of your instruments. No initializers for you instrument types should be public.

5. Create a file named "\_Exported.swift". In this file add the following:
"`@_exported import CoreSwiftVISA`". This will automatically import `CoreSwiftVISA` when users import your package. This will allow the user to use types defined in `CoreSwiftVISA` such as ``Instrument`` without having to manually import `CoreSwiftVISA`.

Consider looking through the source code for `NISwiftVISA` and `SwiftVISASwift` for understanding how to implement backends.

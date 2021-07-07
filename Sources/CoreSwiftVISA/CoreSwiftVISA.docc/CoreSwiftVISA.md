# ``CoreSwiftVISA``

Provides the foundation to communicate with VISA instruments.

## Overview

CoreSwiftVISA defines base types and functionality that is used by both `NISwiftVISA` and `SwiftVISASwift`. Alone, ``CoreSwiftVISA`` does not provide any means to communicate with instruments. Instead it defines the types and protocols that are used by `NISwiftVISA` and `SwiftVISASwift` which *do* allow for communication with VISA instruments. `CoreSwiftVISA` makes it simpler to abstract away implementation details, making it trivial to migrate between different VISA backends. `CoreSwiftVISA` can even be used to create custom backends for VISA instruments or other types of instruments.

## Topics

### Instruments and Sessions

- ``Session``
- ``Instrument``
- ``MessageBasedInstrument``
- <doc:MessageBasedInstrumentGuide>

### Decoding

- ``MessageDecoder``
- ``MessageDecodable``
- ``ByteDecoder``
- ``ByteDecodable``
- <doc:CustomDecoders>

### Default Decoders

- ``DefaultStringDecoder``
- ``DefaultIntDecoder``
- ``DefaultDoubleDecoder``
- ``DefaultBoolDecoder``

### Backends

- <doc:Backends>

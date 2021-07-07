//
//  MessageBasedInstrument.swift
//  
//
//  Created by Connor Barnes on 9/13/20.
//

import Foundation

/// An instrument that can be communicated with via strings or raw bytes.
public protocol MessageBasedInstrument: Instrument {
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
  ) async throws -> String
  
  /// Reads the given number of bytes from the device.
  /// - Parameters:
  ///   - length: The number of bytes to read.
  ///   - chunkSize: The number of bytes to read into a buffer at a time.
  /// - Throws: If the device could not be read from.
  /// - Returns: The bytes read from the device.
  func readBytes(length: Int, chunkSize: Int) async throws -> Data
  
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
  ) async throws -> Data
  
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
  ) async throws -> Int
  
  /// Writes bytes to the device.
  /// - Parameters:
  ///   - bytes: The data to write to the device.
  ///   - terminator: The sequence of bytes to append to the end of `bytes`.
  /// - Throws: If the device could not be written to.
  /// - Returns: The number of bytes that were written.
  @discardableResult
  func writeBytes(_ data: Data, appending terminator: Data?) async throws -> Int
}

// MARK: - Convenience Methods
public extension MessageBasedInstrument {
  /// Reads string data from the device until the terminator is reached.
  /// - Parameters:
  ///   - terminator: The string to end reading at. By default, or if `nil`, `attributes.readTerminator` is used.
  ///   - strippingTerminator: If `true`, the terminator is stripped from the string before being returned, otherwise the string is returned with the terminator at the end. `true` by default.
  ///   - encoding: The encoding used to encode the string. By default, or if `nil`, `attributes.encoding` is used.
  ///   - chunkSize: The number of bytes to read into a buffer at a time. By default, or if `nil`, `attributes.chunkSize` is used.
  /// - Throws: If the device could not be read from.
  /// - Returns: The string read from the device.
  func read(
    until terminator: String? = nil,
    strippingTerminator: Bool = true,
    encoding: String.Encoding? = nil,
    chunkSize: Int? = nil
  ) async throws -> String {
    return try await read(
      until: terminator ?? attributes.readTerminator,
      strippingTerminator: strippingTerminator,
      encoding: encoding ?? attributes.encoding,
      chunkSize: chunkSize ?? attributes.chunkSize
    )
  }
  
  /// Reads the given number of bytes from the device.
  /// - Parameters:
  ///   - length: The number of bytes to read.
  ///   - chunkSize: The number of bytes to read into a buffer at a time. By default, or if `nil`, `attributes.chunkSize` is used.
  /// - Throws: If the device could not be read from.
  /// - Returns: The bytes read from the device.
  func readBytes(length: Int, chunkSize: Int? = nil) async throws -> Data {
    return try await readBytes(length: length, chunkSize: chunkSize ?? attributes.chunkSize)
  }
  
  /// Reads bytes from the device until the given sequence of data is reached.
  /// - Parameters:
  ///   - maxLength: The maximum number of bytes to read. `nil` by default.
  ///   - terminator: The byte sequence to end reading at. By default, or if `nil`, `attributes.readTerminator` is used.
  ///   - strippingTerminator: If `true`, the terminator is stripped from the data before being returned, otherwise the data is returned with the terminator at the end. `true` by default.
  ///   - chunkSize: The number of bytes to read into a buffer at a time. By default, or if `nil`, `attributes.chunkSize` is used.
  /// - Throws: If the device could not be read from.
  /// - Returns: The bytes read from the device.
  func readBytes(
    maxLength: Int? = nil,
    until terminator: Data? = nil,
    strippingTerminator: Bool = true,
    chunkSize: Int? = nil
  ) async throws -> Data {
    guard let terminator = terminator
            ?? attributes.readTerminator.data(using: attributes.encoding)
    else {
      throw CommunicatorError.couldNotEncode
    }
    
    return try await readBytes(
      maxLength: maxLength,
      until: terminator,
      strippingTerminator: strippingTerminator,
      chunkSize: chunkSize ?? attributes.chunkSize
    )
  }
  
  /// Writes a string to the device.
  /// - Parameters:
  ///   - string: The string to write to the device.
  ///   - terminator: The terminator to add to the end of `string`. By default, or if `nil`, `attributes.writeTerminator` is used.
  ///   - encoding: The method to encode the string with. By default, or if `nil`, `attributes.encoding` is used.
  /// - Throws: If the device could not be written to.
  /// - Returns: The number of bytes that were written.
  @discardableResult
  func write(
    _ string: String,
    appending terminator: String?? = .some(nil),
    encoding: String.Encoding? = nil
  ) async throws -> Int {
    try await write(
      string,
      appending: terminator ?? attributes.writeTerminator,
      encoding: encoding ?? attributes.encoding
    )
  }
  
  /// Writes bytes to the device.
  /// - Parameters:
  ///   - bytes: The data to write to the device.
  ///   - terminator: The sequence of bytes to append to the end of `bytes`. By default, or if `nil`, `attributes.terminator` is used.
  /// - Throws: If the device could not be written to.
  /// - Returns: The number of bytes that were written.
  @discardableResult
  func writeBytes(_ bytes: Data, appending terminator: Data?? = .some(nil)) async throws -> Int {
    guard let terminator = terminator ??
            attributes.writeTerminator.data(using: attributes.encoding) else {
              throw CommunicatorError.couldNotEncode
            }
    
    return try await writeBytes(bytes, appending: terminator)
  }
}

// MARK: - Errors
/// An generic communicator error.
public enum CommunicatorError: Error {
  case couldNotEncode
}

// MARK: - Attributes
/// Instrument attributes for customizing communication to VISA compliant instruments.
public struct MessageBasedInstrumentAttributes {
  /// The string to terminate messages with when reading from an instrument.s
  public var readTerminator = "\n"
  
  /// The string to terminate messages with when writing to an instrument.
  public var writeTerminator = "\n"
  
  /// The delay in seconds to wait before reading or writing. Some instruments will fail when writing to or reading from in too short succession.
  ///
  /// - Note: It is the responsibility of the type adopting this protocol to respect this delay.
  public var operationDelay: TimeInterval = 1e-3
  
  /// The size in bytes to read data from the instrument at a time.
  public var chunkSize = 1024
  
  /// The string encoding to use when decoding from the instrument, or when encoding to write to the instrument.
  public var encoding: String.Encoding = .utf8
  
  /// Creates the default set of attributes.
  public init() { }
}

// MARK: - Default Attributes
extension MessageBasedInstrumentAttributes {
  /// A default set of attributes.
  ///
  /// The following defaults are used:
  /// - `readTerminator` is `"\n"`
  /// - `writeTerminator` is `"\n"`
  /// - `operationDelay` is 1 millisecond
  /// - `chunkSize` is 1024 bytes
  /// - `encoding` is UTF8
  static var `default`: Self {
    return .init()
  }
}

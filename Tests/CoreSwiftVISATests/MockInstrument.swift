//
//  MockInstrument.swift
//  
//
//  Created by Connor Barnes on 1/14/21.
//

@testable import CoreSwiftVISA
import Foundation

/// A mock instrument for testing.
///
/// The instrument will alwauys return the last sent message when `read` is called. If `read` is called before `write` is called, then `read` will return an empty string.
class MockInstrument {
	/// The last message written to the instrument.
	var lastMessage: String = ""
	var session: Session = MockSession()
	var attributes: MessageBasedInstrumentAttributes = .init()
}

class MockSession: Session {
	func close() throws {
		// Do nothing
	}
	
	func reconnect(timeout: TimeInterval) throws {
		// Do nothing
	}
}

extension MockInstrument: MessageBasedInstrument {
	
	func writeBytes(_: Data, appending terminator: Data?) throws -> Int {
		fatalError("Not implemented")
	}

	func write(_ string: String, appending terminator: String?, encoding: String.Encoding) throws -> Int {
		self.lastMessage = string
		return string.count
	}

	func readBytes(maxLength: Int?, until terminator: Data, strippingTerminator: Bool, chunkSize: Int) throws -> Data {
		fatalError("Not implemented")
	}

	func readBytes(length: Int, chunkSize: Int) throws -> Data {
		fatalError("Not implemented")
	}

	func read(until terminator: String, strippingTerminator: Bool, encoding: String.Encoding, chunkSize: Int) throws -> String {
		return lastMessage
	}
}

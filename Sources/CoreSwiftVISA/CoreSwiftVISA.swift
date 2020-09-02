//
//  File.swift
//
//
//  Created by Connor Barnes on 11/21/19.
//

import Foundation
import Socket

/// An internal class for managing communicating with an XPSQ8 instrument.
///
/// This class is used by the `XPSQ8Controller` class to abstract away the communication details.
public final class Communicator {
	/// The socket used for communicating with an XPSQ8 instrument.
	let socket: Socket
	
	/// Tries to create an instance from the specified address, and port of the instrument. A timeout value must also be specified.
	///
	/// - Parameters:
	///   - address: The IPV4 address of the instrument in dot notation.
	///   - port: The port of the instrument.
	///   - timeout: The maximum time to wait before timing out when communicating with the instrument.
	///
	/// - Throws: An error if a socket could not be created, connected, or configured properly.
	///
	init(address: String, port: Int, timeout: TimeInterval) throws {
		// Try to create a socket:
		// - XPSQ8 uses an IPV4 address, so the protocol family .inet is used.
		// - We would like to read to and write from the socket, so .stream is used.
		// - XPSQ8 communicates over .tcp.
		
		// We might need to sleep
		//usleep(1_000)
		do {
			socket = try Socket.create(family: .inet, type: .stream, proto: .tcp)
		} catch { throw Error.couldNotCreateSocket }
		
		// XPSQ8 sends data in packets of 1024 bytes.
		socket.readBufferSize = 1024
		
		do {
			try socket.connect(to: address, port: Int32(port))
		} catch { throw Error.couldNotConnect }
		
		do {
			// Timeout is set as an integer in milliseconds, but it is clearer to pass in a TimeInterval into the function because TimeInterval is used
			// thoughout Foundation to represent time in seconds.
			let timeoutInMilliseconds = UInt(timeout * 1_000.0)
			try socket.setReadTimeout(value: timeoutInMilliseconds)
			try socket.setWriteTimeout(value: timeoutInMilliseconds)
		} catch { throw Error.couldNotSetTimeout }
		
		do {
			// I'm not sure why we need to senable blocking, but the python drivers enabled it, so we will too.
			try socket.setBlocking(mode: true)
		} catch { throw Error.couldNotEnableBlocking }
	}
	
	deinit {
		// Close the connection to the socket because we will no longer need it.
		socket.close()
	}
}

// MARK: Reading

extension Communicator {
	/// Reads a message from the instrument.
	///
	/// - Throws: If a reading or decoding error occurred.
	///
	/// - Returns: The message string and integer code returned by the instrument.
	func read() throws -> String {
		// The message may not fit in a single buffer (only 1024 bytes). To overcome this, we continue to request data until we are at the end of the message.
		// The API ends all of its messages in the string ",EndOfAPI", so we continue to append values to `string` until it ends in ",EndOfAPI".
		var string = ""
		repeat {
			do {
				guard let substring = try socket.readString() else { throw Error.failedReadOperation }
				string += substring
			} catch { throw Error.failedReadOperation }
		} while !string.hasSuffix("\n")
		
		return string
	}
}

// MARK: Writing

extension Communicator {
	/// Sends a string to the instrument. This should be a function such as `"ElapsedTimeGet(double *)"`.
	/// - Parameter string: The string to sent the instrument.
	func write(string: String) throws {
		do {
			try socket.write(from: string)
		} catch {
			throw Error.failedWriteOperation
		}
	}
}

// MARK: Error
extension Communicator {
	/// An error associated with an XPSQ8Communicator.
	///
	/// - `couldNotCreateSocket`: The socket to communicate with the instrument could not be created.
	/// - `couldNotConnect`: The instrument could not be connected to. The instrument may not be connected, or could have a different address/port than the one specified.
	/// - `couldNotSetTimeout`: The timeout value could not be set.
	/// - `couldNotEnableBlocking`: The socket was unable to enable blocking.
	enum Error: Swift.Error {
		case couldNotCreateSocket
		case couldNotConnect
		case couldNotSetTimeout
		case couldNotEnableBlocking
		case failedWriteOperation
		case failedReadOperation
		case couldNotDecode
	}
}

// MARK: Error Descriptions
extension Communicator.Error {
	var localizedDescription: String {
		switch self {
		case .couldNotConnect:
			return "Could not connect."
		case .couldNotCreateSocket:
			return "Could not create socket."
		case .couldNotSetTimeout:
			return "Could not set timeout."
		case .couldNotEnableBlocking:
			return "Could not enable blocking."
		case .failedWriteOperation:
			return "Failed write operation."
		case .failedReadOperation:
			return "Failed read operation."
		case .couldNotDecode:
			return "Could not decode."
		}
	}
}

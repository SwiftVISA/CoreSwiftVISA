//
//  File.swift
//  
//
//  Created by Connor Barnes on 9/13/20.
//

import Foundation
import Socket

/// A class for communicating with an instrumnet over TCP-IP.
public final class TCPIPCommunicator {
	/// The socket used for communicating with the instrument.
	internal let socket: Socket
	/// Tries to create an instance from the specified address, and port of the instrument. A timeout value must also be specified.
	///
	/// - Parameters:
	///   - address: The IPV4 address of the instrument in dot notation.
	///   - port: The port of the instrument.
	///   - timeout: The maximum time to wait before timing out when communicating with the instrument.
	///
	/// - Throws: An error if a socket could not be created, connected, or configured properly.
	public init(address: String, port: Int, timeout: TimeInterval) throws {
		do {
			// TODO: Support IVP6 addresses (family: .net6)
			socket = try Socket.create(family: .inet, type: .stream, proto: .tcp)
		} catch { throw Error.couldNotCreateSocket }
		
		// TODO: XPSQ8 sent data in packets of 1024. What size packets does VISA use?
		socket.readBufferSize = 1024
		
		do {
			// TODO: We might need to specify a timeout value here. It says adding a timeout can put it into non-blocking mode, and I'm not sure What that will do.
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
			// We want to user to manage multithreding, so use blocking.
			try socket.setBlocking(mode: true)
		} catch { throw Error.couldNotEnableBlocking }
	}
	
	deinit {
		// Close the connection to the socket because we will no longer need it.
		socket.close()
	}
}

// MARK: Communicator
extension TCPIPCommunicator: Communicator {
	/// Reads a message from the instrument.
	///
	/// - Throws: If a reading or decoding error occurred.
	///
	/// - Returns: The message string returned by the instrument.
	public func read() throws -> String {
		// The message may not fit in a single buffer (only 1024 bytes). To overcome this, we continue to request data until we are at the end of the message.
		// NS-VISA specifies that messages should end in a new line character, so we continue to append values to `string` until it ends in "\n".
		var string = ""
		repeat {
			do {
				guard let substring = try socket.readString() else { throw Error.failedReadOperation }
				string += substring
			} catch { throw Error.failedReadOperation }
		} while !string.hasSuffix("\n")
		// Remove the trailing "\n"
		return String(string.dropLast())
	}
	/// Sends a string to the instrument.
	/// - Parameter string: The string to send to the instrument.
	public func write(string: String) throws {
		do {
			try socket.write(from: string)
		} catch {
			throw Error.failedWriteOperation
		}
	}
}

// MARK:- Error
extension TCPIPCommunicator {
	/// An error associated with a `TCPIPCommunicator`.
	///
	/// - `couldNotCreateSocket`: The socket to communicate with the instrument could not be created.
	/// - `couldNotConnect`: The instrument could not be connected to. The instrument may not be connected, or could have a different address/port than the one specified.
	/// - `couldNotSetTimeout`: The timeout value could not be set.
	/// - `couldNotEnableBlocking`: The socket was unable to enable blocking.
	/// - `failedWriteOperation`: The communicator could not write to the instrument.
	/// - `failedReadOperation`: The communicator could not read from the instrument.
	/// - `couldNotDecode`: The communicator could not decode the data sent from the instrument.
	public enum Error: Swift.Error {
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
extension TCPIPCommunicator.Error {
	public var localizedDescription: String {
		switch self {
		case .couldNotConnect:
			return "Could not connect"
		case .couldNotCreateSocket:
			return "Could not create socket"
		case .couldNotSetTimeout:
			return "Could not set timeout"
		case .couldNotEnableBlocking:
			return "Could not enable blocking"
		case .failedWriteOperation:
			return "Failed write operation"
		case .failedReadOperation:
			return "Failed read operation"
		case .couldNotDecode:
			return "Could not decode"
		}
	}
}

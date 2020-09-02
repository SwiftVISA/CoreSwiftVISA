import XCTest
@testable import CoreSwiftVISA

final class CoreSwiftVISATests: XCTestCase {
	
	static var communicator: Communicator!
	
	override class func setUp() {
		communicator = try? .init(address: "169.254.10.1", port: 5025, timeout: 5.0)
	}
	
	func testWrite() {
		let command = "OUTPUT OFF"
		
		do {
			try Self.communicator.write(string: command)
		} catch {
			XCTFail("Failed to write \"\(command)\" with error: \(error)")
		}
	}
	
	func testRead() {
		let command = "VOLTAGE?"
		
		do {
			try Self.communicator.write(string: command)
			_ = try Self.communicator.read()
		} catch {
			XCTFail("Failed to read \"\(command)\" with error: \(error)")
		}
	}
	
	func testCantRead() {
		let command = "OUTPUT OFF"
		
		do {
			try Self.communicator.write(string: command)
		} catch {
			XCTFail("Failed to write \"\(command)\" with error: \(error)")
		}
		do {
			_ = try Self.communicator.read()
			XCTFail("Read when no text returned \"\(command)\"")
		} catch {
			return
		}
	}
	
	static var allTests = [
		("testWrite", testWrite),
		("testRead", testRead),
		("testCantRead", testCantRead)
	]
}

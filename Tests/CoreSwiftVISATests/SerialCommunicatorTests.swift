import XCTest
@testable import CoreSwiftVISA

/// Tests for communicating with a Keysight E36103B Oscilliscope over Serial.
final class SerialCommunicatorTests: XCTestCase {
	/// The communicator to use for the tests.
	static var communicator: SerialCommunicator!
	
	func testList() {
		SerialCommunicator.listPorts()
	}
	
	static var allTests = [
		("testList", testList)
	]
}


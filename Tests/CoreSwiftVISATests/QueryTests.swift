//
//  File.swift
//  
//
//  Created by Connor Barnes on 1/14/21.
//

import XCTest
@testable import CoreSwiftVISA

/// A series of tests to test the querying functionality of the library.
final class QueryTests: XCTestCase {
	/// Tests default querying functionality.
	func testQuery() async {
    let instrument = MockInstrument()
    
    await {
      let result = try! await instrument.query("Test")
      XCTAssertEqual(result, "Test")
    }()
    
    await {
      let result = try! await instrument.query("3.14", as: Double.self)
      XCTAssertEqual(result, 3.14, accuracy: 1e-10)
    }()
    
    await {
      let result = try! await instrument.query("-20", as: Int.self)
      XCTAssertEqual(result, -20)
    }()
    
    await {
      let result = try! await instrument.query("OFF", as: Bool.self)
      XCTAssertEqual(result, false)
    }()
	}
  
	/// Tests custom querying functionality.
	func testCustomDecoder() async {
		let instrument = MockInstrument()
		
		struct LowercaseDecoder: MessageDecoder {
			typealias DecodingType = String
			
			func decode(_ message: String) throws -> String {
				return message.lowercased()
			}
		}
		
		let decoder = LowercaseDecoder()
    let result = try! await instrument.query("Some TEXT", as: String.self, using: decoder)
		XCTAssertEqual(result, "some text")
	}
	
	static var allTests = [
		("testQuery", testQuery),
		("testCustomDecoder", testCustomDecoder)
	]
}

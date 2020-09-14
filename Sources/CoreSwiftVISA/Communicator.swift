//
//  File.swift
//  
//
//  Created by Connor Barnes on 9/13/20.
//

import Foundation

/// A channel to communicate to and from an NI-VISA instrument.
public protocol Communicator {
	func read() throws -> String
	func write(string: String) throws
}

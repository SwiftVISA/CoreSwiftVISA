//
//  Session.swift
//  
//
//  Created by Connor Barnes on 12/28/20.
//

import Foundation

/// A session of an instrument.
public protocol Session {
	/// Closes the session. The instrument owning this session will no longer be able to read or write data.
	func close() async throws
  
	/// Tries to reestablish the session's connection.
	func reconnect(timeout: TimeInterval) async throws
}

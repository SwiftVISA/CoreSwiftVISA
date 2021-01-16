//
//  InstrumentManager.swift
//
//
//  Created by Connor Barnes on 11/17/20.
//

import typealias Foundation.TimeInterval

/// A class that is used to connect to VISA instruments.
///
/// An application uses a single shared instance of `InstrumentManager` that can be accessed by the static `shared` property.
public final class InstrumentManager {
	/// How long to wait when trying to connect to instruments for the first time.
	public var connectionTimeout: TimeInterval = 2.0
	// Prevent users from creating instances of this class
	internal init() { }
}

// MARK:- Singleton
extension InstrumentManager {
	/// The application's shared `InstrumentManager` instance.
	public static var shared = InstrumentManager()
}

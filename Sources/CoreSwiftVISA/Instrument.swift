//
//  Instrument.swift
//  
//
//  Created by Connor Barnes on 12/28/20.
//

/// An external instrument that can be connected to.
public protocol Instrument {
	/// The session that this insturment is connected over.
	var session: Session { get }
}

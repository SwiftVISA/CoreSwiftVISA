//
//  File.swift
//  
//
//  Created by Connor Barnes on 12/28/20.
//

/// An external instrument that can be connected to.
public protocol Instrument {
	var session: Session { get }
}

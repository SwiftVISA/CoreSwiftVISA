//
//  _Exported.swift
//  
//
//  Created by Connor Barnes on 11/17/20.
//

// We redefine this (origionally from Foundation) so that we can have the
// symbol be exported by SwiftVISA without including Foundation bloat.
/// A number of seconds.
///
/// A `TimeInterval value` is always specified in seconds; it yields sub-millisecond precision over a range of 10,000 years.
/// On its own, a time interval does not specify a unique point in time, or even a span between specific times. Combining a time interval with one or more known reference points yields a `Date` or `DateInterval` value.
public typealias TimeInterval = Double

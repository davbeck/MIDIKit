//
//  MIDIObject.swift
//  MIDIDebug
//
//  Created by David Beck on 8/3/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import CoreMIDI

extension MIDIObjectType: CustomStringConvertible {
	public var description: String {
		switch self {
		case .other:
			return ("other")
		case .device:
			return ("device")
		case .entity:
			return ("entity")
		case .source:
			return ("source")
		case .destination:
			return ("destination")
		case .externalDevice:
			return ("externalDevice")
		case .externalEntity:
			return ("externalEntity")
		case .externalSource:
			return ("externalSource")
		case .externalDestination:
			return ("externalDestination")
		@unknown default:
			return ("unknown")
		}
	}
}

public class MIDIObject: CustomStringConvertible, Identifiable, Hashable {
	internal let rawValue: MIDIObjectRef
	
	internal init(rawValue: MIDIObjectRef) {
		self.rawValue = rawValue
	}
	
	public convenience init(uniqueID: MIDIUniqueID) throws {
		var rawValue = MIDIObjectRef()
		let status = MIDIObjectFindByUniqueID(uniqueID, &rawValue, nil)
		
		guard status == 0 else {
			print("\(uniqueID) find failed", status)
			throw MIDIError(status: status)
		}
		
		self.init(rawValue: rawValue)
	}
	
	public func string(forPropertyID propertyID: CFString) throws -> String? {
		var result: Unmanaged<CFString>?
		let status = MIDIObjectGetStringProperty(rawValue, propertyID, &result)
		guard status == 0 else {
			print("\(propertyID) lookup failed", status)
			throw MIDIError(status: status)
		}
		guard let displayName = result else { return nil }
		
		return displayName.takeUnretainedValue() as String
	}
	
	public func integer(forPropertyID propertyID: CFString) throws -> Int32 {
		var result: Int32 = 0
		let status = MIDIObjectGetIntegerProperty(rawValue, propertyID, &result)
		guard status == 0 else {
			print("\(propertyID) lookup failed", status)
			throw MIDIError(status: status)
		}
		return result
	}
	
	public func name() throws -> String? {
		try string(forPropertyID: kMIDIPropertyName)
	}
	
	public func uniqueID() throws -> MIDIUniqueID {
		return try integer(forPropertyID: kMIDIPropertyUniqueID)
	}
	
	public var id: MIDIUniqueID? {
		return try? uniqueID()
	}
	
	public var description: String {
		"<\(type(of: self)) \((try? name()) ?? "")>"
	}
	
	public static func == (lhs: MIDIObject, rhs: MIDIObject) -> Bool {
		lhs.rawValue == rhs.rawValue
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(rawValue)
	}
}

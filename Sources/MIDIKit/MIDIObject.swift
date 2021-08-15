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
        try MIDIError.check(MIDIObjectGetStringProperty(rawValue, propertyID, &result))
        guard let displayName = result else { return nil }
        
        return displayName.takeUnretainedValue() as String
    }
    
    public func set(_ value: String, forPropertyID propertyID: CFString) throws {
        try MIDIError.check(MIDIObjectSetStringProperty(rawValue, propertyID, value as CFString))
    }
	
    public func integer(forPropertyID propertyID: CFString) throws -> Int32 {
        var result: Int32 = 0
        try MIDIError.check(MIDIObjectGetIntegerProperty(rawValue, propertyID, &result))
        return result
    }
    
    public func set(_ value: Int32, forPropertyID propertyID: CFString) throws {
        try MIDIError.check(MIDIObjectSetIntegerProperty(rawValue, propertyID, value))
    }
    
    public func name() throws -> String? {
        try string(forPropertyID: kMIDIPropertyName)
    }
    
    public var isOffline: Bool {
        (try? integer(forPropertyID: kMIDIPropertyOffline)) != 0
    }
	
    public var uniqueID: MIDIUniqueID {
        return (try? integer(forPropertyID: kMIDIPropertyUniqueID)) ?? MIDIUniqueID(rawValue)
    }
	
    public var id: MIDIUniqueID {
        return uniqueID
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

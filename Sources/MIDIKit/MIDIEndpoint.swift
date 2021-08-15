import Foundation
import CoreMIDI
import Combine

public class MIDIEndpoint: MIDIObject {
    public static var allSources: [MIDIEndpoint] {
        (0 ..< MIDIGetNumberOfSources()).map { index in
            MIDIEndpoint(rawValue: MIDIGetSource(index))
        }
    }
	
    public static var allDestinations: [MIDIEndpoint] {
        (0 ..< MIDIGetNumberOfDestinations()).map { index in
            MIDIEndpoint(rawValue: MIDIGetDestination(index))
        }
    }
	
    public func entity() throws -> MIDIEntity {
        var rawEntity = MIDIEntityRef()
        let status = MIDIEndpointGetEntity(rawValue, &rawEntity)
		
        guard status == 0 else {
            print("get entity", status)
            throw MIDIError(status: status)
        }
		
        return MIDIEntity(rawValue: rawEntity)
    }
	
    public func displayName() throws -> String? {
        try string(forPropertyID: kMIDIPropertyDisplayName)
    }
}

public final class MIDIVirtualDestination: MIDIEndpoint {
    public let packetRecieved: AnyPublisher<MIDIPacket, Never>
    
    internal init(
        rawValue: MIDIObjectRef,
        packetRecieved: PassthroughSubject<MIDIPacket, Never>
    ) {
        self.packetRecieved = packetRecieved.eraseToAnyPublisher()
        
        super.init(rawValue: rawValue)
    }
    
    deinit {
        MIDIEndpointDispose(rawValue)
    }
    
    public func setUniqueID(_ newValue: MIDIUniqueID) throws {
        try self.set(newValue, forPropertyID: kMIDIPropertyUniqueID)
    }
}

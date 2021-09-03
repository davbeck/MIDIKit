import Foundation
import CoreMIDI
import Combine

public class MIDIPort: MIDIObject {
    deinit {
        MIDIPortDispose(rawValue)
    }
}

public final class MIDIOutputPort: MIDIPort {
    public init(client: MIDIClient, name: String) throws {
        var rawValue: MIDIClientRef = 0
        let status = MIDIOutputPortCreate(client.rawValue, name as CFString, &rawValue)
		
        guard status == 0 else {
            print("setup output failed", status)
            throw MIDIError(status: status)
        }
		
        super.init(rawValue: rawValue)
    }
	
    public func send(_ packet: MIDIPacket, to endpoint: MIDIEndpoint) throws {
        //		let packetList = MIDIPacketList(numPackets: 1, packet: packet)
        var packetList = MIDIPacketList(midiEvents: [packet.bytes])
		
        let status = MIDISend(self.rawValue, endpoint.rawValue, &packetList)
		
        guard status == 0 else {
            print("send failed", status)
            throw MIDIError(status: status)
        }
    }
}

public final class MIDIInputPort: MIDIPort {
    private let _packetRecieved: PassthroughSubject<MIDIPacket, Never>
    public var packetRecieved: AnyPublisher<MIDIPacket, Never> {
        _packetRecieved.eraseToAnyPublisher()
    }
	
    public init(client: MIDIClient, name: String) throws {
        let packetRecieved = PassthroughSubject<MIDIPacket, Never>()
		
        var rawValue: MIDIClientRef = 0
        let status = MIDIInputPortCreateWithBlock(client.rawValue, name as CFString, &rawValue) { pktlist, readProcRefCon in
            for packet in pktlist.pointee {
                packetRecieved.send(packet)
            }
        }
		
        guard status == 0 else {
            print("setup input failed", status)
            throw MIDIError(status: status)
        }
		
        _packetRecieved = packetRecieved
		
        super.init(rawValue: rawValue)
    }
	
    public func connect(source: MIDIEndpoint) throws {
        try MIDIError.check(MIDIPortConnectSource(self.rawValue, source.rawValue, nil))
    }
    
    public func disconnect(source: MIDIEndpoint) throws {
        try MIDIError.check(MIDIPortDisconnectSource(self.rawValue, source.rawValue))
    }
}

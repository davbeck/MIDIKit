import Foundation
import CoreMIDI
import Combine

public final class MIDIClient: MIDIObject, ObservableObject {
    public let setupChanged: AnyPublisher<Void, Never>
    public let objectAdded: AnyPublisher<MIDIObjectAddRemoveNotification, Never>
    public let objectRemoved: AnyPublisher<MIDIObjectAddRemoveNotification, Never>
    public let propertyChanged: AnyPublisher<MIDIObjectPropertyChangeNotification, Never>
    
    public init(name: String) throws {
        var rawValue: MIDIClientRef = 0
        
        let setupChanged = PassthroughSubject<Void, Never>()
        let objectAdded = PassthroughSubject<MIDIObjectAddRemoveNotification, Never>()
        let objectRemoved = PassthroughSubject<MIDIObjectAddRemoveNotification, Never>()
        let propertyChanged = PassthroughSubject<MIDIObjectPropertyChangeNotification, Never>()
		
        let status = MIDIClientCreateWithBlock(name as CFString, &rawValue) { message in
            switch message.pointee.messageID {
            case .msgSetupChanged:
                print("msgSetupChanged")
                setupChanged.send()
            case .msgObjectAdded:
                message.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) { pointer in
                    print("msgObjectAdded", "parentType", pointer.pointee.parentType, "childType", pointer.pointee.childType)
                    objectAdded.send(pointer.pointee)
                }
            case .msgObjectRemoved:
                message.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) { pointer in
                    print("msgObjectRemoved", "parentType", pointer.pointee.parentType, "childType", pointer.pointee.childType)
                    objectRemoved.send(pointer.pointee)
                }
            case .msgPropertyChanged:
                message.withMemoryRebound(to: MIDIObjectPropertyChangeNotification.self, capacity: 1) { pointer in
                    print("msgPropertyChanged", "propertyName", pointer.pointee.propertyName, "objectType", pointer.pointee.objectType, "object", pointer.pointee.object)
                    propertyChanged.send(pointer.pointee)
                }
            case .msgThruConnectionsChanged:
                print("msgThruConnectionsChanged")
            case .msgSerialPortOwnerChanged:
                print("msgSerialPortOwnerChanged")
            case .msgIOError:
                print("msgIOError")
            @unknown default:
                print("default", message.pointee.messageID)
            }
        }
		
        guard status == 0 else {
            print("client setup failed", status)
            throw MIDIError(status: status)
        }
        
        self.setupChanged = setupChanged.eraseToAnyPublisher()
        self.objectAdded = objectAdded.eraseToAnyPublisher()
        self.objectRemoved = objectRemoved.eraseToAnyPublisher()
        self.propertyChanged = propertyChanged.eraseToAnyPublisher()
		
        super.init(rawValue: rawValue)
    }
	
    deinit {
        MIDIClientDispose(rawValue)
    }
}

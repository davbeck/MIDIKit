import Foundation
import CoreMIDI

public final class MIDIDevice: MIDIObject {
    public static var allDevices: [MIDIDevice] {
        (0 ..< MIDIGetNumberOfDevices()).map { index in
            MIDIDevice(rawValue: MIDIGetDevice(index))
        }
    }
	
    //	deinit {
    //		MIDIDeviceDispose(rawValue)
    //	}
	
    public var entities: [MIDIEntity] {
        (0 ..< MIDIDeviceGetNumberOfEntities(rawValue)).map { index in
            MIDIEntity(rawValue: MIDIDeviceGetEntity(rawValue, index))
        }
    }
    
    public var manufacturer: String? {
        try? string(forPropertyID: kMIDIPropertyManufacturer)
    }
    
    public var model: String? {
        try? self.string(forPropertyID: kMIDIPropertyModel)
    }
}

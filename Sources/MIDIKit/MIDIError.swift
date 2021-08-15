import Foundation
import CoreMIDI

public struct MIDIError: Swift.Error {
    public var status: OSStatus
	
    internal init(status: OSStatus) {
        self.status = status
    }
    
    static func check(_ status: OSStatus) throws {
        guard status == 0 else {
            throw MIDIError(status: status)
        }
    }
}

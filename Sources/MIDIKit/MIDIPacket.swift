//
//  MIDIPacket.swift
//  MIDIDebug
//
//  Created by David Beck on 8/3/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import CoreMIDI

public typealias MIDIPacket = CoreMIDI.MIDIPacket

extension MIDIPacketList: Sequence {
	public typealias Element = MIDIPacket
	
	public var count: UInt32 {
		return self.numPackets
	}
	
	public func makeIterator() -> AnyIterator<Element> {
		var p: MIDIPacket = packet
		var idx: UInt32 = 0
		
		return AnyIterator {
			guard idx < self.numPackets else {
				return nil
			}
			defer {
				p = MIDIPacketNext(&p).pointee
				idx += 1
			}
			return p
		}
	}
}

extension MIDIPacket: Hashable, Identifiable {
	public static func == (lhs: MIDIPacket, rhs: MIDIPacket) -> Bool {
		return lhs.timeStamp == rhs.timeStamp &&
			lhs.bytes == rhs.bytes
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(timeStamp)
		hasher.combine(bytes)
	}
	
	public var id: MIDIPacket {
		self
	}
}

public enum MIDIStatus: UInt8, CaseIterable {
	/// Note Off event.
	///
	/// This message is sent when a note is released (ended). (kkkkkkk) is the key (note) number. (vvvvvvv) is the velocity.
	case noteOff = 0b1000_0000
	
	/// Note On event.
	///
	/// This message is sent when a note is depressed (start). (kkkkkkk) is the key (note) number. (vvvvvvv) is the velocity.
	case noteOn = 0b1001_0000
	
	/// Polyphonic Key Pressure (Aftertouch).
	///
	/// This message is most often sent by pressing down on the key after it "bottoms out". (kkkkkkk) is the key (note) number. (vvvvvvv) is the pressure value.
	case polyphonicKeyPressure = 0b1010_0000
	
	/// Control Change.
	///
	/// This message is sent when a controller value changes. Controllers include devices such as pedals and levers. Controller numbers 120-127 are reserved as "Channel Mode Messages" (below). (ccccccc) is the controller number (0-119). (vvvvvvv) is the controller value (0-127).
	case controlChange = 0b1011_0000
	
	/// Program Change.
	///
	/// This message sent when the patch number changes. (ppppppp) is the new program number.
	case programChange = 0b1100_0000
	
	/// Channel Pressure (After-touch).
	///
	/// This message is most often sent by pressing down on the key after it "bottoms out". This message is different from polyphonic after-touch. Use this message to send the single greatest pressure value (of all the current depressed keys). (vvvvvvv) is the pressure value.
	case channelPressure = 0b1101_0000
	
	/// Pitch Bend Change.
	///
	/// This message is sent to indicate a change in the pitch bender (wheel or lever, typically). The pitch bender is measured by a fourteen bit value. Center (no pitch change) is 2000H. Sensitivity is a function of the receiver, but may be set using RPN 0. (lllllll) are the least significant 7 bits. (mmmmmmm) are the most significant 7 bits.
	case pitchBendChange = 0b1110_0000
	
	public var localizedDescription: String {
		switch self {
		case .noteOff:
			return "Note Off"
		case .noteOn:
			return "Note On"
		case .polyphonicKeyPressure:
			return "Polyphonic Key Pressure"
		case .controlChange:
			return "Control Change"
		case .programChange:
			return "Program Change"
		case .channelPressure:
			return "Channel Pressure"
		case .pitchBendChange:
			return "Pitch Bend Change"
		}
	}
	
	public var usesNote: Bool {
		switch self {
		case .noteOn, .noteOff, .polyphonicKeyPressure:
			return true
		default:
			return false
		}
	}
}

extension MIDIPacket {
	public var bytes: [UInt8] {
		var tmp = self.data
		let bytes = withUnsafeBytes(of: &tmp) { pointer in
			[UInt8](pointer)
		}
		
		return Array(bytes.prefix(Int(length)))
	}
	
	public var status: MIDIStatus? {
		MIDIStatus(rawValue: data.0 & 0xF0)
	}
	
	public var channel: UInt8 {
		data.0 & 0x0F
	}
    
    public var note: UInt8 {
        data.1
    }
    
    public var intensity: UInt8 {
        data.2
    }
    
    public var polyphonicKeyPressure: UInt8 {
        data.2
    }
    
    public var control: UInt8 {
        data.1
    }
    
    public var value: UInt8 {
        data.2
    }
    
    public var program: UInt8 {
        data.1
    }
    
    public var channelPressure: UInt8 {
        data.1
    }
	
	public init(timeStamp: MIDITimeStamp, bytes: [UInt8]) {
		self.init()
		
		let completeBytes = (0..<MemoryLayout<MIDITimeStamp>.size).map { _ in UInt8(0) } +
			(0..<MemoryLayout<UInt16>.size).map { _ in UInt8(0) } +
			bytes
		withUnsafeMutableBytes(of: &self) { pointer in
			pointer.copyBytes(from: completeBytes)
		}
		
		self.timeStamp = timeStamp
		self.length = UInt16(bytes.count)
	}
	
//	var isSysex: Bool {
//		return data.0 == AKMIDISystemCommand.sysex.rawValue
//	}
//
//	var status: AKMIDIStatus? {
//		return AKMIDIStatus(byte: data.0)
//	}
//
//	var channel: MIDIChannel {
//		return data.0.lowBit
//	}
//
//	var isSystemCommand: Bool {
//		return data.0 >= 0xf0
//	}
//
//	var systemCommand: AKMIDISystemCommand? {
//		return AKMIDISystemCommand(rawValue: data.0)
//	}
}

extension MIDIPacketList {
	public init(midiEvents: [[UInt8]]) {
		let timestamp = MIDITimeStamp(0) // do it now
		let totalBytesInAllEvents = midiEvents.reduce(0) { total, event in
			total + event.count
		}
		
		// Without this, we'd run out of space for the last few MidiEvents
		let listSize = MemoryLayout<MIDIPacketList>.size + totalBytesInAllEvents
		
		// CoreMIDI supports up to 65536 bytes, but in practical tests it seems
		// certain devices accept much less than that at a time. Unless you're
		// turning on / off ALL notes at once, 256 bytes should be plenty.
		assert(totalBytesInAllEvents < 256,
			   "The packet list was too long! Split your data into multiple lists.")
		
		// Allocate space for a certain number of bytes
		let byteBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: listSize)
		
		// Use that space for our MIDIPacketList
		self = byteBuffer.withMemoryRebound(to: MIDIPacketList.self, capacity: 1) { packetList -> MIDIPacketList in
			var packet = MIDIPacketListInit(packetList)
			midiEvents.forEach { event in
				packet = MIDIPacketListAdd(packetList, listSize, packet, timestamp, event.count, event)
			}
			
			return packetList.pointee
		}
		
		byteBuffer.deallocate() // release the manually managed memory
	}
}

//
//  MIDIEntity.swift
//  MIDIDebug
//
//  Created by David Beck on 8/3/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import CoreMIDI

public final class MIDIEntity: MIDIObject {
	public func device() throws -> MIDIDevice {
		var rawDevice = MIDIDeviceRef()
		let status = MIDIEntityGetDevice(rawValue, &rawDevice)
		
		guard status == 0 else {
			print("get device", status)
			throw MIDIError(status: status)
		}
		
		return MIDIDevice(rawValue: rawDevice)
	}
	
	public var sources: [MIDIEndpoint] {
		(0..<MIDIEntityGetNumberOfSources(rawValue)).map { index in
			MIDIEndpoint(rawValue: MIDIEntityGetSource(rawValue, index))
		}
	}
	
	public var destinations: [MIDIEndpoint] {
		(0..<MIDIEntityGetNumberOfDestinations(rawValue)).map { index in
			MIDIEndpoint(rawValue: MIDIEntityGetDestination(rawValue, index))
		}
	}
}

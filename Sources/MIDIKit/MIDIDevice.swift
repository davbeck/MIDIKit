//
//  MIDIDevice.swift
//  MIDIDebug
//
//  Created by David Beck on 8/3/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import CoreMIDI

public final class MIDIDevice: MIDIObject {
	public static var allDevices: [MIDIDevice] {
		(0..<MIDIGetNumberOfDevices()).map { index in
			MIDIDevice(rawValue: MIDIGetDevice(index))
		}
	}
	
	//	deinit {
	//		MIDIDeviceDispose(rawValue)
	//	}
	
	public var entities: [MIDIEntity] {
		(0..<MIDIDeviceGetNumberOfEntities(rawValue)).map { index in
			MIDIEntity(rawValue: MIDIDeviceGetEntity(rawValue, index))
		}
	}
}

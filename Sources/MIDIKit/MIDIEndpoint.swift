//
//  MIDIEndpoint.swift
//  MIDIDebug
//
//  Created by David Beck on 8/3/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import CoreMIDI

public final class MIDIEndpoint: MIDIObject {
	public static var allSources: [MIDIEndpoint] {
		(0..<MIDIGetNumberOfSources()).map { index in
			MIDIEndpoint(rawValue: MIDIGetSource(index))
		}
	}
	
	public static var allDestinations: [MIDIEndpoint] {
		(0..<MIDIGetNumberOfDestinations()).map { index in
			MIDIEndpoint(rawValue: MIDIGetDestination(index))
		}
	}
	
	//	deinit {
	//		MIDIEndpointDispose(rawValue)
	//	}
	
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

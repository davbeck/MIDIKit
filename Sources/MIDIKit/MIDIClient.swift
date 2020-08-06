//
//  MIDIClient.swift
//  MIDIDebug
//
//  Created by David Beck on 8/3/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import CoreMIDI

public final class MIDIClient: MIDIObject {
	public init(name: String) throws {
		var rawValue: MIDIClientRef = 0
		
		let status = MIDIClientCreateWithBlock(name as CFString, &rawValue) { message in
			switch message.pointee.messageID {
			case .msgSetupChanged:
				print("msgSetupChanged")
			case .msgObjectAdded:
				message.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) { pointer in
					print("msgObjectAdded", "parentType", pointer.pointee.parentType, "childType", pointer.pointee.childType)
				}
			case .msgObjectRemoved:
				message.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) { pointer in
					print("msgObjectRemoved", "parentType", pointer.pointee.parentType, "childType", pointer.pointee.childType)
				}
			case .msgPropertyChanged:
				print("msgPropertyChanged")
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
		
		super.init(rawValue: rawValue)
	}
	
	deinit {
		MIDIClientDispose(rawValue)
	}
}

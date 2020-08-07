//
//  MIDIError.swift
//  MIDIDebug
//
//  Created by David Beck on 8/3/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import Foundation
import CoreMIDI

public struct MIDIError: Swift.Error {
	public var status: OSStatus
	
	internal init(status: OSStatus) {
		self.status = status
	}
}

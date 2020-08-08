//
//  File.swift
//
//
//  Created by David Beck on 8/7/20.
//

import Foundation

private let octaveOffset: Int8 = 2

public struct MIDINote: RawRepresentable, Hashable {
	public var rawValue: UInt8
	
	public init(rawValue: UInt8) {
		self.rawValue = rawValue
	}
	
	init(_ pitchClass: PitchClass, octave: Int8) {
		self.rawValue = 12 * UInt8(octave + octaveOffset) + pitchClass.rawValue
	}
	
	public enum PitchClass: UInt8, CaseIterable, CustomStringConvertible {
		case c = 0
		case cSharp = 1
		case d = 2
		case dSharp = 3
		case e = 4
		case f = 5
		case fSharp = 6
		case g = 7
		case gSharp = 8
		case a = 9
		case aSharp = 10
		case b = 11
		
		public var description: String {
			switch self {
			case .c:
				return "C"
			case .cSharp:
				return "C#"
			case .d:
				return "D"
			case .dSharp:
				return "D#"
			case .e:
				return "E"
			case .f:
				return "F"
			case .fSharp:
				return "F#"
			case .g:
				return "G"
			case .gSharp:
				return "G#"
			case .a:
				return "A"
			case .aSharp:
				return "A#"
			case .b:
				return "B"
			}
		}
	}
	
	public var pitchClass: PitchClass {
		let index = rawValue % UInt8(PitchClass.allCases.count)
		return PitchClass.allCases[Int(index)]
	}
	
	public var octave: Int8 {
		Int8(floor(Double(rawValue) / 12)) - octaveOffset
	}
}

extension MIDINote: CustomStringConvertible {
	public var description: String {
		pitchClass.description + String(octave)
	}
}

extension MIDINote: CaseIterable {
	public static var allCases: [MIDINote] {
		(0...UInt8.max).map({ MIDINote(rawValue: $0) })
	}
}

extension MIDINote: Identifiable {
	public var id: UInt8 {
		return rawValue
	}
}

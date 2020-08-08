import XCTest
@testable import MIDIKit

final class MIDIKitTests: XCTestCase {
	func testCreateWithRawValue() {
		let note = MIDINote(rawValue: 24)
		
		XCTAssertEqual(note.pitchClass, .c)
		XCTAssertEqual(note.octave, 0)
	}
	
	func testCreateWithPitch() {
		let note = MIDINote(.c, octave: 0)
		
		XCTAssertEqual(note.rawValue, 24)
	}
	
	static var allTests = [
		("testCreateWithRawValue", testCreateWithRawValue),
		("testCreateWithPitch", testCreateWithPitch),
	]
}

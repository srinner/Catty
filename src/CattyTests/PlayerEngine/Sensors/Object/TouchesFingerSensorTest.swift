/**
 *  Copyright (C) 2010-2021 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest

@testable import Pocket_Code

final class TouchesFingerSensorTest: XCTestCase {

    let screenWidth = 500

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: TouchesFingerSensor!
    var touchManager: TouchManagerMock!

    override func setUp() {
        super.setUp()
        let scene = Scene(name: "testScene")
        spriteObject = SpriteObject()
        spriteObject.scene = scene
        spriteNode = CBSpriteNodeMock(spriteObject: spriteObject)
        touchManager = TouchManagerMock()
        sensor = TouchesFingerSensor(touchManagerGetter: { self.touchManager })
    }

    override func tearDown() {
        self.spriteObject = nil
        self.touchManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = TouchesFingerSensor { nil }
        XCTAssertEqual(TouchesFingerSensor.defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        let lastPoint = CGPoint(x: 10, y: 0)
        self.touchManager.lastTouch = lastPoint
        XCTAssertEqual(Double(lastPoint.x), self.sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testConvertToStandarized() {
        let lastPoint = CGPoint(x: 10, y: 0)
        self.touchManager.lastTouch = lastPoint

        // random
        XCTAssertEqual(Double(10 - screenWidth / 2), self.sensor.convertToStandardized(rawValue: 10, for: spriteObject))

        // center
        XCTAssertEqual(Double(250 - screenWidth / 2), self.sensor.convertToStandardized(rawValue: 250, for: spriteObject))

        // left
        XCTAssertEqual(Double(63 - screenWidth / 2), self.sensor.convertToStandardized(rawValue: 63, for: spriteObject))

        // right
        XCTAssertEqual(Double(437 - screenWidth / 2), self.sensor.convertToStandardized(rawValue: 437, for: spriteObject))

        self.touchManager.lastTouch = nil
        XCTAssertEqual(TouchesFingerSensor.defaultRawValue, self.sensor.convertToStandardized(rawValue: 437, for: spriteObject))
    }

    func testTag() {
        XCTAssertEqual("COLLIDES_WITH_FINGER", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.touchHandler, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.object(position: type(of: sensor).position, subsection: .motion), sections.first)
    }
}

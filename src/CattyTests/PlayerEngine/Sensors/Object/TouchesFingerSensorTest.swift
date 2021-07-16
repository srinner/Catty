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

    var spriteObject: SpriteObject!
    var spriteNode: CBSpriteNodeMock!
    var sensor: TouchesFingerSensor!
    var touchManager: TouchManagerMock!
    var lookA: Look!
    var lookB: Look!

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
        XCTAssertEqual(TouchesFingerSensor.defaultRawValue, sensor.rawValue(for: spriteObject), accuracy: Double.epsilon)
    }

    func testRawValue() {
        let objectWidth = Double((spriteObject.dimensions(of: spriteObject.spriteNode.currentLook).width / 2) * spriteObject.spriteNode.xScale)
        let objectHeight = Double((spriteObject.dimensions(of: spriteObject.spriteNode.currentLook).height / 2) * spriteObject.spriteNode.yScale)

        spriteNode.catrobatPosition = CBPosition(x: 1, y: 1)

        var x_value = 1 + Double(spriteNode.scene.size.width) / 2.0 + objectWidth
        var y_value = 1 + Double(spriteNode.scene.size.height) / 2.0 + objectHeight
        self.touchManager.lastTouch = CGPoint(x: x_value, y: y_value)

        XCTAssertEqual(1, self.sensor.rawValue(for: spriteObject))

        x_value += 1
        self.touchManager.lastTouch = CGPoint(x: x_value, y: y_value)
        XCTAssertEqual(0, self.sensor.rawValue(for: spriteObject))

        x_value -= 1
        y_value += 1
        self.touchManager.lastTouch = CGPoint(x: x_value, y: y_value)
        XCTAssertEqual(0, self.sensor.rawValue(for: spriteObject))

        x_value += 1
        self.touchManager.lastTouch = CGPoint(x: x_value, y: y_value)
        XCTAssertEqual(0, self.sensor.rawValue(for: spriteObject))

        spriteNode.catrobatPosition = CBPosition(x: 0, y: 0)

        x_value = Double(spriteNode.scene.size.width) / 2.0
        y_value = Double(spriteNode.scene.size.height) / 2.0
        self.touchManager.lastTouch = CGPoint(x: x_value, y: y_value)

        XCTAssertEqual(1, self.sensor.rawValue(for: spriteObject))
        spriteNode.isHidden = true
        XCTAssertEqual(0, self.sensor.rawValue(for: spriteObject))
    }

    func testConvertToStandarized() {
        XCTAssertEqual(1, self.sensor.convertToStandardized(rawValue: 1, for: spriteObject))
        XCTAssertEqual(0, self.sensor.convertToStandardized(rawValue: 0, for: spriteObject))
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

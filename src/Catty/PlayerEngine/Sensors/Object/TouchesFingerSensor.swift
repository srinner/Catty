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

@objc class TouchesFingerSensor: NSObject, TouchSensor {

    @objc static let tag = "COLLIDES_WITH_FINGER"
    static let name = kUIFESensorTouchesFinger
    static let defaultRawValue = 0.0
    static let defaultRawValuePoint = CGPoint(x: 0, y: 0)
    static let requiredResource = ResourceType.touchHandler
    static let position = 20
    static let screenWidth = 500

    let getTouchManager: () -> TouchManagerProtocol?

    init(touchManagerGetter: @escaping () -> TouchManagerProtocol?) {
        self.getTouchManager = touchManagerGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue() -> Double {
        guard let lastPosition = getTouchManager()?.lastPositionInScene() else { return type(of: self).defaultRawValue }
        return Double(lastPosition.x)
    }

    func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        guard let _ = getTouchManager()?.lastPositionInScene() else { return type(of: self).defaultRawValue }
        let width = spriteObject.dimensions(of: spriteObject.spriteNode.currentLook).width / 2
        let height = spriteObject.dimensions(of: spriteObject.spriteNode.currentLook).height / 2

        var position = getTouchPosition()
        var pointX = PositionXSensor.convertToStandardized(rawValue: Double(position.x), for: spriteObject)
        var pointY = PositionYSensor.convertToStandardized(rawValue: Double(position.y), for: spriteObject)
        let touchPoint = CGPoint(x: pointX, y: pointY)
        position = spriteObject.spriteNode.position
        pointX = PositionXSensor.convertToStandardized(rawValue: Double(position.x), for: spriteObject)
        pointY = PositionYSensor.convertToStandardized(rawValue: Double(position.y), for: spriteObject)
        let objectPoint = CGPoint(x: pointX, y: pointY)

        if (objectPoint.x + width) < touchPoint.x || (objectPoint.x - width) > touchPoint.x {
            return 0
        }

        if (objectPoint.y + height) < touchPoint.y || (objectPoint.y - height) > touchPoint.y {
            return 0
        }
        return 1
        //return rawValue - Double(TouchesFingerSensor.screenWidth) / 2.0
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.object(position: type(of: self).position, subsection: .motion)]
    }

    func getTouchPosition() -> CGPoint {
        guard let lastPosition = getTouchManager()?.lastPositionInScene() else { return type(of: self).defaultRawValuePoint }
        return lastPosition
    }
}

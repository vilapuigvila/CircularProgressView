//
//  Helpers.swift
//  Path
//
//  Created by albert vila on 26/06/2020.
//  Copyright © 2020 albert vila. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Helper's -
extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
}

extension Double {
    func toRadians() -> Double {
        return self * Double.pi / 180.0
    }
}

extension CGPoint {
    
    static func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let x = center.x + radius * cos(CGFloat(angle))
        let y = center.y + radius * sin(CGFloat(angle))
        
        return CGPoint(x: x, y: y)
    }
}

struct Rescale<Type : BinaryFloatingPoint> {
    typealias RescaleDomain = (lowerBound: Type, upperBound: Type)

    var fromDomain: RescaleDomain
    var toDomain: RescaleDomain

    init(from: RescaleDomain, to: RescaleDomain) {
        self.fromDomain = from
        self.toDomain = to
    }

    func interpolate(_ x: Type ) -> Type {
        return toDomain.lowerBound * (1 - x) + toDomain.upperBound * x;
    }

    func uninterpolate(_ x: Type) -> Type {
        let b = (fromDomain.upperBound - fromDomain.lowerBound) != 0 ?
                fromDomain.upperBound - fromDomain.lowerBound :
                1 / fromDomain.upperBound
        
        return (x - fromDomain.lowerBound) / b
    }

    func rescale(_ x: Type)  -> Type {
        return interpolate( uninterpolate(x) )
    }
    
    func rescaleAndClamp(_ x: Type)  -> Type {
        let value = rescale(x)
        let clampMin = max(toDomain.lowerBound, value)
        return min(toDomain.upperBound, clampMin)
    }
}

enum PanDirection: Int {
    case up, down, left, right
    public var isVertical: Bool { return [.up, .down].contains(self) }
    public var isHorizontal: Bool { return !isVertical }
}
enum Direction {
    case up
    case down
    case left
    case right
}

extension UIPanGestureRecognizer {

   var direction: PanDirection? {
        let velocity = self.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        switch (isVertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return nil
        }
    }

    var directionV2: Direction? {
        let velocityV2 = velocity(in: view)
        let isVertical = abs(velocityV2.y) > abs(velocityV2.x)

        switch (isVertical, velocityV2.x, velocityV2.y) {
            case (true, _, let y) where y < 0: return .up
            case (true, _, let y) where y > 0: return .down
            case (false, let x, _) where x > 0: return .right
            case (false, let x, _) where x < 0: return .left
            default: return nil
        }
    }
}

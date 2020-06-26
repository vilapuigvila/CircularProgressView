//
//  ViewController.swift
//  Path
//
//  Created by albert vila on 25/06/2020.
//  Copyright © 2020 albert vila. All rights reserved.
//

import UIKit
import HGCircularSlider

class ViewController: UIViewController {
    
    @IBOutlet weak var thumbView: UIView!
    
    lazy var p0 : CGPoint = CGPoint.pointOnCircle(center: view.center, radius: radius, angle: Double(startAngle))
    lazy var currentThumbPos: CGPoint = p0
    
    var thumbRect: CGRect!
    
    var bezierPath = UIBezierPath()
    var bezierOriginY: CGFloat!
    
    // alf
    let radius = CGFloat(150)
    let startAngle = -CGFloat(225).toRadians()
    let endAngle = CGFloat(45).toRadians()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawBezierPath()

        let dragPan = UIPanGestureRecognizer(target: self, action: #selector(dragEmotionOnBezier(recognizer:)))
        thumbView.addGestureRecognizer(dragPan)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        thumbView.center = p0
        updateEmojiRect()
    }
    
    func updateEmojiRect() {
        thumbRect = thumbView.frame
        thumbRect.size = CGSize(width: thumbRect.width * 3, height: thumbRect.height * 3)
    }

    func drawBezierPath() {
        bezierPath = UIBezierPath(arcCenter: view.center,
                                  radius: radius,
                                  startAngle: startAngle,
                                  endAngle: endAngle,
                                  clockwise: true)
    
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 3.0
        view.layer.addSublayer(shapeLayer)
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        
        bezierOriginY = CGPoint.pointOnCircle(center: view.center, radius: radius, angle: -Double(90).toRadians()).y
    }
    
    @objc func dragEmotionOnBezier(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: view)

        let touchSide = positionTouch(xCoordinate: point.x)
        
        let angle = getAngle(start: view.center, end: point)
        if angle == 45 && touchSide == .left || angle == -225 && touchSide == .right {
            return
        }
        
        let newPos = CGPoint.pointOnCircle(center: view.center, radius: radius, angle: angle.toRadians())
        thumbView.center = newPos
    }
    
    enum Side {
        case left, center, right
    }
    
    func positionTouch(xCoordinate: CGFloat) -> Side {
        if xCoordinate < view.center.x {
            return .left
        } else if xCoordinate > view.center.x {
            return .right
        } else {
            return .center
        }
    }
    
    func getAngle(start: CGPoint, end: CGPoint) -> Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let abs_dy = abs(dy)

        let constraint = Double.pi / 4
        var radians = Double(atan(abs_dy / dx))
        
        let quarter = TouchInCircle(dx: dx, dy: dy)
        if quarter.isInDownSide {
            radians = min(constraint, max(-constraint, radians))
        }
        
        let addition: Double = dx < 0 ? 180 : 0
        let degrees = (radians * 360 / (2.0 * Double.pi)) + addition
        
        let normalized: Double = {
            switch quarter {
            case .rightDown:
                return degrees
            case .leftDown:
                let diff = 180 - degrees
                return (180 + diff) * -1
            case .rightUp, .leftUp, .equals:
                return degrees * -1
            }
        }()
        return Double(normalized)
    }
    
    enum TouchInCircle {
        case rightUp
        case rightDown
        case leftUp
        case leftDown
        case equals
        
        init(dx: CGFloat, dy: CGFloat) {
            if dy > 0 && dx > 0 {
                self = .rightDown
            } else if dy > 0 && dx < 0 {
                self = .leftDown
            } else if dy < 0 && dx > 0 {
                self = .rightUp
            } else if dy < 0 && dx < 0 {
                self = .leftUp
            } else {
                self = .equals
            }
        }
        
        var isInDownSide: Bool {
            switch self {
            case .rightDown, .leftDown: return true
            default: return false
            }
        }
    }
}

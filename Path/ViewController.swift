//
//  ViewController.swift
//  Path
//
//  Created by albert vila on 25/06/2020.
//  Copyright © 2020 albert vila. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    typealias StartEndArc = (start: CGPoint, end: CGPoint)
    
    @IBOutlet weak var thumbView: UIView!
    var thumbLayer = UIView()
    
    lazy var arcPosition: StartEndArc = {
        return (CGPoint.pointOnCircle(center: view.center, radius: radius, angle: Double(startAngle)),
                CGPoint.pointOnCircle(center: view.center, radius: radius, angle: Double(endAngle)))
    }()
    
    var thumbRect: CGRect!
    
    var arcPath = UIBezierPath()
    var bezierOriginY: CGFloat!
    
    let leftRange: ClosedRange = -225.0...(-180.0)
    let rightRange: ClosedRange = -180.0...45.0
    
    let radius = CGFloat(150)
    let startAngle = -CGFloat(225).toRadians()
    let endAngle = CGFloat(45).toRadians()
    
    
    // MARK: - Helper's -
    let circular = CircularProgressView(frame: .zero)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        drawBezierPath()

//        let dragPan = UIPanGestureRecognizer(target: self, action: #selector(dragEmotionOnBezier(recognizer:)))
//        thumbView.addGestureRecognizer(dragPan)
//        let cir = CircularProgressView(frame: view.frame)
        view.addSubview(circular)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        thumbView.center = arcPosition.start
//        updateEmojiRect()
        circular.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: view.frame.width * 0.75)
        circular.center = view.center
        circular.setNeedsDisplay()
        circular.delegate = self
    }
    
    func updateEmojiRect() {
        thumbRect = thumbView.frame
        thumbRect.size = CGSize(width: thumbRect.width * 2, height: thumbRect.height * 2)
    }

    func drawBezierPath() {
        arcPath = UIBezierPath(arcCenter: view.center,
                                  radius: radius,
                                  startAngle: startAngle,
                                  endAngle: endAngle,
                                  clockwise: true)
    
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = arcPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 3.0
        view.layer.addSublayer(shapeLayer)
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        
        bezierOriginY = CGPoint.pointOnCircle(center: view.center, radius: radius, angle: -Double(90).toRadians()).y
    }
    
    @objc func dragEmotionOnBezier(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: view)

        guard let angle = getAngle(start: view.center, end: point) else {
            return
        }
        updateEmojiRect()
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
    
    func getAngle(start: CGPoint, end: CGPoint) -> Double? {
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
        
        if rightRange.contains(normalized) && quarter != .leftDown && thumbView!.center == arcPosition.start ||
        leftRange.contains(normalized) && quarter != .rightDown && thumbView!.center == arcPosition.end {
            return nil
        }
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

extension ViewController: CircularProgressViewDelegate {
    func circularProgressView(_ view: CircularProgressView, thumbValue: Double) {
        print("ddfdfd: \(thumbValue)")
    }
}

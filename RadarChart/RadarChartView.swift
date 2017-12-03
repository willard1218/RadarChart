//
//  RadarChartView.swift
//  radarTest
//
//  Created by willard on 2017/11/18.
//  Copyright © 2017年 willard. All rights reserved.
//

import UIKit

@IBDesignable

class RadarChartView: UIView {

    @IBInspectable var bgColor: UIColor = .lightGray
    @IBInspectable var areaColor: UIColor = .orange
    @IBInspectable var circleColor: UIColor = .green
    @IBInspectable var vertexCircleRadius: CGFloat = 3
    @IBInspectable var separatorLineColor: UIColor = .white
    
    let padding : CGFloat = 30
    var ratios : [Double]! { // 0~1
        didSet {
            radiuss = ratios.map{$0 * self.edgeLength}
        }
    }
    var radiuss : [Double]! {
        didSet {
            setRadiuss(radiuss)
        }
    }
    
    var edgeLength : Double {
        get { return Double(frame.height / 2 - padding) }
    }
    
    var vertexPoints : [CGPoint]!
    
    override func draw(_ rect: CGRect) {
        ratios = [0.3, 0.5, 0.2, 0.1, 1]
        
        // example for add titles
        let texts = ["態度", "效率", "責任", "合作", "應變"]
        let attr = [NSAttributedStringKey.foregroundColor : UIColor.brown,
                    NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)
        ]
        
        let attrs = texts.map{NSAttributedString(string: $0, attributes: attr)}
        
        
        let offsets = [CGPoint(x:-15, y:-20),
                       CGPoint(x:5, y:-10),
                       CGPoint(x:-5, y:5),
                       CGPoint(x:-5, y:5),
                       CGPoint(x:-35, y:-10)]
        
        drawVertexTitles(attrStrings: attrs, offsets: offsets)
    }
    
    
    func setRadiuss(_ radiss: [Double]) {
        let x = frame.width / 2
        let y = frame.height / 2
        
        let origin = CGPoint(x: x, y: y)
        vertexPoints = self.points(origin: origin, radiuss: edgeLength.repeats(count: radiss.count))
        
      
        
        drawArea(withPoints: vertexPoints, color: bgColor)
        drawCircles(withPoints: vertexPoints, color: circleColor)
        
        let areaPoints = self.points(origin: origin, radiuss: radiuss)
        
        drawArea(withPoints: areaPoints, color: areaColor)
        
        drawLines(withPoints: vertexPoints, origin: origin, color: separatorLineColor)
        
    }
    
    func drawLines(withPoints points: [CGPoint], origin: CGPoint, color: UIColor) {
        let path = UIBezierPath()
        
        for point in points {
            path.move(to: origin)
            path.addLine(to: point)
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func drawCircles(withPoints points: [CGPoint], color: UIColor) {
        let path = UIBezierPath()

        for point in points {
            path.move(to: point)
            path.addCircle(withCenter: point, radius: vertexCircleRadius)
        }
        
        color.setFill()
        path.lineWidth = 5
        path.fill()
    }
    
    func drawArea(withPoints points: [CGPoint], color: UIColor) {
        if points.count <= 1 {
            return
        }
        
        let path = UIBezierPath()
        
        path.move(to: points.first!)
        points.dropFirst().forEach(path.addLine)

        color.setFill()
        path.lineWidth = 5
        path.fill()
    }
    
    func points(origin: CGPoint, radiuss: [Double]) -> [CGPoint] {
        let drgree : Double = 360 / Double(radiuss.count)
        var points : [CGPoint] = []
        
        for (i, radius) in radiuss.enumerated() {
            let y : Double = radius
            let anchor = CGPoint(x: 0, y: -y)
            let point = anchor.roate(degree: drgree * Double(i), atOrigin: origin)
            
            points.append(point)
        }

        
        return points
    }
    
    func drawVertexTitles(attrStrings: [NSAttributedString], offsets: [CGPoint]) {
        assert(attrStrings.count == offsets.count, "The count of attrString and count of offset must be equal.")
        assert(attrStrings.count >= vertexPoints.count, "The count of attrString and count of radius must be equal.")
        
        for (i, (attr, offset)) in zip(attrStrings, offsets).enumerated() {
            attr.draw(at: vertexPoints[i].plus(offset))
        }
    }
}

extension UIBezierPath {
    func addCircle(withCenter center: CGPoint, radius: CGFloat) {
        addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360, clockwise: true)
    }
}


protocol RepeatsAble {}

extension RepeatsAble {
    func repeats(count: Int) -> [Self] {
        var n : [Self] = []
        for _ in 0..<count {
            n.append(self)
        }
        
        return n
    }
}

extension Int : RepeatsAble {}
extension Double : RepeatsAble {}
extension CGFloat : RepeatsAble {}

extension CGPoint {
    
    func roate(degree : Double, atOrigin origin: CGPoint) -> CGPoint {
        let sinV = sin(degrees: degree)
        let cosV = cos(degrees: degree)
      
        let x2 = (cosV * Double(x) - sinV * Double(y)) + Double(origin.x)
        let y2 = (sinV * Double(x) + cosV * Double(y)) + Double(origin.y)
        let point = CGPoint(x: x2, y: y2)
        return point
    }
    
    @discardableResult
    mutating func plus(_ point: CGPoint) -> CGPoint {
        self.x += point.x
        self.y += point.y
        return self
    }
}


func sin(degrees: Double) -> Double {
    return __sinpi(degrees/180.0)
}

func cos(degrees: Double) -> Double {
    return __cospi(degrees/180.0)
}

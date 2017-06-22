//
//  CourseworkProgressGraphic.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 01/05/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import UIKit

let π:CGFloat = CGFloat(M_PI)

@IBDesignable
class CourseworkProgressGraphic: UIView {
    
    // Setting up the colours that will be used.
    @IBInspectable var bgColor: UIColor = UIColor(red: 197.0/255.0, green: 202.0/255.0, blue: 233.0/255.0, alpha: 1.0)
    @IBInspectable var fillColor: UIColor = UIColor(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 1.0)
    @IBInspectable var dotColor: UIColor = UIColor(red: 139.0/255.0, green: 195.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    
    // Time and progress variables.
    var timeElapsedRatio: CGFloat = 0.67
    var progressElapsedRatio: CGFloat = 0.70
    
    override func draw(_ rect: CGRect) {
        
        let pointerBallRadius: CGFloat = 20
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let arcWidth: CGFloat = 24
        let radius: CGFloat = min(bounds.width / 2, bounds.height / 2) - 2 * pointerBallRadius
        let startAngle: CGFloat = 2 * π / 3
        let endAngle: CGFloat = π / 3
        
        // Time indicator.
        // Filling out the background of the still remaining days (dark blue).
        let background = UIBezierPath(arcCenter: center,
                                radius: radius - arcWidth/2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        background.lineWidth = arcWidth
        bgColor.setStroke()
        background.stroke()
        
        // Filling out the background based on the days passed (light blue) on top of the background.
        let fillAngle: CGFloat = (2 * π - startAngle + endAngle) * timeElapsedRatio
        let fillAngleEnd: CGFloat = startAngle + fillAngle
        
        let fill = UIBezierPath(arcCenter: center,
                                      radius: radius - arcWidth/2,
                                      startAngle: startAngle,
                                      endAngle: fillAngleEnd,
                                      clockwise: true)
        fill.lineWidth = arcWidth
        fillColor.setStroke()
        fill.stroke()
        
        
        // Progress indicatior.
        let dotAngle: CGFloat = (2 * π - startAngle + endAngle) * progressElapsedRatio + startAngle
        let dotOrbit: CGFloat = pointerBallRadius + radius
        
        let dotCenter = CGPoint(x: center.x + dotOrbit * cos(dotAngle), y: center.y + dotOrbit * sin(dotAngle))
        let dotBounds = CGRect(x: dotCenter.x - pointerBallRadius, y: dotCenter.y - pointerBallRadius, width: pointerBallRadius * 2, height: pointerBallRadius * 2)
        
        // Filling out the dot (green).
        let dot = UIBezierPath(ovalIn: dotBounds)
        dotColor.setFill()
        dot.fill()
        
        // Filling out the stroke (green).
        let strokeWidth = (2 * π * 4 / 360)
        let stroke = UIBezierPath(arcCenter: center,
                                radius: radius - arcWidth/2,
                                startAngle: dotAngle - strokeWidth / 2,
                                endAngle: dotAngle + strokeWidth / 2,
                                clockwise: true)
        stroke.lineWidth = arcWidth
        dotColor.setStroke()
        stroke.stroke()
    }
}

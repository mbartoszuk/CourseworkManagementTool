//
//  TaskProgressGraphic.swift
//  CourseworkManagementTool
//
//  Created by Maria Bartoszuk on 07/05/2017.
//  Copyright © 2017 Maria Bartoszuk. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TaskProgressGraphic: UIView {
    
    // Setting up the colours that will be used.
    @IBInspectable var fillColor: UIColor = UIColor(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 1.0)
    @IBInspectable var dotColor: UIColor = UIColor(red: 139.0/255.0, green: 195.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    
    @IBInspectable var ratio: Float = 0.7 {
        didSet {
            // Redraw every time the ratio changes.
            setNeedsDisplay()
            ratioChanged?(ratio)
        }
    }
    
    // Invoked every time ratio changes to update corresponding label.
    var ratioChanged: ((Float) -> Void)? = nil
    @IBInspectable var barHeight: CGFloat = 20
    @IBInspectable var barRadius: CGFloat = 3
    @IBInspectable var stripeWidth: CGFloat = 2
    
    override func draw(_ rect: CGRect) {
        
        // The progress bar.
        let bar = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: barHeight), cornerRadius: barRadius)
        fillColor.setStroke()
        fillColor.setFill()
        bar.stroke()
        bar.fill()
        
        // The dot position and drawing.
        let ballX: CGFloat = CGFloat(ratio) * rect.width
        let radius: CGFloat = max(0, rect.height - barHeight) / 2
        let stripe = UIBezierPath(rect: CGRect(x: ballX - stripeWidth/2, y: 0, width: stripeWidth, height: barHeight + radius))
        dotColor.setStroke()
        dotColor.setFill()
        stripe.stroke()
        stripe.fill()
        let ball = UIBezierPath(ovalIn: CGRect(x: ballX - radius, y: barHeight, width: 2 * radius, height: 2 * radius))
        ball.stroke()
        ball.fill()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If there are many touches, just get the first.
        let touch = touches.first!
        // Find where was the touch (relative to this view).
        let point = touch.location(in: self)
        // Bar is stretched across the whole view so ratio is position / total width.
        ratio = Float(point.x) / Float(bounds.size.width)
    }
}

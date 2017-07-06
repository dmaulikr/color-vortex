//
//  Ball.swift
//  ColorVortex
//
//  Created by Paxon Yu on 7/5/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit


class Ball : SKShapeNode {
    
    var distFromCenter: CGFloat!
    var angularDist: CGFloat?
    var orbitalRadius: CGFloat?
    
    init(_ color: UIColor) {
        
        super.init()
        let diameter = 2 * 2
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: 0 , y:0), size: CGSize(width: diameter, height: diameter)), transform: nil)
        self.fillColor = color
        physicsBody = SKPhysicsBody(circleOfRadius: 2)
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 1
        physicsBody?.contactTestBitMask = 2
        
        
        if color == UIColor.red {
        self.name = "redBall"
        }else if color == UIColor.blue {
            self.name = "blueBall"
        }else if color == UIColor.yellow {
            self.name = "yellowBall"
        }else {
            self.name = "greenBall"
        }
        
    }
    
    
    
    
    
    
    
    
    func update() {
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
    
}
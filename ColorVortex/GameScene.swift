//
//  GameScene.swift
//  ColorVortex
//
//  Created by Paxon Yu on 7/3/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation


public func calcDistance(_ start: CGPoint, _ end: CGPoint) -> CGFloat {
    let xDist = start.x - end.x
    let yDist = start.y - end.y
    let dist = sqrt((xDist*xDist) + (yDist*yDist))
    return dist
    
}

let dt: CGFloat = 1.0/60.0 //Delta Time
let fixedDelta: CFTimeInterval = 1.0/60.0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var node1: SKShapeNode!
    var vortexOn: Bool = false
    var lastPosition: CGPoint!
    var orbitalRadius: CGFloat!
    
    let period: CGFloat = 3 //Number of seconds it takes to complete 1 orbit.
    var balls = [Ball]()
    var addBallTimer: CFTimeInterval = 0
    var origin: CGPoint!
    
    var red: SKSpriteNode! = nil
    var blue: SKSpriteNode!
    var yellow: SKSpriteNode!
    var green: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = String(score)
        red = childNode(withName: "red") as! SKSpriteNode
        blue = childNode(withName: "blue") as! SKSpriteNode
        green = childNode(withName: "green") as! SKSpriteNode
        yellow = childNode(withName: "yellow") as! SKSpriteNode
        origin = CGPoint(x: self.size.width/2, y: self.size.height - self.size.width/2)
        physicsWorld.speed = 0.5
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        node1 = SKShapeNode(circleOfRadius: 10)
        node1.physicsBody?.categoryBitMask = 0
        node1.position = origin
        node1.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        let ball = Ball(UIColor.red)
        ball.position = CGPoint(x: origin.x, y: origin.y - 50)
        self.addChild(ball)
        let ball2 = Ball(UIColor.blue)
        ball2.position = CGPoint(x:origin.x - 100, y:origin.y)
        balls.append(ball)
        balls.append(ball2)
        self.addChild(ball2)
        self.addChild(node1)
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        scoreLabel.text = String(score)
        node1.position = origin
        addBallTimer += fixedDelta
        if addBallTimer > 4 {
            addBall()
            addBallTimer = 0
        }
        if vortexOn {
            for ball in balls {
                if calcDistance(node1.position, ball.position) < 120 {
                    ball.orbitalRadius = calcDistance(node1.position, ball.position)
                    let orbitPosition = node1.position //Point to orbit.
                    //let orbitRadius = calcDistance(orbitPosition, lastPosition) //Radius of orbit.
                    ball.angularDist = atan2(ball.position.y - origin.y, ball.position.x - origin.x) + CGFloat(M_1_PI / 5)
                    
                    print(ball.physicsBody?.contactTestBitMask)
                    print(red.physicsBody?.contactTestBitMask)
                    let normal = CGVector(dx:orbitPosition.x + CGFloat(cos(ball.angularDist!))*ball.orbitalRadius!,dy:orbitPosition.y + CGFloat(sin(ball.angularDist!))*ball.orbitalRadius!);
                    ball.angularDist! += (CGFloat(M_PI)*2.0) / (period*dt);
                    if (fabs(ball.angularDist!) > CGFloat(M_PI)*2)
                    {
                        ball.angularDist = 0
                    }
                    
                    ball.physicsBody!.velocity = CGVector(dx:(normal.dx-ball.position.x)/dt,dy:(normal.dy-ball.position.y)/dt);
                }
                
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        vortexOn = true
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        vortexOn = false
    }
    
    
    func addBall() {
        
        let ball: Ball
        let decider = arc4random_uniform(4)
        switch decider {
        case 0:
            ball = Ball(UIColor.red)
            break
        case 1:
            ball = Ball(UIColor.blue)
            break
        case 2:
            ball = Ball(UIColor.yellow)
            break
        case 3:
            ball = Ball(UIColor.green)
            break
        default:
            ball = Ball(UIColor.blue)
        }
        
        let xPos = arc4random_uniform(185) + UInt32(origin.x - 100)
        let yPos = arc4random_uniform(185) + UInt32(origin.y - 100)
        ball.position = CGPoint(x:CGFloat(xPos),y:CGFloat(yPos))
        balls.append(ball)
        addChild(ball)
        
    }
    
  func didBegin(_ contact: SKPhysicsContact) {
    
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        let nodeA = contactA.node!
        let nodeB = contactB.node!
    
    print("contactttt")
        
    if nodeA.name == "redBall" && nodeB.name == "red" {
        score += 1
        removeBall(nodeA.position)
    }
    if nodeA.name == "red" && nodeB.name == "redBall" {
        
        score += 1
        removeBall(nodeB.position)
    }
    if nodeA.name == "greenBall" && nodeB.name == "green" {
        
        score += 1
        removeBall(nodeA.position)
    }
    if nodeA.name == "green" && nodeB.name == "greenBall" {
        score += 1
    }
    if nodeA.name == "blueBall" && nodeB.name == "blue" {
        score += 1
    }
    if nodeA.name == "blue" && nodeB.name == "blueBall" {
        score += 1
    }
    if nodeA.name == "yellow" && nodeB.name == "yellowBall" {
        score += 1
    }
    if nodeA.name == "yellowBall" && nodeB.name == "yellow" {
        score += 1
    }
    
    }
    
    
    func removeBall(_ ballPosition: CGPoint) {
        var index = 0
        for ball in balls {
            if ball.position == ballPosition {
                ball.removeFromParent()
                balls.remove(at: index)
                return
            }
            index += 1
    }
    
}












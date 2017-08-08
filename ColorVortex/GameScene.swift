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
import GoogleMobileAds

//general function used to calculate the distance between two CGPoints and returns this distance in the form of a CGFloat
public func calcDistance(_ start: CGPoint, _ end: CGPoint) -> CGFloat {
    let xDist = start.x - end.x
    let yDist = start.y - end.y
    let dist = sqrt((xDist*xDist) + (yDist*yDist))
    return dist
    
}

func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

//the time deltas used for calculations and incrementing timers respectively also the period of the rotations which totally doesn't work (I think)
let period: CGFloat = 3 //Number of seconds it takes to complete 1 orbit.
let dt: CGFloat = 1.0/60.0 //Delta Time
let fixedDelta: CFTimeInterval = 1.0/60.0

//game state enums to affect code based on the player actions
enum GameState {
    case playing, gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate, GADBannerViewDelegate {
    
    var firstTimeEver: Bool = true
    var bannerView: GADBannerView!
    
    //defining all of the nodes in the scene
    var state: GameState = .playing
    var vortex: SKEmitterNode!
    var minimumRadius = 40
    var ballSpawnRate = 2.5
    
    //boolean to determine whether the vortex is on
    var vortexOn: Bool = false
    
    //determines whether the tutorial needs to be set
    var gameStart: Bool = false
    
    //highscore label and information also userdefault information
    var highscoreNum: SKLabelNode!
    var highscore: Int = 0
    let scoreDefault = UserDefaults.standard
    
    //array used to store the balls for easier iteration and tracking
    var balls = [Ball]()
    
    //timers used to determine how often to add a ball and what the global limit for the balls should be
    var addBallTimer: CFTimeInterval = 0
    var globalTimer: CFTimeInterval = 0
    
    //origin point for the vertex, defined relative to the size of the screen
    var origin: CGPoint!
    
    //lose areas, score labels, tutorial text, buttons and global limit on balls
    var red: SKSpriteNode! = nil
    var blue: SKSpriteNode!
    var yellow: SKSpriteNode!
    var green: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var tutorialText: SKLabelNode!
    var tutorialArrow: SKSpriteNode!
    var playArea: SKSpriteNode!
    let playAreaPulse = SKAction(named: "SubtlePulse")
    var score = 0
    var restartButton: MSButtonNode!
    var MainMenuButton: MSButtonNode!
    var sparkly: SKEmitterNode!
    var limit = 2
    var soundEffect = SKAction.playSoundFileNamed("Hyperspace.wav", waitForCompletion: false)
    
    var colorBlind: Bool!
    
    //determines the velocity at which the balls spawn at
    let initialScalar = 40
    
    //initializes all of the nodes and what not
    override func didMove(to view: SKView) {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.frame = CGRect(x: 0, y: view.bounds.height - bannerView.frame.size.height, width: 320, height: 50)
        self.view?.addSubview(bannerView)
       // bannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111" // FAKE ID
        bannerView.adUnitID = "ca-app-pub-8233645734871172/8656498030" //REAL ID
        bannerView.rootViewController = self.view?.window?.rootViewController
//        let request = GADRequest()
//        request.testDevices =  [ kGADSimulatorID,
//            "2077ef9a63d2b398840261c8221a0c9b" ]
//        
        let requestActual = GADRequest()
        bannerView.load(requestActual)
        bannerView.delegate = self

        
        MainMenuButton = childNode(withName: "//MainMenuButton") as! MSButtonNode
        MainMenuButton.selectedHandler = {
            if let scene = MainMenu(fileNamed: "MainMenu") {
                
                self.bannerView.removeFromSuperview()
                // Present the scene
                if let view = self.view {
                    view.presentScene(scene)
                    
                    view.ignoresSiblingOrder = true
                    
                 
                    
                    
                }
            }
        }
        tutorialArrow = childNode(withName: "tutorialArrow") as! SKSpriteNode
        sparkly = SKEmitterNode(fileNamed: "HitEffect.sks")
        playArea = childNode(withName: "playArea") as! SKSpriteNode
        vortex = childNode(withName: "vortex") as! SKEmitterNode
        tutorialText = childNode(withName: "tutorialText") as! SKLabelNode
        physicsWorld.contactDelegate = self
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = String(score)
        red = childNode(withName: "red") as! SKSpriteNode
        blue = childNode(withName: "blue") as! SKSpriteNode
        green = childNode(withName: "green") as! SKSpriteNode
        yellow = childNode(withName: "yellow") as! SKSpriteNode
        origin = CGPoint(x: self.size.width/2, y: self.size.height - self.size.width/2)
        calcHighscore()
        sparkly.zPosition = 1
        
        //sets the speed of the world and turns the gravity off
        physicsWorld.speed = 0.8
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        //restart button removes all balls, sets the state to playing, hides itself and immediately adds a ball
        restartButton = childNode(withName: "restartButton") as! MSButtonNode
        restartButton.selectedHandler = {
            self.balls.removeAll()
            self.state = .playing
            self.restartButton.isHidden = true
            self.addBall()
        }
        highscoreNum = childNode(withName: "highscoreNum") as! SKLabelNode
          highscoreNum.text = String(highscore)
        let ball: Ball
        //first tutorial ball, nothing special about it
        if colorBlind == true {
        ball = Ball(UIColor(red:1.00, green:0.53, blue:0.71, alpha:1.0))
        }else {
        ball = Ball(UIColor.red)
        }
        ball.position = CGPoint(x: origin.x, y: origin.y - 50)
        self.addChild(ball)
        balls.append(ball)
        
        //initially sets the vortex to hidden and disables multitouch
        vortex.isHidden = true
        self.view?.isMultipleTouchEnabled = false
      
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        //will only run this huge block if the game is playing
        if state == .playing {
            
            restartButton.isHidden = true
            scoreLabel.text = String(score)
            changeDifficulty()
            
            //turns off tutorial text
            if score == 1 {
                gameStart = true
                tutorialText.isHidden = true
                firstTimeEver = false
                
                tutorialArrow.removeFromParent()
            }
            
            //increments the timer once the player scores the first point
            if gameStart {
                globalTimer += fixedDelta
                addBallTimer += fixedDelta
                
                //every three "seconds" adds a ball assuming that the ball limit hasn't been exceeded then updates the limit and resets the timer
                if addBallTimer > ballSpawnRate{
                    if balls.count < limit {
                    addBall()
                    }
                    addBallTimer = 0
                }
                updateLimit()
            }
            
            //if the vortex is on then does all this jank ass calcultions to determine the velocity of all the balls
            if vortexOn {
                for ball in balls {
                    if calcDistance(origin, ball.position) < 120 {
                        ball.orbitalRadius = calcDistance(origin, ball.position)
                        ball.angularDist = atan2(ball.position.y - origin.y, ball.position.x - origin.x) + CGFloat(M_1_PI / 5)
                        
                        let normal = CGVector(dx: origin.x + CGFloat(cos(ball.angularDist!))*ball.orbitalRadius!,dy:origin.y + CGFloat(sin(ball.angularDist!))*ball.orbitalRadius!);
                        ball.angularDist! += (CGFloat(M_PI)*2.0) / (period*dt);
                        if (fabs(ball.angularDist!) > CGFloat(M_PI)*2)
                        {
                            ball.angularDist = 0
                        }
                        
                        ball.physicsBody!.velocity = CGVector(dx:(normal.dx-ball.position.x)/dt,dy:(normal.dy-ball.position.y)/dt);
                    }
                    
                }
            }
            
        }else {
            restartButton.isHidden = false
            
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .playing {
            vortexOn = true
            vortex.isHidden = false
            vortex.alpha = 0
            vortex.run(SKAction.fadeIn(withDuration: 0.5))
            playArea.removeAllActions()
            
            playArea.run(SKAction.repeatForever(playAreaPulse!))
            
          
        }
        
      
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .playing {
            vortex.removeAllActions()
            vortexOn = false
            vortex.run(SKAction.fadeOut(withDuration: 0.3))
            gameStart = true
            playArea.scale(to: CGSize(width: 320, height: 200))
            playArea.removeAllActions()
            
        }
    }
    
    
    func addBall() {
        var ball:Ball?
        var validSpawn: Bool = false
        var failIndex = 0
        
        while !validSpawn && balls.count <= limit {
            if failIndex > 100 {
                return
            }
            let decider = arc4random_uniform(4)
            let dirDecider = arc4random_uniform(4)
            switch decider {
            case 0:
                if colorBlind == true {
                    ball = Ball(UIColor(red:1.00, green:0.53, blue:0.71, alpha:1.0))
                }else {
                ball = Ball(UIColor.red)
                }
                break
            case 1:
                ball = Ball(UIColor.blue)
                break
            case 2:
                if colorBlind == true {
                    ball = Ball(UIColor.gray)
                }else {
                ball = Ball(UIColor.yellow)
                }
                break
            case 3:
                ball = Ball(UIColor.green)
                break
            default:
                ball = Ball(UIColor.blue)
            }
            
            switch dirDecider {
            case 0:
                ball?.physicsBody?.velocity = CGVector(dx:0,dy: initialScalar)
                break
            case 1:
                ball?.physicsBody?.velocity = CGVector(dx:0,dy: -initialScalar)
                break
            case 2:
                ball?.physicsBody?.velocity = CGVector(dx: initialScalar, dy:0)
                break
            case 3:
                ball?.physicsBody?.velocity = CGVector(dx:-initialScalar,dy:0)
                break
            default:
                continue
            }
            
            let xPos = arc4random_uniform(160) + UInt32(origin.x - 80)
            let yPos = arc4random_uniform(160) + UInt32(origin.y - 80)
            let testPoint = CGPoint(x: CGFloat(xPos),y: CGFloat(yPos))
            
            if balls.count > 0 {
                for ballin in balls {
                    if fabs(calcDistance(testPoint, origin) - calcDistance(ballin.position, origin)) > CGFloat(minimumRadius) && calcDistance(testPoint, origin) > CGFloat(10          ){
                        validSpawn = true
                        ball?.position = testPoint
                    }else {
                        failIndex += 1
                        validSpawn = false
                        break
                    }
                }
            }else {
                validSpawn = true
                ball?.position = testPoint
            }
        }
        
        if balls.count <= limit {
        balls.append(ball!)
        addChild(ball!)
        }
        return
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        tutorialArrow?.removeFromParent()
    
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        let position = contact.contactPoint
        let particleEffect = sparkly.copy() as! SKEmitterNode
        particleEffect.particleColorSequence = nil
        particleEffect.particleColorBlendFactor = 1.0
        playArea.removeAllActions()
        run(soundEffect)
        
        print(nodeA)
        print(nodeB)
        
        if nodeA.name == "redBall" && nodeB.name == "red" {
            score += 1
            
            if colorBlind == true {
                particleEffect.particleColor = UIColor(red:1.00, green:0.53, blue:0.71, alpha:1.0)
            }else {
            particleEffect.particleColor = .red
            }
            particleEffect.position = position
            addChild(particleEffect)
            particleEffect.run(SKAction.fadeOut(withDuration: 1))
            removeBall(nodeA.position)
        }else if nodeA.name == "red" && nodeB.name == "redBall" {
            if colorBlind == true {
                particleEffect.particleColor = UIColor(red:1.00, green:0.53, blue:0.71, alpha:1.0)
            }else {
                particleEffect.particleColor = .red
            }
            particleEffect.position = position
            addChild(particleEffect)
            particleEffect.run(SKAction.fadeOut(withDuration: 1))
            score += 1
            removeBall(nodeB.position)
        }else if nodeA.name == "greenBall" && nodeB.name == "green" {
            particleEffect.particleColor = .green
            particleEffect.position = position
            particleEffect.emissionAngle = CGFloat.pi
            addChild(particleEffect)
            particleEffect.run(SKAction.fadeOut(withDuration: 1))
            score += 1
            removeBall(nodeA.position)
        }else if nodeA.name == "green" && nodeB.name == "greenBall" {
            particleEffect.particleColor = .green
            particleEffect.position = position
            particleEffect.emissionAngle = CGFloat.pi
            addChild(particleEffect)
            particleEffect.run(SKAction.fadeOut(withDuration: 1))
            score += 1
            removeBall(nodeB.position)
        }else if nodeA.name == "blueBall" && nodeB.name == "blue" {
            particleEffect.particleColor = .blue
            particleEffect.position = position
            particleEffect.emissionAngle = 3 * CGFloat.pi / 2
            addChild(particleEffect)
            particleEffect.run(SKAction.fadeOut(withDuration: 1))
            score += 1
            removeBall(nodeA.position)
        }else if nodeA.name == "blue" && nodeB.name == "blueBall" {
            particleEffect.particleColor = .blue
            particleEffect.position = position
             particleEffect.emissionAngle = 3 * CGFloat.pi / 2
            addChild(particleEffect)
            particleEffect.run(SKAction.fadeOut(withDuration: 1))
            score += 1
            removeBall(nodeB.position)
        }else if nodeA.name == "yellow" && nodeB.name == "yellowBall" {
            if colorBlind == true {
                particleEffect.particleColor = .gray
            }else {
            particleEffect.particleColor = .yellow
            }
            particleEffect.position = position
            particleEffect.emissionAngle = 0
            addChild(particleEffect)
            particleEffect.run(SKAction.fadeOut(withDuration: 1))
            score += 1
            removeBall(nodeB.position)
        }else if nodeA.name == "yellowBall" && nodeB.name == "yellow" {
            if colorBlind == true {
                particleEffect.particleColor = .gray
            }else {
                particleEffect.particleColor = .yellow
            }
            particleEffect.position = position
            particleEffect.emissionAngle = 0
            addChild(particleEffect)
            particleEffect.run(SKAction.fadeOut(withDuration: 1))
            score += 1
            removeBall(nodeA.position)
        }else if nodeA.name == nil || nodeB.name == nil {
            return
        }else {
            
            calcHighscore()
            highscoreNum.text = String(highscore)
            
            for ball in balls {
                ball.removeFromParent()
            }
            balls.removeAll()
            score = 0
            state = .gameOver
            gameStart = false
            if vortexOn {
            vortex.run(SKAction.fadeOut(withDuration: 0.3))
            vortexOn = false
            }
        }
        
    }
    
    func updateLimit() {
        
        if globalTimer > 10 && globalTimer < 30{
            limit = 3
        }else if globalTimer > 30 && globalTimer < 50 {
            limit = 4
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
    func calcHighscore() {
        
        if score > highscore {
            highscore = score
            scoreDefault.set(highscore, forKey: "highscoreNum")
        }
        if scoreDefault.integer(forKey: "highscoreNum") != 0 {
            highscore = scoreDefault.integer(forKey: "highscoreNum")
        }else {
            highscore = 0
        }
    }
    
    
    func changeDifficulty() {
        if score % 10 == 0 {
            let randomRadius = Double(arc4random_uniform(20) + 30)
            minimumRadius = Int(randomRadius)
            let randomRate = randomBetweenNumbers(firstNum: 2, secondNum: 3)
            ballSpawnRate = Double(randomRate)
        }
    }
    
    class func level(colorBlind: Bool) -> GameScene? {
        
        if colorBlind == false {
            guard let scene = GameScene(fileNamed: "GameScene") else {
                return nil
            }
            scene.scaleMode = .aspectFit
            return scene
        } else {
            guard let scene = GameScene(fileNamed:"GameScene2") else {
                return nil
            }
            scene.scaleMode = .aspectFit
            return scene
            
        
    }
    
}


}








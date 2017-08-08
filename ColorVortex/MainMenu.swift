//
//  MainMenu.swift
//  ColorVortex
//
//  Created by Paxon Yu on 7/7/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import Foundation
import SpriteKit


class MainMenu: SKScene {
    
    
    var playButton: MSButtonNode!
    var colorBlindMode: MSButtonNode!
    var colorBool: Bool = false
    
    
    
    override func didMove(to view: SKView) {
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        playButton.selectedHandler = {
            self.loadGame()
        }
        colorBlindMode = childNode(withName: "colorBlind") as! MSButtonNode
        colorBlindMode.selectedHandler = {
            self.colorBool = !self.colorBool
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if colorBool == true {
            colorBlindMode.texture = SKTexture(imageNamed: "CheckBoxCheck")
        }else {
            colorBlindMode.texture = SKTexture(imageNamed: "CheckBoxNoCheck")
        }
    }
    
    func loadGame() {
        
        guard let skView = self.view as SKView! else {
            print("Could not get SKview")
            return
        }
        guard let scene = GameScene.level(colorBlind: colorBool) else {
            print("Could not get GameScene")
            return
        }
        scene.colorBlind = colorBool
        scene.scaleMode = .aspectFit
        
    
        skView.presentScene(scene)
    }
}

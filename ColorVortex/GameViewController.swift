//
//  GameViewController.swift
//  ColorVortex
//
//  Created by Paxon Yu on 7/3/17.
//  Copyright © 2017 Paxon Yu. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = MainMenu(fileNamed: "MainMenu") {
            
        
       scene.scaleMode = .aspectFit
                
                // Present the scene
                if let view = self.view as! SKView? {
                    
                    view.presentScene(scene)
                    
                    view.ignoresSiblingOrder = true
                    
               
                
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

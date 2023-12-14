//
//  ViewController.swift
//  Earth-and-Sun
//
//  Created by sebi d on 12/7/23.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    @IBOutlet weak var eccSliderValue: NSSlider!
    @IBOutlet weak var eccTxtFieldValue: NSTextField!
    
    var gameScene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // save the scene for setting eccentricity
                gameScene = scene
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    @IBAction func eccTxtFieldDidChange(_ sender: Any) {
    }
    @IBAction func eccSliderDidChange(_ sender: NSSlider) {
        let newEcc = sender.floatValue
        eccTxtFieldValue.floatValue = newEcc
        
        gameScene?.eccentricity = newEcc
    }
}


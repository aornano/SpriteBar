//
//  GameScene.swift
//  SpriteBar
//
//  Created by Alessandro Ornano on 03/06/2018.
//  Copyright © 2018 Alessandro Ornano. All rights reserved.
//

import SpriteKit
class GameScene: SKScene {
    var energyProgressBar: SpriteBar!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        print("❊ --- \(type(of: self)) --- ")
        let progressBarAtlas = SKTextureAtlas.init(named: "sb_default")
        self.energyProgressBar = SpriteBar(textureAtlas: progressBarAtlas)
        self.addChild(self.energyProgressBar)
        self.energyProgressBar.size = CGSize(width:350, height:150)
        self.energyProgressBar.position = CGPoint(x:self.frame.width/2, y:self.frame.height/2)
        
        let wait = SKAction.wait(forDuration: 2.0)
        let action1 = SKAction.run {
            self.energyProgressBar.setProgress(0.7)
        }
        let action2 = SKAction.run {
            self.energyProgressBar.setProgress(0.0)
        }
        let action3 = SKAction.run {
            self.energyProgressBar.setProgress(1.0)
        }
        let action4 = SKAction.run {
            self.energyProgressBar.setProgress(0.5)
        }
        let action5 = SKAction.run {
            self.energyProgressBar.setProgress(0.1)
        }
        let action6 = SKAction.run {
            self.energyProgressBar.startBarProgress(withTimer: 10, target: self, selector: #selector(self.timeOver))
        }
        let sequence = SKAction.sequence([wait,action1,wait,action2,wait,action3,wait,action4,wait,action5,wait,action6])
        self.run(sequence)
    }
    @objc func timeOver() {
        print("time is over")
    }
}



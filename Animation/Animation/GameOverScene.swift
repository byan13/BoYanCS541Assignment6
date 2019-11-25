//
//  GameOverScene.swift
//  Animation
//
//  Created by Bo Yan on 10/11/19.
//  Copyright © 2019 Bo Yan. All rights reserved.
//

import Foundation

import SpriteKit

class GameOverScene: SKScene {
  init(size: CGSize, won:Bool) {
    super.init(size: size)
    
    // 1
    backgroundColor = SKColor.white
    
    // 2
    let message = won ? "You Are A True KungFu Master!" : "You Still Have A Long Way to go!"
    
    // 3
    let label = SKLabelNode(fontNamed: "BradleyHandiTCTT-Bold")
    label.text = message
    label.fontSize = 40
    label.fontColor = SKColor.black
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
    
    // 4
    run(SKAction.sequence([
      SKAction.wait(forDuration: 3.0),
      SKAction.run() { [weak self] in
        // 5
        guard let `self` = self else { return }
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
      }
      ]))
   }
  
  // 6
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

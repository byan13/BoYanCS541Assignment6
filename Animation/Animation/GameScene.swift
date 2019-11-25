//
//  GameScene.swift
//  Animation
//
//  Created by Bo Yan on 10/11/19.
//  Copyright © 2019 Bo Yan. All rights reserved.
//

import SpriteKit
import GameplayKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
  }
  
    func normalized() -> CGPoint {
        return self / length()
  }
}

struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let monster   : UInt32 = 0b1
    static let projectile: UInt32 = 0b10
}

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "player")
    var monstersDestroyed = 0
    let label = SKLabelNode(fontNamed: "BradleyHandiTCTT-Bold")

    override func didMove(to view: SKView) {

        backgroundColor = SKColor.white
        
        player.position = CGPoint(x: -250, y: 0)
        addChild(player)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addMonster),
            SKAction.wait(forDuration: 1.0)
            ])
        ))
    }

    func addMonster(){
        let monster = SKSpriteNode(imageNamed: "monster")
        
        let actualY = Int.random(in: -350 ..< 350)
        
        monster.position = CGPoint(x: 250, y: actualY)
        
        addChild(monster)
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        let actualDuration = Float.random(in: 2 ..< 4)
        
        let monsterMove = SKAction.move(to: CGPoint(x: -250, y: actualY), duration: TimeInterval(actualDuration))
        
        let monsterMoveDone = SKAction.removeFromParent()
        
        //monster.run(SKAction.sequence([monsterMove, monsterMoveDone]))
        let loseAction = SKAction.run() { [weak self] in
          guard let `self` = self else { return }
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
          let gameOverScene = GameOverScene(size: self.size, won: false)
          self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.run(SKAction.sequence([monsterMove, loseAction, monsterMoveDone]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
      
      // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
      
      // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
      
      // 4 - Bail out if you are shooting down or backwards
        if offset.x < 0 { return }
      
      // 5 - OK to add now - you've double checked position
        addChild(projectile)
      
      // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
      
      // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
      
      // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
      
      // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        monstersDestroyed += 1
        projectile.removeFromParent()
        monster.removeFromParent()
        
        label.removeFromParent()
        
        label.text = "Hits: \(monstersDestroyed)"
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: 0, y: 400)
        addChild(label)
        
        if monstersDestroyed > 10 {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
      // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
     
      // 2
      if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
          (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let projectile = secondBody.node as? SKSpriteNode {
                    projectileDidCollideWithMonster(projectile: projectile, monster: monster)
        }
      }
    }
}

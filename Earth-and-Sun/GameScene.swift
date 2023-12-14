//
//  GameScene.swift
//  Earth-and-Sun
//
//  Created by sebi d on 12/7/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var path: SKShapeNode!
    var earth: SKShapeNode!
    var sun: SKShapeNode!
    
    let earthColor = NSColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 1)
    let sunColor = NSColor(red: 0.9, green: 0.9, blue: 0.1, alpha: 1)
    
    var eccentricity: Float = 0.33 {
        didSet {
            updateOrbitPath()
            positionSun()
            ellipseAlpha = getAlpha(eccentricity, path)
            makeAngVArr()
        }
    }
    
    var earthAngle: Float = .pi // start left
    var ellipseAlpha: Float = 1.0
    
    // kepler's 2nd law physics
    var interpRes: Int = 40
    var angVArr: [Float] = []
    
    // helper to find angV at an angle
    func getAngV( _ atAngle: Float) -> Float {
        let increment : Float = 2 * Float.pi / Float(interpRes)
        // find the index of the time wedge
        // currentAngle / increment
        
        // we have to use truncating remainder which will make sure we stay between 0 and 2 pi
        let currAngleIndex = Int( atAngle.truncatingRemainder(dividingBy: 2 * Float.pi) / increment )
        return angVArr[currAngleIndex]
    }
    
    // function which sets angular velocities
    func makeAngVArr() {
        let increment : Float = 2 * Float.pi / Float(interpRes)
        var radiusArr : [Float] = [Float].init(repeating: 0.0, count: interpRes)
        var angularVelocities: [Float] = [Float].init(repeating: 0.0, count: interpRes)
        
        // radii from radius helper, increment times indices gets all the way around 2pi
        for i in 0..<interpRes {
            radiusArr[i] = radiusCalc(eccentricity, ellipseAlpha, increment * Float(i) )
        }
        
        // set T1 for first angular velocity
        let t1: Float = 1 / Float(interpRes) // scales with resol.
        
        // first angular velocity
        let angV0 = increment / t1 // first angle over first time.
        angularVelocities[0] = angV0
        
        let M1: Float = 1.0 // planet mass
        let L = angV0 * pow(radiusArr[0],2) * M1  // angV * momntofInertia
        
        // conservation momentum L is the same everywhere
        for i in 0..<interpRes {
            let mInertia = M1 * pow(radiusArr[i], 2)
            // L = angV[i] * mInertia
            
            // angV[i] = L / mInertia
            angularVelocities[i] = L / mInertia
        }
        
        self.angVArr = angularVelocities
    }
    
    func updateOrbitPath() {
        // clear the orbit path form scene (danger! dont forget to make it again)
        if (path != nil)
        {
            path.removeFromParent()
        }
        path  = nil
        
        let width = self.frame.width
        let height = self.frame.height
        let sceneSize = CGSize(width: width, height: height)
        let sceneCenter = CGPoint(x: width / 2, y: height / 2)
        
        let abRatio = CGFloat( sqrtf( 1 - pow(Float(eccentricity), 2 )))
        let a = ( width > height ? height : width ) * 0.6 // ellipse width
        let b = a * abRatio // ellipse height related by abRatio
        
        path = SKShapeNode(ellipseOf: CGSize(width: a, height: b))
        path.position = sceneCenter
        path.name = "path"
        self.addChild(path)
    }
    
    func positionSun() {
        // position on the ellipse
        let focalPointX = CGFloat(eccentricity) * path.frame.width / 2
        let pathCenter = path.position
        
        sun.position = pathCenter
        sun.position.x += focalPointX
    }
    
    // ellipse geometry helpers
    func radiusCalc(_ epsilon: Float, _ alpha: Float, _ angle: Float ) -> Float {
        return alpha / ( 1 + epsilon * cos(angle) )
    }
    
    func getAlpha(_ epsilon: Float, _ path: SKShapeNode) -> Float {
        let a = path.frame.width / 2
        return Float(a) * ( 1 - pow(epsilon, 2) )
    }
    
    func positionEarth() {
        // position on the sun, then use angle to find new X and Y positions
        let semiMajor = path.frame.width * 0.5
        let semiMinor = path.frame.height * 0.5
       
        let newPosX = semiMajor * CGFloat(cos(earthAngle))
        let newPosY = semiMinor * CGFloat(sin( earthAngle ))
        
        earth.position = path.position
        earth.position.x += newPosX
        earth.position.y += newPosY
    }
    
    func createNodes() {
        let width = self.frame.width
        let height = self.frame.height
        let sceneSize = CGSize(width: width, height: height)
        let sceneCenter = CGPoint(x: width / 2, y: height / 2)
        
        //path
        path = SKShapeNode(ellipseOf: sceneSize)
        path.position = sceneCenter
        
        //earth and sun
        earth = SKShapeNode(circleOfRadius: 20)
        sun = SKShapeNode(circleOfRadius: 30)
        earth.fillColor = earthColor
        sun.fillColor = sunColor
        
        earth.position = sceneCenter
        earth.zPosition = 1.0
        
        sun.position = sceneCenter
        
        addChild(path)
        
        addChild(sun)
        addChild(earth)
    }
    
    override func didMove(to view: SKView) {
        createNodes()
        eccentricity = 0.6
        updateOrbitPath()
        positionSun()
        positionEarth()
        makeAngVArr()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let gameView = self.view {
            let timeStep = 1 / Float(gameView.preferredFramesPerSecond)
            earthAngle += timeStep * getAngV(earthAngle)
        }
        
        positionEarth()
    }
}

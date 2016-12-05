//
//  ViewController.swift
//  MetalCube
//
//  Created by Tony Lattke on 24.11.16.
//  Copyright © 2016 bremen.de. All rights reserved.
//

import UIKit
import simd

class SceneViewController: MetalViewController, MetalViewControllerDelegate {
    
    // World Model Matrix
    var worldModelMatrix: float4x4!
    
    // Create a object to draw
    var objectToDraw: Cube!
    
    // Gesture recognition
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    
    // Inititalization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worldModelMatrix = float4x4()
        worldModelMatrix?.translate(0.0, y: 0.0, z: -4.0)
        worldModelMatrix?.rotateAroundX(float4x4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        objectToDraw = Cube(device: device, commandQ: commandQueue, textureLoader: textureLoader)
        
        setupGestures()
        
        self.metalViewControllerDelegate = self
        
    }
    
    
    //MARK: - MetalViewControllerDelegate
    func renderObjects(drawable:CAMetalDrawable) {
        // Background
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // Render Objects
        objectToDraw.render(commandQueue: commandQueue, depthStencilState: depthStencilState, pipelineState: pipelineState, drawable: drawable, renderPassDescriptor: renderPassDescriptor, parentModelViewMatrix: worldModelMatrix!, projectionMatrix: projectionMatrix)
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
    }
    
    //MARK: - Gesture related
    // 1
    func setupGestures(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(SceneViewController.pan))
        self.view.addGestureRecognizer(pan)
    }
    
    // 2
    func pan(panGesture: UIPanGestureRecognizer){
        if panGesture.state == UIGestureRecognizerState.changed{
            let pointInView = panGesture.location(in: self.view)
            
            let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
            let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
            
            objectToDraw.rotationY -= xDelta
            objectToDraw.rotationX -= yDelta
            lastPanLocation = pointInView
        } else if panGesture.state == UIGestureRecognizerState.began{
            lastPanLocation = panGesture.location(in: self.view)
        } 
    }
    
}

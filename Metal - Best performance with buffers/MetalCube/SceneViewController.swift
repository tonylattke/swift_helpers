//
//  ViewController.swift
//  MetalCube
//
//  Created by Tony Lattke on 24.11.16.
//  Copyright © 2016 bremen.de. All rights reserved.
//

import UIKit

class SceneViewController: MetalViewController, MetalViewControllerDelegate {
    
    // World Model Matrix
    var worldModelMatrix: Matrix4!
    
    // Create a object to draw
    var objectToDraw: Cube!
    
    // Inititalization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worldModelMatrix = Matrix4()
        worldModelMatrix?.translate(0.0, y: 0.0, z: -4.0)
        worldModelMatrix?.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        // Setting vertex Buffer
        objectToDraw = Cube(device: device)
        
        self.metalViewControllerDelegate = self
        
    }
    
    
    //MARK: - MetalViewControllerDelegate
    func renderObjects(drawable:CAMetalDrawable) {
        // Background
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        // Render Objects
        objectToDraw.render(commandQueue: commandQueue, depthStencilState: depthStencilState, pipelineState: pipelineState, drawable: drawable, renderPassDescriptor: renderPassDescriptor, parentModelViewMatrix: worldModelMatrix!, projectionMatrix: projectionMatrix)
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
    }
    
}

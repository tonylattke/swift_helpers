//
//  MetalViewController.swift
//  MetalCube
//
//  Created by Tony Lattke on 01.12.16.
//  Copyright © 2016 HSB. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

protocol MetalViewControllerDelegate : class{
    func updateLogic(timeSinceLastUpdate:CFTimeInterval)
    func renderObjects(drawable:CAMetalDrawable)
}

class MetalViewController: UIViewController {
    // Create a MTLDevice
    var device: MTLDevice! = nil
    
    // Create a MetalLayer
    var metalLayer: CAMetalLayer! = nil

    // Create pipeline
    var pipelineState: MTLRenderPipelineState! = nil
    
    // Create a Command Queue
    var commandQueue: MTLCommandQueue! = nil
    
    // Create a timer (Display link)
    var timer: CADisplayLink! = nil
    
    // Setting Camera
    var projectionMatrix: Matrix4!
    
    // Last frame time interval
    var lastFrameTimestamp: CFTimeInterval = 0.0
    
    // Depth Stencil State
    var depthStencilState: MTLDepthStencilState! = nil
    
    weak var metalViewControllerDelegate:MetalViewControllerDelegate?
    
    // Inititalization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        
        // Init Device
        device = MTLCreateSystemDefaultDevice()
        
        // Setting metalLayer
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        // Setting depthStencilDescriptor
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
        
        // Setting command queue
        commandQueue = device.makeCommandQueue()
        
        // Create a connection with the Shaders
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")
        
        // Create a Render Pipeline
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Pipeline connection
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch  {
            print("Error creating pipeline")
        }
        
        // Setting timer to render loop
        timer = CADisplayLink(target: self, selector: #selector(MetalViewController.newFrame)) // Selector("renderloop")
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        print("Initialization finished")
    }
    
    // Render
    func render() {
        if let drawable = metalLayer.nextDrawable(){
            self.metalViewControllerDelegate?.renderObjects(drawable: drawable)
        }
    }
    
    // Calculate Timestamp
    func newFrame(displayLink: CADisplayLink){
        // Init last frame timespamp
        if lastFrameTimestamp == 0.0 {
            lastFrameTimestamp = displayLink.timestamp
        }
        
        // Calculate elapsed time
        let elapsed:CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        // Init loop
        renderloop(timeSinceLastUpdate: elapsed)
    }
    
    // Render loop
    func renderloop(timeSinceLastUpdate: CFTimeInterval) {
        self.metalViewControllerDelegate?.updateLogic(timeSinceLastUpdate: timeSinceLastUpdate)
        
        autoreleasepool {
            self.render()
        }
    }


}

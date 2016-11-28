//
//  ViewController.swift
//  MetalCube
//
//  Created by Tony Lattke on 24.11.16.
//  Copyright © 2016 bremen.de. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {
    
    // Create a MTLDevice
    var device: MTLDevice! = nil

    // Create a MetalLayer
    var metalLayer: CAMetalLayer! = nil
    
    // Create a object to draw
    var objectToDraw: Cube!
    
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
        
        // Setting vertex Buffer
        objectToDraw = Cube(device: device)
        
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
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame)) // Selector("renderloop")
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        print("Initialization finished")
    }
    
    // Render Scene
    
    func render() {
        let drawable = metalLayer.nextDrawable()
        
        // Background
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable?.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        // Create command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // Camera
        let worldModelMatrix = Matrix4()
        worldModelMatrix?.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix?.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        // Render Objects
        objectToDraw.render(commandQueue: commandQueue, depthStencilState: depthStencilState, pipelineState: pipelineState, drawable: drawable!, renderPassDescriptor: renderPassDescriptor, parentModelViewMatrix: worldModelMatrix!, projectionMatrix: projectionMatrix, commandBuffer: commandBuffer)
    }
    
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
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
        autoreleasepool {
            self.render()
        }
    }
}

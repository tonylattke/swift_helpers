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
    var objectToDraw: Triangle!
    
    // Create pipeline
    var pipelineState: MTLRenderPipelineState! = nil
    
    // Create a Command Queue
    var commandQueue: MTLCommandQueue! = nil
    
    // Create a timer (Display link)
    var timer: CADisplayLink! = nil
    
    // Inititalization
    override func viewDidLoad() {
        super.viewDidLoad()
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
        objectToDraw = Triangle(device: device)
        
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
        timer = CADisplayLink(target: self, selector: #selector(ViewController.renderloop)) // Selector("renderloop")
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
        
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable!, renderPassDescriptor: renderPassDescriptor, commandBuffer: commandBuffer)
    }
    
    // Render loop
    func renderloop() {
        autoreleasepool {
            self.render()
        }
    }
}

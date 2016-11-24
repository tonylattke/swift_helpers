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
    
    // Create a Vertex Buffer
    let vertexData:[Float] = [
        0.0, 0.5, 0.0,      // Top
        -0.5, -0.5, 0.0,    // Left-corner
        0.5, -0.5, 0.0]     // Right-corner
    var vertexBuffer: MTLBuffer! = nil
    
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
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // 1
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize) // 2
        
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
        // Drawable
        let drawable = metalLayer.nextDrawable()
        
        // Create and setting a Render Pass Descriptor (background texture)
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable?.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        // Setting backgroundcolor
        // renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        // Create command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // Create and setting a Render Command Encoder
        let renderEncoderOpt = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoderOpt.setRenderPipelineState(pipelineState)
        renderEncoderOpt.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoderOpt.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoderOpt.endEncoding()

        // Commit your Command Buffer
        commandBuffer.present(drawable!)
        commandBuffer.commit()
    }
    
    // Render loop
    func renderloop() {
        autoreleasepool {
            self.render()
        }
    }
}

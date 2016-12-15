//
//  MetalViewController.swift
//  MetalCube
//
//  Created by Tony Lattke on 01.12.16.
//  Copyright © 2016 Hochschule Bremen. All rights reserved.
//

import UIKit
import MetalKit
import QuartzCore
import simd

protocol MetalViewControllerDelegate : class{
    func updateLogic(timeSinceLastUpdate:CFTimeInterval)
    func renderObjects(drawable:CAMetalDrawable)
}

class MetalViewController: UIViewController {
    // MTLDevice
    var device: MTLDevice! = nil
    
    // Pipeline
    var pipelineState: MTLRenderPipelineState! = nil
    
    // Pipeline state
    var basicPipelineState: MTLRenderPipelineState! = nil
    
    // Command Queue
    var commandQueue: MTLCommandQueue! = nil
    
    // Depth Stencil State
    var depthStencilState: MTLDepthStencilState! = nil
    
    // Metal View Controller Delegate
    weak var metalViewControllerDelegate:MetalViewControllerDelegate?
    
    // Texture Loader
    var textureLoader: MTKTextureLoader! = nil
    
    // Camera
    var camera: Camera!
    
    // Image View
    @IBOutlet weak var mtkView: MTKView! {
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
            mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    // Inititalization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Camera
        let position = float3(0,0,10)
        let lookAt = float3(0,0,0)
        let up = float3(0,1,0)
        let aspectRatio = Float(self.view.bounds.size.width / self.view.bounds.size.height)
        camera = Camera(position: position, lookAt: lookAt, up: up, aspectRatio: aspectRatio, angleDregrees: 65.0, nearPlan: 1.0, farPlan: 1000.0)
        
        // Init Device
        device = MTLCreateSystemDefaultDevice()
        textureLoader = MTKTextureLoader(device: device)
        mtkView.device = device
        
        // Setting depthStencilDescriptor
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
        
        // Setting command queue
        commandQueue = device.makeCommandQueue()
        
        // Create a connection with the Shaders
        let defaultLibrary = device.newDefaultLibrary()
        // Vertex Shaders
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")
        // Fragment Shaders
        let basicFragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
        let lightFragmentProgram = defaultLibrary!.makeFunction(name: "light_complex_fragment")
        
        // Create a Render Pipeline
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = lightFragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let basicPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        basicPipelineStateDescriptor.vertexFunction = vertexProgram
        basicPipelineStateDescriptor.fragmentFunction = basicFragmentProgram
        basicPipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Pipeline connection
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            basicPipelineState = try device.makeRenderPipelineState(descriptor: basicPipelineStateDescriptor)
        } catch  {
            print("Error creating pipeline")
        }
        
        print("Initialization finished")
    }
    
    // Render
    func render(_ drawable: CAMetalDrawable?) {
        guard let drawable = drawable else { return }
        self.metalViewControllerDelegate?.renderObjects(drawable: drawable)
    }

}

// MARK: - MTKViewDelegate
extension MetalViewController: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspectRatio = Float(self.view.bounds.size.width / self.view.bounds.size.height)
        camera.projectionMatrixUpdate(aspectRatio: aspectRatio)
    }
    
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
    
}

//
//  ViewController.swift
//  MetalCube
//
//  Created by Tony Lattke on 24.11.16.
//  Copyright © 2016 Hochschule Bremen. All rights reserved.
//

import UIKit
import simd
import AVFoundation

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
    let context = CIContext(options: nil)
    let cgi : CGImage! = context.createCGImage(inputImage, from: inputImage.extent)
    return cgi
}

class SceneViewController: MetalViewController, MetalViewControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Create a object to draw
    var cube: Cube!
    var cameraPlane: Plane!
    var light: Light!
    
    // Gesture recognition
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    
    // Buffer Provider
    var bufferProvider: BufferProvider!
    
    // Camera session
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetHigh
        return s
    }()
    
    var renderPassDescriptor: MTLRenderPassDescriptor!
    
    var lastTime: CFTimeInterval = 0
    var fps: Int = 60
    
    @IBOutlet weak var fpsLabel: UILabel!
    
    // Inititalization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Buffer
        let sizeOfUniformsBuffer = MemoryLayout<Float>.size * float4x4.numberOfElements() * 2 + Light.size()
        bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: sizeOfUniformsBuffer)
        
        // Create camera far plane
        cameraPlane = Plane(name: "Plane", device: device, commandQ: commandQueue, textureLoader: textureLoader, srcImage: "assets/images/black", typeImage: "jpg")
        cameraPlane.scale = float3(x:360, y: 640, z: 1)
        cameraPlane.position.z = -989.0
        
        // Create Cube
        cube = Cube(name: "Cube", device: device, commandQ: commandQueue, textureLoader: textureLoader, srcImage: "assets/images/cube", typeImage: "png")
        
        // Create Light
        light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.2, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8, shininess: 10, specularIntensity: 2)
        
        // Settings
        setupGestures()
        setupCameraSession()
        
        renderPassDescriptor = MTLRenderPassDescriptor()
        
        // Assign delegate
        self.metalViewControllerDelegate = self
    }
    
    // Start App
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Run camera session
        cameraSession.startRunning()
    }
    
    // Setup camera
    func setupCameraSession() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput)) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if (cameraSession.canAddOutput(dataOutput)) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.invasivecode.videoQueue2")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    // Output of Camera
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        // Get Image
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        // Rotate image
        var tx = CGAffineTransform(translationX: cameraImage.extent.width / 2, y: cameraImage.extent.height / 2)
        tx = tx.rotated(by: CGFloat(-M_PI/2))
        tx = tx.translatedBy(x: -cameraImage.extent.width / 2,y: -cameraImage.extent.height / 2)
        let transformImage = CIFilter(
            name: "CIAffineTransform",
            withInputParameters: [
                kCIInputImageKey: cameraImage,
                kCIInputTransformKey: NSValue(cgAffineTransform: tx)])!.outputImage!
        
        /* Apply filter - Optional
        
        let InvertFilter = CIFilter(name: "CIColorInvert")
        let filter = InvertFilter
        filter!.setValue(transformImage, forKey: kCIInputImageKey)
        let filteredImage = filter!.value(forKey: kCIOutputImageKey) as! CIImage!
        
        let cgImage = convertCIImageToCGImage(inputImage: filteredImage!
        
        */
        
        // Create CGimage
        let cgImage = convertCIImageToCGImage(inputImage: transformImage)

        // Assign image in the texture
        DispatchQueue.main.sync {
            self.cameraPlane.texture = try! self.textureLoader.newTexture(with: cgImage!)
        }
        
    }
    
    // Dopped frames manage
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
    }
    
    
    //MARK: - MetalViewControllerDelegate
    func renderObjects(drawable:CAMetalDrawable) {
        
        // Background
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // Wait to the next Buffer
        _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: .distantFuture)
        
        // Get avaiable buffer and create a command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.addCompletedHandler { (commandBuffer) -> Void in
            self.bufferProvider.avaliableResourcesSemaphore.signal()
        }
        
        // Create and setting a Render Command Encoder
        let renderEncoderOpt = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoderOpt.setCullMode(MTLCullMode.front)
        renderEncoderOpt.setDepthStencilState(depthStencilState)
        
        // Render Objects
        // Camera
        cameraPlane.render(pipelineState: basicPipelineState, camera: camera, renderEncoderOpt: renderEncoderOpt, bufferProvider: bufferProvider, light: light)
        
        // Cube
        cube.render(pipelineState: pipelineState, camera: camera, renderEncoderOpt: renderEncoderOpt, bufferProvider: bufferProvider, light: light)
        // End rendering
        renderEncoderOpt.endEncoding()
        
        // Commit your Command Buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        fpsLabel.text = "FPS = \(fps)"
    }
    
    // Update timer on Objects
    func updateLogic(time: CFTimeInterval) {
        fps = 60
        let elapsed = time - lastTime
        
        if elapsed > 0 {
            fps = Int(round(1 / elapsed)/60)
        }
        lastTime = time
        
        cube.updateWithDelta(delta: time)
        cameraPlane.updateWithDelta(delta: time)
    }
    
    //MARK: - Gesture related
    func setupGestures(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(SceneViewController.pan))
        self.view.addGestureRecognizer(pan)
    }
    
    // Setting pan gesture trigger
    func pan(panGesture: UIPanGestureRecognizer){
        if panGesture.state == UIGestureRecognizerState.changed{
            let pointInView = panGesture.location(in: self.view)
            
            let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
            let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
            
            cube.rotation.y -= xDelta
            cube.rotation.x -= yDelta
            lastPanLocation = pointInView
        } else if panGesture.state == UIGestureRecognizerState.began{
            lastPanLocation = panGesture.location(in: self.view)
        } 
    }
    
    // Destroy - TODO
    deinit {
        cameraPlane=nil
        cube=nil
    }

}

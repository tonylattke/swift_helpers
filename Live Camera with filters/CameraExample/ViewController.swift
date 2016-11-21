//
//  ViewController.swift
//  CameraExample
//
//  Created by Tony Lattke on 11/18/16.
//  Copyright © 2016 bremen.de, Inc. All rights reserved.
//

import UIKit
import AVFoundation

// Filters
let CMYKHalftoneFilter = CIFilter(name: "CICMYKHalftone", withInputParameters: ["inputWidth" : 20, "inputSharpness": 1])
let ComicEffectFilter = CIFilter(name: "CIComicEffect")
let CrystallizeFilter = CIFilter(name: "CICrystallize", withInputParameters: ["inputRadius" : 30])
let EdgesEffectFilter = CIFilter(name: "CIEdges", withInputParameters: ["inputIntensity" : 10])
let HexagonalPixellateFilter = CIFilter(name: "CIHexagonalPixellate", withInputParameters: ["inputScale" : 40])
let InvertFilter = CIFilter(name: "CIColorInvert")
let PointillizeFilter = CIFilter(name: "CIPointillize", withInputParameters: ["inputRadius" : 30])
let LineOverlayFilter = CIFilter(name: "CILineOverlay")
let PosterizeFilter = CIFilter(name: "CIColorPosterize", withInputParameters: ["inputLevels" : 5])

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // imageView -> Storyboard
    @IBOutlet weak var imageView: UIImageView!
    
    // Camera session
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetLow
        return s
    }()
    
    // Layer
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.videoGravity = AVLayerVideoGravityResize
        return preview!
    }()
    
    // Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraSession()
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

			if (cameraSession.canAddInput(deviceInput) == true) {
				cameraSession.addInput(deviceInput)
			}

			let dataOutput = AVCaptureVideoDataOutput()
			dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
			dataOutput.alwaysDiscardsLateVideoFrames = true

			if (cameraSession.canAddOutput(dataOutput) == true) {
				cameraSession.addOutput(dataOutput)
			}

			cameraSession.commitConfiguration()

			let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
			dataOutput.setSampleBufferDelegate(self, queue: queue)

		}
		catch let error as NSError {
			NSLog("\(error), \(error.localizedDescription)")
		}
	}

    
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
		
        // Get Image
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        // Apply filter
        let filter = InvertFilter
        filter!.setValue(cameraImage, forKey: kCIInputImageKey)
        let filteredImage = UIImage(ciImage: filter!.value(forKey: kCIOutputImageKey) as! CIImage!, scale: 1.0, orientation: UIImageOrientation.right)
        
        DispatchQueue.main.async {
            // Filtered
            self.imageView.image = filteredImage
            
            // Original image
            //self.imageView.image = UIImage(ciImage: cameraImage, scale: 1.0, orientation: UIImageOrientation.right)
        }
        
	}

	func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
		// Here you can count how many frames are dopped
	}
    
    
	
}


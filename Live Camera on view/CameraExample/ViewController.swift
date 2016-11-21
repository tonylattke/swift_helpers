//
//  ViewController.swift
//  CameraExample
//
//  Created by Tony Lattke on 11/18/16.
//  Copyright © 2016 bremen.de, Inc. All rights reserved.
//

import UIKit
import AVFoundation

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

        // Setting layer
        previewLayer.bounds = CGRect(x: 0, y: 0, width: imageView.bounds.width, height: imageView.bounds.height)
        previewLayer.position = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        imageView.layer.addSublayer(previewLayer)
        
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
		// Handle image
	}

	func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
		// Here you can count how many frames are dopped
	}
    
    
	
}


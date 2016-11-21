# Live Camera on view

This app access to the camera and show on the view. AVFoundation is required to have a live access to the camera. 

You need to set a new key and value in your Info.plist to allow the using the camera with your app. 

Key:    Privacy - Camera Usage Description
Value:  $(PRODUCT_NAME) camera use

On the ViewController is the configuration of the app.

- cameraSession contains the camera session, which allows the app to access to the camera. It will be seted on the function setupCameraSession().
- imageView is the Variable which allow to comunicate with the view and show the image.
- previewLayer is the layer with the image. This is seted with the size of the imageView.
- When you work with cameraSession, you need two extra functions on the controller 
- **captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)** This handle the image 
- **captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)** Here you can count how many frames are dopped

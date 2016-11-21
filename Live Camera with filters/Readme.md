# Live Camera with filters

This app access to the camera, show on the view and apply a filter. AVFoundation is required to have a live access to the camera. 

You need to set a new key and value in your Info.plist to allow the using the camera with your app. 

Key:    Privacy - Camera Usage Description
Value:  $(PRODUCT_NAME) camera use

On the ViewController is the configuration of the app.

- cameraSession contains the camera session, which allows the app to access to the camera. It will be seted on the function setupCameraSession().
- imageView is the Variable which allow to comunicate with the view and show the image.
- previewLayer is the layer with the image. 
- When you work with cameraSession, you need two extra functions on the controller 
- **captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)** Here I get the image, apply the filter and set on the imageView. Note: The image is by default 90 grades rotated to the left. 
- **captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!)** Here you can count how many frames are dopped

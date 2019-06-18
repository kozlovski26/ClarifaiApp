//
//  ImageViewController.swift
//  ClarifaiApp
//
//  Created by Bar kozlovski on 30/05/2019.
//  Copyright © 2019 Bar kozlovski. All rights reserved.
//

import UIKit
import AVFoundation

class ImageViewController: UIViewController ,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    var takePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            self.title = "Camera"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareTheCamera()
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.stopCaptureSession()
        
           }
    
    
    func prepareTheCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        captureDevice = availableDevices.first
        startSession()
        
    }
    
    func startSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
            
        } catch {
            print(error)
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value : kCVPixelFormatType_32BGRA )] as [String : Any]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "com.captureQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        
    }
    
    @IBAction func takephoto(_ sender: Any) {
      
        takePhoto = true
       self.dismiss(animated: true, completion: nil)
        
    }
    
   
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        if takePhoto {
            takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                
                let photoVC = tabBarController!.viewControllers![0]  as! ViewController
                
                photoVC.imageToCheck = image
                photoVC.getImage = true
                
               
                DispatchQueue.main.async {

                    self.stopCaptureSession()
                }
            }
            
            
        }
//        if takePhoto {
//
//            let svc = tabBarController!.viewControllers![0] as! ViewController
//
//                svc.getImage = true
//
//                svc.imageToCheck = self.getImageFromSampleBuffer(buffer: sampleBuffer)!
//
//            takePhoto = false
//            self.stopCaptureSession()
//
//            }
        }
    //            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer ) {
    //                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! mainViewController
    //                photoVC.takenPhoto = image
    //
    //                DispatchQueue.main.async {
    //                    self.present(photoVC, animated: true, completion: nil)
    //                }
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
       // dismiss(animated: true, completion: nil)
       
        
}
    

    
}

//
//  CameraViewController.swift
//  FaceDetection
//
//  Created by Wei Chieh Tseng on 27/12/2016.
//  Copyright © 2016 Wei Chieh. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate  {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var face: UILabel!
    
    var faceBoxes = [UIView()]
    
    var captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        captureSession.sessionPreset = AVCaptureSessionPresetPhoto

        // Choose Camera Type
        let backCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                
                if(captureSession.canAddOutput(photoOutput)){
                    captureSession.addOutput(photoOutput)
                    
                    captureSession.startRunning()
                    
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.frame = cameraView.bounds
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    
                    cameraView.layer.addSublayer(previewLayer!)
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        face.isHidden = true
    }
    
    
    func captureImage() {
        
        for faceBox in self.faceBoxes {
            faceBox.removeFromSuperview()
        }
        
        let settings = AVCapturePhotoSettings()
        
        let pixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first!.uint32Value
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: pixelFormatType
            //                             kCVPixelBufferWidthKey as String: 160,
            //                             kCVPixelBufferHeightKey as String: 160,
        ]
        settings.previewPhotoFormat = previewFormat
        photoOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("didFinishProcessingPhotoSampleBuffer")
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
            self.imageView.image = UIImage(data: dataImage)
            self.imageView.isHidden = false
            self.previewLayer?.isHidden = true
            self.findFace(img: self.imageView.image!)
        }
    }
    
    var didTakePhoto = Bool()
    
    func didPressTakeAnother() {
        if didTakePhoto {
            self.previewLayer?.isHidden = false
            self.imageView.isHidden = true
            didTakePhoto = false
        } else {
            
            captureSession.startRunning()
            didTakePhoto = true
            captureImage()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        didPressTakeAnother()
    }
    
}


extension CameraViewController {
    func findFace(img: UIImage) {
        guard let faceImage = CIImage(image: img) else { return }
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        
        
        
        // For converting the Core Image Coordinates to UIView Coordinates
        let detectedImageSize = faceImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -detectedImageSize.height)
        var faceFeatures: [CIFaceFeature]!
        
        // https://github.com/zhangao0086/iOS-CoreImage-Swift/blob/master/FaceDetection/FaceDetection/ViewController.swift
        if let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy) {
            if let orientation = faceImage.properties[kCGImagePropertyOrientation as String] {
                faceFeatures = faceDetector.features(in: faceImage, options: [CIDetectorImageOrientation: orientation]) as! [CIFaceFeature]
            } else {
                faceFeatures = faceDetector.features(in: faceImage, options: nil) as! [CIFaceFeature]
            }
            
            for face in faceFeatures {
                
                // Apply the transform to convert the coordinates
                var faceViewBounds =  face.bounds.applying(transform)
                // Calculate the actual position and size of the rectangle in the image view
                let viewSize = imageView.bounds.size
                let scale = min(viewSize.width / detectedImageSize.width,
                                viewSize.height / detectedImageSize.height)
                let offsetX = (viewSize.width - detectedImageSize.width * scale) / 2
                let offsetY = (viewSize.height - detectedImageSize.height * scale) / 2
                
                faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                print("faceBounds = \(faceViewBounds)")
                faceViewBounds.origin.x += offsetX
                faceViewBounds.origin.y += offsetY
                
                showBounds(at: faceViewBounds)
                
                if face.hasSmile {
                    print("😀")
                }
                
                if face.leftEyeClosed {
                    print("LEFT: 😉")
                }
                
                if face.leftEyeClosed {
                    print("RIGHT: 😉")
                }
            }
            
            if faceFeatures.count != 0 {
                face.isHidden = false
                print("Number of faces: \(faceFeatures.count)")
            } else {
                print("No faces 😢")
                face.isHidden = true
            }
            
            
            
        }
        
        
        
        
    }
    
    func showBounds(at bounds: CGRect) {
        let indicator = UIView(frame: bounds)
        indicator.frame =  bounds
        indicator.layer.borderWidth = 3
        indicator.layer.borderColor = UIColor.red.cgColor
        indicator.backgroundColor = .clear
        
        self.imageView.addSubview(indicator)
        faceBoxes.append(indicator)
        
    }
}


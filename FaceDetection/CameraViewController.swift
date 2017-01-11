//
//  CameraViewController.swift
//  FaceDetection
//
//  Created by Wei Chieh Tseng on 27/12/2016.
//  Copyright © 2016 Wei Chieh. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var face: UILabel!
    
    var faceBoxes = [UIView()]

    var captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG])
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                
                if(captureSession.canAddOutput(photoOutput)){
                    captureSession.addOutput(photoOutput)
                    captureSession.startRunning()

                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer?.frame = cameraView.bounds
                    
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        previewLayer?.frame = cameraView.bounds
    }


    
    
    func captureImage() {
        
        for faceBox in self.faceBoxes {
            faceBox.removeFromSuperview()
        }
        
        let videoConnection = photoOutput.connection(withMediaType: AVMediaTypeVideo)
        videoConnection?.videoOrientation = AVCaptureVideoOrientation.portrait
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.previewPhotoFormat = previewFormat
        photoOutput.capturePhoto(with: settings, delegate: self)

    }

    
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        // Without previewPhotoSampleBuffer
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
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        
        
        // For converting the Core Image Coordinates to UIView Coordinates
        let detectedImageSize = faceImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -detectedImageSize.height)
        
        // [CIDetectorSmile: true, CIDetectorEyeBlink: true]
        if let faces = faceDetector?.features(in: faceImage, options: nil) {
            for face in faces as! [CIFaceFeature] {
                
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
            
            if faces.count != 0 {
                face.isHidden = false
                print("Number of faces: \(faces.count)")
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


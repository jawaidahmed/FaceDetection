//
//  ViewController.swift
//  FaceDetection
//
//  Created by Wei Chieh Tseng on 27/12/2016.
//  Copyright © 2016 Wei Chieh. All rights reserved.
//

import UIKit

class StillImageViewController: UIViewController {

    let imgs = [#imageLiteral(resourceName: "mark"), #imageLiteral(resourceName: "larry"), #imageLiteral(resourceName: "IMG_2694")]

    var faceBoxes = [UIView()]

    @IBOutlet weak var face: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imgs[2]
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        findFace(img: imgs[2])
    }
    
    func findFace(img: UIImage) {
        
        var mouths = 0
        var leftEyeClosed = 0
        var rightEyeClosed = 0
        var smiles = 0
        
        guard let faceImage = CIImage(image: img) else { return }
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        
        
        // For converting the Core Image Coordinates to UIView Coordinates
        let detectedImageSize = faceImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -detectedImageSize.height)

        
        if let faces = faceDetector?.features(in: faceImage, options: [CIDetectorSmile: true, CIDetectorEyeBlink: true]) {
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
                    smiles += 1
                }
                
                if face.leftEyeClosed {
                    print("LEFT: 😉")
                    leftEyeClosed += 1
                }
                
                if face.leftEyeClosed {
                    print("RIGHT: 😉")
                    rightEyeClosed += 1
                }
                
                if face.hasMouthPosition {
                    mouths += 1
                }
            }
            
            if faces.count != 0 {
                face.text = "Number of faces: \(faces.count)\n" +
                            "Number of mouth: \(mouths)\n" +
                            "Number of smile: \(smiles)\n" +
                            "Number of left Eye Closed: \(leftEyeClosed)\n" +
                            "Number of rihgt Eye Closed: \(rightEyeClosed)\n"

            } else {
                print("No faces 😢")
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


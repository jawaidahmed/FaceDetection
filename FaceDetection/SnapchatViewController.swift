//
//  SnapchatViewController.swift
//  FaceDetection
//
//  Created by Wei Chieh Tseng on 27/12/2016.
//  Copyright © 2016 Wei Chieh. All rights reserved.
//

import UIKit

class SnapchatViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var cameraVC: CameraViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        return vc
    }()
    
    lazy var deviceVC:  StillImageViewController = {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StillImageViewController") as! StillImageViewController
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(cameraVC)
        scrollView.addSubview(cameraVC.view)
        cameraVC.didMove(toParentViewController: self)
        
        addChildViewController(deviceVC)
        scrollView.addSubview(deviceVC.view)
        deviceVC.didMove(toParentViewController: self)
        
        var deviceVCFrame = deviceVC.view.frame
        deviceVCFrame.origin.x = self.view.frame.width
        deviceVC.view.frame = deviceVCFrame
        
        scrollView.contentSize = CGSize(width: view.frame.width*2, height: view.frame.height)
    }


}

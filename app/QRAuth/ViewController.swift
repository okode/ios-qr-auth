//
//  ViewController.swift
//  QRAuth
//
//  Created by Pedro Jorquera on 12/2/16.
//  Copyright © 2016 Okode. All rights reserved.
//

import UIKit
import AVFoundation
import MobileForms
import PKHUD
import RestFetcher

class ViewController: UIViewController, FormDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var form: Form!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var qrCode = ""
    var qrDetections = 0
    var jsonData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form.delegate = self
        
        let filepath = NSBundle.mainBundle().pathForResource("contact", ofType: "json", inDirectory: "json")
        do {
            form.layout = try NSString(contentsOfFile: filepath!, usedEncoding: nil) as String
            form.load()
        } catch { }

    }
    
    func result(data: String) {
        jsonData = data
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            return
        }

        captureSession = AVCaptureSession()
        captureSession?.addInput(input as AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
    }
    
    func event(eventType: FormEventType, element: String, value: String) { }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            qrCode = ""
            qrDetections = 0
            return
        }

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                let currentQRCode = metadataObj.stringValue
                if currentQRCode != qrCode {
                    qrCode = currentQRCode
                    qrDetections = 0
                } else {
                    ++qrDetections
                }
                if (qrDetections == 10) {
                    let url = qrCode
                    qrCodeFrameView?.removeFromSuperview()
                    videoPreviewLayer?.removeFromSuperlayer()
                    captureSession?.stopRunning()
                    qrCode = ""
                    qrDetections = 0
                    AudioServicesPlaySystemSound(1052)
                    auth(url)
                }
            }
        }
    }
    
    func auth(url: String) {
        PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Activando...")
        PKHUD.sharedHUD.show()
        
        RestFetcher(resource: url, method: RestMethod.POST, headers: [String: String](), body: jsonData,
            successCallback: { (response) -> () in
                PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                PKHUD.sharedHUD.hide(afterDelay: 2.0)
                AudioServicesPlaySystemSound(1005)
            }, errorCallback: { (error) -> () in
                PKHUD.sharedHUD.contentView = PKHUDErrorView()
                PKHUD.sharedHUD.hide(afterDelay: 2.0)
                AudioServicesPlaySystemSound(1003)
            }).fetch()
    }
    
}


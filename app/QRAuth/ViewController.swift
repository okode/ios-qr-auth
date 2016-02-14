//
//  ViewController.swift
//  QRAuth
//
//  Created by Pedro Jorquera on 12/2/16.
//  Copyright © 2016 Okode. All rights reserved.
//

import UIKit
import MobileForms
import AVFoundation

class ViewController: UIViewController, FormDelegate, AVCaptureMetadataOutputObjectsDelegate {

    var form: Form!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var qrCode = ""
    var qrDetections = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = Form(controller: self)
        form.delegate = self
        
        let filepath = NSBundle.mainBundle().pathForResource("contact", ofType: "json", inDirectory: "json")
        do {
            let contents = try NSString(contentsOfFile: filepath!, usedEncoding: nil) as String
            form.setForm(contents)
            form.load()
        } catch { }

    }
    
    func result(data: String) {
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
                if (qrDetections == 20) {
                    print(qrCode)
                }
            }
        }
    }
    
}


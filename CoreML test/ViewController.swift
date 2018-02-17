//
//  ViewController.swift
//  CoreML test
//
//  Created by Khalil on 03/01/2018.
//  Copyright © 2018 Trash Productions. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate  {
    @IBOutlet weak var textLabel: UILabel!
    var text:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input)
        captureSession.startRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session : captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        let cameraOutput = AVCaptureVideoDataOutput()
        cameraOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(cameraOutput)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let model = try? VNCoreMLModel(for : Resnet50().model ) else {return}
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let request = VNCoreMLRequest(model: model) { (finishReq, err) in
            guard let results = finishReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            DispatchQueue.main.async { // Correct
                    self.textLabel.text = firstObservation.identifier
                }
        }
       // VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [<#T##[VNImageOption : Any]#>]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options:[:] ).perform([request])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  VideoRecordViewController.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 29/06/1445 AH.
//

import UIKit
import ARKit
import AVKit
import SwiftUI

class VideoRecordViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate {
    lazy var sceneView: ARSCNView = {
            let sceneView = ARSCNView()
            sceneView.delegate = self
            return sceneView
        }()
    var infoLabel: UILabel?
    var faceConfiguration = ARFaceTrackingConfiguration()
    var startButton: UIButton?
    var stopButton: UIButton?
    var moustachOptions = [String]()
    let features = ["mouthTopCenter"]
    var featureIndices = [[ 24]]
    @ObservedObject var viewModel : VideoViewModel = VideoViewModel()
    var firstImage: UIImage?
    var videoRecordStatus = false
    private var isRecording:Bool = false
    var lastTime:TimeInterval = 0
    private var videoStartTime:CMTime?
    
     // Asset Writer
     var pixelBufferAdaptor:AVAssetWriterInputPixelBufferAdaptor?
     var videoInput:AVAssetWriterInput?
     var audioInput:AVAssetWriterInput?
     var assetWriter:AVAssetWriter?
    var captureSession: AVCaptureSession?
    var micInput:AVCaptureDeviceInput?
    var audioOutput:AVCaptureAudioDataOutput?
    // MARK: Adio RECORDING FUNCTIONALITY
        func startAudioRecording(completionHandler:@escaping(Bool) -> ()) {
            
            let microphone = AVCaptureDevice.default(AVCaptureDevice.DeviceType.microphone, for: AVMediaType.audio, position: .unspecified)
            
            do {
                try self.micInput = AVCaptureDeviceInput(device: microphone!);
                
                self.captureSession = AVCaptureSession();
                
                if (self.captureSession?.canAddInput(self.micInput!))! {
                    self.captureSession?.addInput(self.micInput!);
                    
                    self.audioOutput = AVCaptureAudioDataOutput();
                    
                    if self.captureSession!.canAddOutput(self.audioOutput!){
                        self.captureSession!.addOutput(self.audioOutput!)
                   
                        self.audioOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.global());
                        DispatchQueue.global(qos: .background).async {
                            self.captureSession?.startRunning();
                        }
                       
                        completionHandler(true);
                    }
                    
                }
            }
            catch {
                completionHandler(false);
            }
        }
        
        func endAudioRecording() { //completionHandler:@escaping()->()

            self.captureSession!.stopRunning();
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
           
            
            var count: CMItemCount = 0
            CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: 0, arrayToFill: nil, entriesNeededOut: &count);
            var info = [CMSampleTimingInfo](repeating: CMSampleTimingInfo(duration: CMTimeMake(value: 0, timescale: 0), presentationTimeStamp: CMTimeMake(value: 0, timescale: 0), decodeTimeStamp: CMTimeMake(value: 0, timescale: 0)), count: count)
            CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: count, arrayToFill: &info, entriesNeededOut: &count);
            
            let scale = CMTimeScale(NSEC_PER_SEC)
            var currentFrameTime:CMTime = CMTime(value: CMTimeValue((self.sceneView.session.currentFrame!.timestamp) * Double(scale)), timescale: scale);
            
            currentFrameTime = currentFrameTime-self.videoStartTime!;
            
            for i in 0..<count {
                info[i].decodeTimeStamp = currentFrameTime
                info[i].presentationTimeStamp = currentFrameTime
            }

            var soundbuffer:CMSampleBuffer?
            
            CMSampleBufferCreateCopyWithNewTiming(allocator: kCFAllocatorDefault, sampleBuffer: sampleBuffer, sampleTimingEntryCount: count, sampleTimingArray: &info, sampleBufferOut: &soundbuffer);
            

            self.audioInput?.append(soundbuffer!);
        }
    // MARK: Video RECORDING FUNCTIONALITY
    func startRecording() {
        let  videoURL = FileSystemServices.createURLForVideo()
       
        self.prepareWriterAndInput(size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), videoURL: videoURL!) { (error) in
                guard error == nil else{
                    return
                }
                self.startAudioRecording { (result) in
                    guard result == true else {
                                           print("FAILED TO START AUDIO SESSION")
                                           return
                                       }
                                   
                                       self.lastTime = 0;
                                       self.isRecording = true

                }
            }
       
        
    }
    public func didUpdateAtTime(time: TimeInterval) {
           
           if self.isRecording {
               if self.lastTime == 0 || (self.lastTime + 1/10) < time {
                   DispatchQueue.main.async { [weak self] () -> Void in
                       let scale = CMTimeScale(NSEC_PER_SEC)
                       var currentFrameTime:CMTime = CMTime(value: CMTimeValue((self?.sceneView.session.currentFrame!.timestamp)! * Double(scale)), timescale: scale)
                       if self?.lastTime == 0 {
                            self?.videoStartTime = currentFrameTime;
                         }
                       print("UPDATE AT TIME : \(time)");
                       guard self != nil else { return }
                       self!.lastTime = time
                       // VIDEO
                       let image = (self?.sceneView.snapshot())!
                       if self != nil, self!.firstImage == nil{
                           self!.firstImage = image
                       }
                       self?.createPixelBufferFromUIImage(image: image , completionHandler: { (error, pixelBuffer)  in
                           guard error == nil else {
                                                     print("failed to get pixelBuffer")
                                                     return
                                                 }
                           currentFrameTime = currentFrameTime - self!.videoStartTime!
                           // Add pixel buffer to video input
                        self!.pixelBufferAdaptor!.append(pixelBuffer!, withPresentationTime: currentFrameTime)
                       })
                       
                      
                      
                       
                   }
               }
           }
       }
    
 
        
    public func prepareWriterAndInput(size:CGSize, videoURL:URL, completionHandler:@escaping(Error?)->()) {
            
            do {
                self.assetWriter = try AVAssetWriter(outputURL: videoURL, fileType: AVFileType.mp4)
                
                // Input is the mic audio of the AVAudioEngine
                let audioOutputSettings = [
                    AVFormatIDKey : kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey : 2,
                    AVSampleRateKey : 44100.0,
                    AVEncoderBitRateKey: 192000
                    ] as [String : Any]
                
                self.audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings);
                self.audioInput!.expectsMediaDataInRealTime = true
                self.assetWriter?.add(self.audioInput!);
                
    
                let videoOutputSettings: Dictionary<String, Any> = [
                    AVVideoCodecKey : AVVideoCodecType.h264,
                    AVVideoWidthKey : size.width,
                    AVVideoHeightKey : size.height
                ];
                
                self.videoInput  = AVAssetWriterInput (mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
                self.videoInput!.expectsMediaDataInRealTime = true
                self.assetWriter!.add(self.videoInput!)
              
                let sourceBufferAttributes:[String : Any] = [
                    (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
                    (kCVPixelBufferWidthKey as String): Float(size.width),
                    (kCVPixelBufferHeightKey as String): Float(size.height)] as [String : Any]
                
                self.pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoInput!, sourcePixelBufferAttributes: sourceBufferAttributes);
        
                self.assetWriter?.startWriting();
                self.assetWriter?.startSession(atSourceTime: CMTime.zero);
                completionHandler(nil);
            }
            catch {
                print("Failed to create assetWritter with error : \(error)");
                completionHandler(error);
            }
        }
       
        
     
        private func createPixelBufferFromUIImage(image:UIImage, completionHandler:@escaping(String?, CVPixelBuffer?) -> ()) {
            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
            var pixelBuffer : CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
            guard (status == kCVReturnSuccess) else {
                completionHandler("Failed to create pixel buffer", nil)
                return
            }
            
            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
            
            context?.translateBy(x: 0, y: image.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            UIGraphicsPushContext(context!)
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
            completionHandler(nil, pixelBuffer)
        }
  
        
        private func finishVideoRecordingAndSave() {
            self.videoInput!.markAsFinished();
            self.assetWriter?.finishWriting(completionHandler: {
                print("output url : \(self.assetWriter?.outputURL)")
                
                if let url = self.assetWriter?.outputURL{
                    DispatchQueue.main.async {
                        let frontImageIndex = FileSystemServices.createURLForImage(image: self.firstImage!)
                        let videoIndex = FileSystemServices.getIndexForVideo(url: self.assetWriter!.outputURL)
                     
                    let duration = MediaServices.getVideoDuration(url: url)
                   
                    let alertController = UIAlertController(title: "Video Tag", message: "Enter video tag", preferredStyle: .alert)
                           
                           //the confirm action taking the inputs
                           let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
                               
                               //getting the input values from user
                               let name = alertController.textFields?[0].text
                               if name != nil, name != ""{
                                   
                                   let video = Video(duration: duration, tag: name, video: videoIndex, frontImage: frontImageIndex )
                                   self.viewModel.saveVideo(video: video)
                               }
                               
                               
                           }
                           
                           
                           //adding textfields to our dialog box
                           alertController.addTextField { (textField) in
                               textField.placeholder = "Write video tag here ..."
                           }
                          
                           
                           //adding the action to dialogbox
                           alertController.addAction(confirmAction)
                         //  alertController.addAction(cancelAction)
                           
                   
                        //finally presenting the dialog box
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
               
               
            })
        }
    func stopRecording() {
        self.isRecording = false;
              self.endAudioRecording()
              self.finishVideoRecordingAndSave()
    }
    @IBAction func startVideoRecording(_ sender: UIButton) {
        startRecording()
   
        startButton!.isHidden = true
        stopButton!.isHidden = false
       
    }
   
    @IBAction func stopVideoRecording(_ sender: UIButton) {
        stopRecording()
        
       
        startButton!.isHidden = false
        stopButton!.isHidden = true
    }
   

   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(sceneView)
           
               NSLayoutConstraint.activate([
                   sceneView.topAnchor.constraint(equalTo: view.topAnchor),
                   sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                   sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
               ])
               view.subviews.forEach {
                   $0.translatesAutoresizingMaskIntoConstraints = false
               }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        sceneView.addGestureRecognizer(tap)
      
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(faceConfiguration)
        
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       sceneView.delegate = self
   startButton = UIButton()
        startButton!.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
        startButton!.addTarget(self, action: #selector(startVideoRecording), for: .touchUpInside)
        startButton!.translatesAutoresizingMaskIntoConstraints = false
 self.view.addSubview(startButton!)
      
        startButton!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        startButton!.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        startButton!.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startButton!.widthAnchor.constraint(equalToConstant: 50).isActive = true
        startButton!.isHidden = false
        startButton!.contentVerticalAlignment = .fill
        startButton!.contentHorizontalAlignment = .fill
        stopButton = UIButton()
        stopButton!.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
        stopButton!.addTarget(self, action: #selector(stopVideoRecording), for: .touchUpInside)
 
  
        stopButton!.translatesAutoresizingMaskIntoConstraints = false
   self.view.addSubview(stopButton!)
        stopButton!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        stopButton!.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        stopButton!.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stopButton!.widthAnchor.constraint(equalToConstant: 50).isActive = true
        stopButton!.contentVerticalAlignment = .fill
        stopButton!.contentHorizontalAlignment = .fill
        stopButton!.isHidden = true
        
        infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 21))
        infoLabel!.translatesAutoresizingMaskIntoConstraints = false
   self.view.addSubview(infoLabel!)
        infoLabel!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -85).isActive = true
        infoLabel!.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 65).isActive = true
        infoLabel!.heightAnchor.constraint(equalToConstant: 21).isActive = true
        infoLabel!.widthAnchor.constraint(equalToConstant: 250).isActive = true
       
        infoLabel!.textAlignment = .center
        infoLabel!.text = "Tap to moustache to change"
        infoLabel!.textColor = UIColor.white
        var x = 90
        self.view.addSubview(infoLabel!)
        
        UIView.animate(withDuration: 8, delay: 0.05 , usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.infoLabel!.transform = CGAffineTransform(translationX: CGFloat(x), y: 0)
            x += 1
           
        }, completion: {_ in
            print(x)
            self.infoLabel?.removeFromSuperview()
        })
       

         
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
      
        for (feature, indices) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? FaceNode
            
            let vertices = indices.map { anchor.geometry.vertices[$0] }
            
        
            child?.updatePosition(for: vertices)
            break
        }
    }
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, options: nil)
        if let result = results.first,
            let node = result.node as? FaceNode {
            node.next()
        }
    }
}
extension VideoRecordViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let device: MTLDevice!
        device = MTLCreateSystemDefaultDevice()
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return nil
        }
        let faceGeometry = ARSCNFaceGeometry(device: device)
       
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .fill
        node.geometry?.firstMaterial?.transparency = 0.0
        
       
        
        let noseNode = FaceNode(with: moustachOptions)
        noseNode.name = "mouthTopCenter"
    
        node.addChildNode(noseNode)
        
        updateFeatures(for: node, using: faceAnchor)
         
       return node
    }
    
    func renderer(
        _ renderer: SCNSceneRenderer,
        didUpdate node: SCNNode,
        for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
            }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        didUpdateAtTime(time: time)
    }
    
}

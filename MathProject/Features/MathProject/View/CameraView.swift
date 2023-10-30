//
//  CameraView.swift
//  MathProject
//
//  Created by Hakan ERDOĞMUŞ on 30.10.2023.
//

import UIKit
import SnapKit
import AVFoundation
import Vision
import FirebaseStorage

protocol CameraViewProtocol: AnyObject {
    func configureVC()
    func configureCaptureSession()
    func configureCamera()
    func labelButton()
    func photoView(image: UIImage?)
    func buttonRetake()
    func configureSendButton()
    func returnTextView(text: String)
}

class CameraView: UIViewController, AVCapturePhotoCaptureDelegate {
    private let cameraViewModel = CameraViewModel()
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var setting: AVCapturePhotoSettings!
    private var photoLabel: UIImageView!
    private var button: UIButton!
    private var retakeButton: UIButton!
    private var circleView: UIView!
    private var sendButton: UIButton!
    private var textLabel: UILabel!
    
    var photo: UIImage?
    var customFrame: CGRect = CGRect(x: 50, y: 100, width: 300, height: 100)
    var screenWidth: CGFloat?
    var screenHeight: CGFloat?
    var centerX: CGFloat?
    var centerY: CGFloat?
    var customFrameX: CGFloat?
    var customFrameY: CGFloat?
    var pathFrame: CGRect?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraViewModel.view = self
        cameraViewModel.viewDidLoad()
    }
}

extension CameraView: CameraViewProtocol {
    func configureVC() {
        view.backgroundColor = .systemBackground
    }
    //Enable Camera
    func configureCaptureSession() {
        captureSession = AVCaptureSession()
        photoOutput = AVCapturePhotoOutput()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            captureSession.addOutput(photoOutput)
        } catch {
            print("Error: \(error)")
            return
        }
    }
    // Camera configure
    func configureCamera() {
        // Ekranın merkez noktasını hesaplayın
        screenWidth = view.bounds.size.width
        screenHeight = view.bounds.size.height
        centerX = screenWidth! / 2
        centerY = screenHeight! / 2

        // Özel çerçevenin ortalamasını hesaplayın
        customFrameX = centerX! - (customFrame.size.width / 2)
        customFrameY = centerY! - (customFrame.size.height / 2)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        //videoPreviewLayer.borderColor = UIColor.yellow.cgColor
       // videoPreviewLayer.borderWidth = 2
        videoPreviewLayer.frame = view.bounds
        //videoPreviewLayer.frame = CGRect(x: customFrameX , y: customFrameY, width: customFrame.size.width, height: customFrame.size.height)
        view.layer.addSublayer(videoPreviewLayer)
        //Start Camera
       // captureSession.startRunning()
        
        let transparentLayer = CALayer()
        transparentLayer.frame = view.bounds
        transparentLayer.backgroundColor = UIColor(white: 0.5, alpha: 0.8).cgColor
        view.layer.addSublayer(transparentLayer)
        
        let maskLayer = CAShapeLayer()
        pathFrame = CGRect(x: customFrameX!, y: customFrameY!, width: customFrame.size.width, height: customFrame.size.height)
        let path = UIBezierPath(rect: pathFrame!)
        path.append(UIBezierPath(rect: view.bounds))
        maskLayer.borderColor = UIColor.yellow.cgColor
        maskLayer.borderWidth = 2
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        transparentLayer.mask = maskLayer
    }
    //Photo
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData) {
                if let cropToBounds = cropToBounds(image: image, width: 0.0, height: 0.0) {
                    let correctedImage = correctImageOrientation(cropToBounds)
                    self.photo = correctedImage
                    photoView(image: self.photo)
                    buttonRetake()
                    configureSendButton()
                    button.isHidden = true
                    circleView.isHidden = true
                    captureSession.stopRunning()
                    //FireBase fotoğraf kaydetme
                    addStorgePhoto()
                }
            }
        }
    }
    //Added Storage Photo
    func addStorgePhoto() {
        let storage = Storage.storage()
        let storageRefferance = storage.reference()
        let mediaFolder = storageRefferance.child("Image")
        
        if let data = photoLabel.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageRefferance = mediaFolder.child("\(uuid).jpeg")
            imageRefferance.putData(data) { metadata, error in
                if error != nil {
                    print(error?.localizedDescription ?? "Error")
                } else {
                    imageRefferance.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            print(imageUrl)
                        }
                    }
                }
            }
        }
    }
    //Photo Cropped
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage? {

        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)

        let contextSize: CGSize = contextImage.size

        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
    //Photo Cropped
//    func cropImage(image: UIImage, rect: CGRect) -> UIImage? {
//        print(customFrame)
//        let scale = image.scale
//        print("scale: \(scale)")
//        let x = rect.origin.x * scale
//        print("x: \(x)")
//        let y = rect.origin.y * scale
//        print("y: \(y)")
//        let width = rect.size.width * scale
//        print("width: \(width)")
//        let height = rect.size.height * scale
//        print("height: \(height)")
//
//        if let cgImage = image.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height)) {
//            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
//        }
//        return nil
//    }
    // Button Add View
    func labelButton() {
        //View config
        circleView = UIView()
        //circleView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        circleView.backgroundColor = .white
        circleView.layer.cornerRadius = 42
        circleView.clipsToBounds = true
        //Button config
        button = UIButton()
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        //Added Views
        view.addSubview(circleView)
        circleView.addSubview(button)
        //View constraints
        circleView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.bottom.equalTo(view.snp.bottom).offset(UIScreen.main.bounds.height * -0.1)
            make.centerX.equalToSuperview()
        }
        //Button constraints
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    @objc func tapButton() {
        print("Click")
        setting = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: setting, delegate: self)
        //retakeButton.isHidden = false
    }
    //Send Button
    func configureSendButton() {
        sendButton = UIButton()
        view.addSubview(sendButton)
        //retakeButton.backgroundColor = .yellow
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.red, for: .normal)
        sendButton.addTarget(self, action: #selector(sendButton1), for: .touchUpInside)
        sendButton.snp.makeConstraints { make in
           // make.width.height.equalTo(80)
            make.bottom.equalTo(view.snp.bottom).offset(UIScreen.main.bounds.height * -0.1)
            make.right.equalTo(view.snp.right).offset(-10)
        }
    }
    // OCR ImagiView -> Text convert
    @objc func sendButton1() {
        print("Send Photo")
        guard let selfPhoto = self.photo else { return }
        print(selfPhoto)
        guard let ciImage = CIImage(image: self.photo!) else { return }
        
        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            if let results = request.results as? [VNRecognizedTextObservation] {
                for observation in results {
                    if let topCandidate = observation.topCandidates(1).first {
                        
                        print("Tanınan metin: \(topCandidate.string)")
                       // self.returnTextView(text: topCandidate.string)
                    }
                }
            }
        }
        let textRecognitionRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try textRecognitionRequestHandler.perform([textRecognitionRequest])
        } catch {
            print("Tanıma Hatası: \(error)")
        }
    }
    //Convert text -> UILabel
    func returnTextView(text: String) {
        textLabel = UILabel()
        view.addSubview(textLabel)
        textLabel.backgroundColor = .red
        textLabel.text = text
        textLabel.numberOfLines = 0
        textLabel.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.center.equalToSuperview()
        }
    }

    //photo add view
    func photoView(image: UIImage?) {
        photoLabel = UIImageView()
        view.addSubview(photoLabel)
        photoLabel.image = UIImage(cgImage: (image?.cgImage!)!)
        photoLabel.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    func buttonRetake() {
        //retakeButton photoView Add
        retakeButton = UIButton()
        view.addSubview(retakeButton)
        //retakeButton.backgroundColor = .yellow
        retakeButton.setTitle("Cancel", for: .normal)
        retakeButton.setTitleColor(.red, for: .normal)
        retakeButton.addTarget(self, action: #selector(retakePhoto), for: .touchUpInside)
        retakeButton.snp.makeConstraints { make in
           // make.width.height.equalTo(80)
            make.bottom.equalTo(view.snp.bottom).offset(UIScreen.main.bounds.height * -0.1)
            make.left.equalTo(view.snp.left).offset(10)
        }
    }
    //Retake Button
    @objc func retakePhoto() {
        captureSession.startRunning()
        photoLabel.image = nil
        retakeButton.isHidden = true
        sendButton.isHidden = true
        button.isHidden = false
        circleView.isHidden = false
       // textLabel.text = ""
       // textLabel.isHidden = true
        print("Fotoğraf iptal")
    }
    //Image Orientation
    func correctImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        var transform: CGAffineTransform = .identity
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi/2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat.pi/2)
        default:
            break
        }
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        if let cgImage = image.cgImage, let colorSpace = cgImage.colorSpace, let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) {
            context.concatenate(transform)
            if image.imageOrientation == .left || image.imageOrientation == .leftMirrored || image.imageOrientation == .right || image.imageOrientation == .rightMirrored {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
            } else {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            }
            if let correctedImage = context.makeImage() {
                return UIImage(cgImage: correctedImage)
            }
        }
        return image
    }
}


//
//  PaymentCardScanner.swift
//  
//
//  Created by Ricardo Silva on 26/09/2022.
//

import Combine
import UIKit
import AVFoundation
import Vision

@objc open class PaymentCardScanner: UIViewController {
    enum Constants {
        static let rectOfInterestInset: CGFloat = 25
        static let viewFrameRatio: CGFloat = 12 / 18
        static let maskedAreaY: CGFloat = 100
        static let maskedAreaCornerRadius: CGFloat = 8
        static let guideImageInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let explainerLabelPadding: CGFloat = 25
        static let explainerLabelHeight: CGFloat = 22
        static let widgetViewTopPadding: CGFloat = 30
        static let widgetViewLeftRightPadding: CGFloat = 25
        static let widgetViewHeight: CGFloat = 100
        static let closeButtonSize = CGSize(width: 44, height: 44)
        static let timerInterval: TimeInterval = 5.0
        static let scanErrorThreshold: TimeInterval = 1.0
    }
    
     lazy var panLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
        label.textColor = .white
        label.backgroundColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.alpha = 1
        label.text = "panLabel"
        return label
    }()
    
     lazy var expiryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
        label.textColor = .white
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.alpha = 1
        label.text = "expiryLabel"
        return label
    }()
    
     lazy var nameOnCardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
        label.textColor = .white
         label.backgroundColor = .green
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.alpha = 1
        label.text = "nameOnCardLabel"
        return label
    }()

    private var session = AVCaptureSession()
    private var captureOutput: AVCaptureOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var previewView = UIView()
    private let schemeScanningQueue = DispatchQueue(label: "ScannerQueue")
    private var timer: Timer?
    private var ocrTimer: Timer?
    private let visionUtility = VisionUtility()
    private var paymentCardRectangleObservation: VNRectangleObservation?
    private var subscriptions = Set<AnyCancellable>()
    private var trackingRect: CAShapeLayer?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(previewView)
        
        view.addSubview(panLabel)
        view.addSubview(expiryLabel)
        view.addSubview(nameOnCardLabel)
        
        NSLayoutConstraint.activate([
            panLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panLabel.widthAnchor.constraint(equalToConstant: 200),
            panLabel.heightAnchor.constraint(equalToConstant: 50),
            expiryLabel.topAnchor.constraint(equalTo: panLabel.bottomAnchor),
            expiryLabel.centerXAnchor.constraint(equalTo: panLabel.centerXAnchor),
            nameOnCardLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            nameOnCardLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
        
        visionUtility.subject.sink { completion in
            switch completion {
            case .finished:
                DispatchQueue.main.async {
                    self.stopScanning()
                    self.nameOnCardLabel.text = self.visionUtility.paymentCard.nameOnCard ?? "Nothing"
                    self.nameOnCardLabel.alpha = 1
                }
            case .failure(let error):
                print("Received error: \(error)")
            }
        } receiveValue: { paymentCard in
            DispatchQueue.main.async {
                self.panLabel.text = paymentCard.fullPan ?? "Nothing"
                if paymentCard.fullPan != nil {
                    self.expiryLabel.text = paymentCard.formattedExpiryDate() ?? ""
                }
            }
        }
        .store(in: &subscriptions)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanning()
    }
    
    public func startScanning() {
        session.sessionPreset = .high
        guard let backCamera = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: backCamera) else { return }
        performCaptureChecksForDevice(backCamera)
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait

        previewView.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.frame = view.frame
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        
        if session.outputs.isEmpty {
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
        }
        
        guard let connection = videoOutput.connection(with: AVMediaType.video), connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait

        if !session.isRunning {
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.session.startRunning()
            }
        }
        captureOutput = videoOutput
    }
    
    private func stopScanning() {
        schemeScanningQueue.async { [weak self] in
            self?.session.stopRunning()
            guard let outputs = self?.session.outputs else { return }
            for output in outputs {
                self?.session.removeOutput(output)
            }
            self?.timer?.invalidate()
            self?.ocrTimer?.invalidate()
        }
    }
    
    private func performCaptureChecksForDevice(_ device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
        } catch let error {
            // TODO: Handle error
            print(error.localizedDescription)
        }

        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }

        if device.isSmoothAutoFocusSupported {
            device.isSmoothAutoFocusEnabled = true
        }

        device.isSubjectAreaChangeMonitoringEnabled = true

        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
        }

        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }

        if device.isLowLightBoostSupported {
            device.automaticallyEnablesLowLightBoostWhenAvailable = true
        }

        device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 10)
        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 10)
        device.unlockForConfiguration()
    }
}

extension PaymentCardScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("captureOutput called")
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if let paymentCardRectangleObservation = self.paymentCardRectangleObservation {
            DispatchQueue.main.async {
                self.visionUtility.recognizePaymentCard(frame: frame, rectangle: paymentCardRectangleObservation)
            }
        } else if let paymentCardRectangleObservation = self.visionUtility.detectPaymentCard(frame: frame) {
            self.paymentCardRectangleObservation = paymentCardRectangleObservation
        }
        
//        if let paymentCardRectangleObservation = self.paymentCardRectangleObservation {
//            if let trackedPaymentCardRectangle = self.visionUtility.trackPaymentCard(for: paymentCardRectangleObservation, in: frame) {
//                DispatchQueue.main.async {
//                    let paymentCardRectOnScreen = self.createRectangleDrawing(trackedPaymentCardRectangle)
//                    guard self.paymentCardIsFocused(paymentCardRectOnScreen) else {
//                        return
//                    }
//
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        self.visionUtility.recognizePaymentCard(frame: frame, rectangle: paymentCardRectangleObservation)
//                    }
//                }
//            } else {
//                self.paymentCardRectangleObservation = nil
//            }
//        }
    }
    
    private func paymentCardIsFocused(_ rect: CGRect) -> Bool {
        let inset = Constants.rectOfInterestInset
        let width = view.frame.size.width - (inset * 2)
//        let viewFrameRatio = Constants.viewFrameRatio
//        let height: CGFloat = floor(viewFrameRatio * width)
        
        let xPosMatched = rect.minX > Constants.rectOfInterestInset
        let yPosMatched = rect.minY < Constants.maskedAreaY
        let widthMatched = rect.width > (width - 60)
//        let heightMatched = rect.height > (height - 26)
        
        return xPosMatched && yPosMatched && widthMatched
    }
    
    private func createRectangleDrawing(_ rectangleObservation: VNRectangleObservation) -> CGRect {
        self.trackingRect?.removeFromSuperlayer()
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.view.frame.height)
        let scale = CGAffineTransform.identity.scaledBy(x: self.view.frame.width, y: self.view.frame.height)
        let rectOnScreen = rectangleObservation.boundingBox.applying(scale).applying(transform)
        let boundingBoxPath = CGPath(rect: rectOnScreen, transform: nil)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = boundingBoxPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.borderWidth = 5
        self.trackingRect = shapeLayer
        self.view.layer.addSublayer(shapeLayer)
        return rectOnScreen
    }
}

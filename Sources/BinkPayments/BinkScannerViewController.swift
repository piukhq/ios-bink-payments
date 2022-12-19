//
//  BinkScannerViewController.swift
//  binkapp
//
//  Created by Sean Williams on 06/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Combine
import UIKit
import AVFoundation
import Vision

public protocol BinkScannerViewControllerDelegate: AnyObject {
    func binkScannerViewControllerShouldEnterManually(_ viewController: BinkScannerViewController, completion: (() -> Void)?)
    func binkScannerViewController(_ viewController: BinkScannerViewController, didScan paymentCard: PaymentAccountCreateModel)
}

open class BinkScannerViewController: UIViewController, UINavigationControllerDelegate {
    enum Constants {
        static let rectOfInterestInset: CGFloat = 25
        static let viewFrameRatio: CGFloat = 12 / 18
        static let maskedAreaY: CGFloat = 150
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

    public weak var delegate: BinkScannerViewControllerDelegate?
    private var session = AVCaptureSession()
    private var captureOutput: AVCaptureOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var previewView = UIView()
    private let schemeScanningQueue = DispatchQueue(label: "com.bink.wallet.scanning.loyalty.scheme.queue")
    private var rectOfInterest = CGRect.zero
    private var timer: Timer?
    private var canPresentScanError = true
    private var shouldAllowScanning = true
    private var shouldPresentWidgetError = true
    private var visionUtility: VisionUtility!
    private var cancellable: AnyCancellable?
    
    private lazy var blurredView: UIVisualEffectView = {
        return UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    }()

    private lazy var guideImageView: UIImageView = {
        let image = UIImage(named: "scannerGuide", in: .module, with: nil)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        return imageView
    }()
    
    private lazy var panLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var expiryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var nameOnCardLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()

    private lazy var explainerLabel: UILabel = {
        let label = UILabel()
        label.text = "Hold card here, it will scan automatically"
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    private lazy var widgetView: BinkScannerWidgetView = {
        var widget = BinkScannerWidgetView()
        widget.addTarget(self, selector: #selector(enterManually))
        widget.translatesAutoresizingMaskIntoConstraints = false
        widget.backgroundColor = .secondarySystemBackground
        return widget
    }()
    

    private lazy var cancelButton: UIBarButtonItem = {
        let image = UIImage(named: "close", in: .module, with: nil)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(close))
        return button
    }()

    public init(themeConfig: BinkThemeConfiguration, visionUtility: VisionUtility) {
        self.visionUtility = visionUtility
        super.init(nibName: nil, bundle: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: themeConfig.backButtonTitle, style: .plain, target: nil, action: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
//        startScanning()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSubscribers()
        startScanning()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanning()
    }
    
    private func configureUI() {
        view.addSubview(previewView)

        // BLUR AND MASK
        blurredView.frame = view.frame
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.frame
        // Setup rect of interest
        let inset = Constants.rectOfInterestInset
        let width = view.frame.size.width - (inset * 2)
        let viewFrameRatio = Constants.viewFrameRatio
        let height: CGFloat = floor(viewFrameRatio * width)
        let maskedAreaFrame = CGRect(x: inset, y: Constants.maskedAreaY, width: width, height: height)
        rectOfInterest = maskedAreaFrame
        let maskedPath = UIBezierPath(roundedRect: rectOfInterest, cornerRadius: Constants.maskedAreaCornerRadius)
        maskedPath.append(UIBezierPath(rect: view.bounds))
        maskLayer.fillRule = .evenOdd
        maskLayer.path = maskedPath.cgPath
        blurredView.layer.mask = maskLayer
        view.addSubview(blurredView)

        guideImageView.frame = rectOfInterest.inset(by: Constants.guideImageInset)
        view.addSubview(guideImageView)
        view.addSubview(explainerLabel)
        view.addSubview(widgetView)
        view.addSubview(panLabel)
        view.addSubview(expiryLabel)
        view.addSubview(nameOnCardLabel)
        navigationItem.rightBarButtonItem = cancelButton
        
        NSLayoutConstraint.activate([
            explainerLabel.topAnchor.constraint(equalTo: guideImageView.bottomAnchor, constant: Constants.explainerLabelPadding),
            explainerLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.explainerLabelPadding),
            explainerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.explainerLabelPadding),
            explainerLabel.heightAnchor.constraint(equalToConstant: Constants.explainerLabelHeight),
            widgetView.topAnchor.constraint(equalTo: explainerLabel.bottomAnchor, constant: Constants.widgetViewTopPadding),
            widgetView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.widgetViewLeftRightPadding),
            widgetView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.widgetViewLeftRightPadding),
            widgetView.heightAnchor.constraint(equalToConstant: Constants.widgetViewHeight),
            panLabel.centerXAnchor.constraint(equalTo: guideImageView.centerXAnchor),
            panLabel.centerYAnchor.constraint(equalTo: guideImageView.centerYAnchor, constant: 20),
            expiryLabel.topAnchor.constraint(equalTo: panLabel.bottomAnchor),
            expiryLabel.centerXAnchor.constraint(equalTo: panLabel.centerXAnchor),
            nameOnCardLabel.leadingAnchor.constraint(equalTo: guideImageView.leadingAnchor, constant: 25),
            nameOnCardLabel.bottomAnchor.constraint(equalTo: guideImageView.bottomAnchor, constant: -10)
        ])
    }
    
    private func startScanning() {
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
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue")) /// Change to global variable queue?
        
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
        scheduleTimer()
    }

    private func stopScanning() {
        schemeScanningQueue.async { [weak self] in
            self?.session.stopRunning()
            guard let outputs = self?.session.outputs else { return }
            for output in outputs {
                self?.session.removeOutput(output)
            }
            self?.timer?.invalidate()
        }
    }
    
    private func scheduleTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            if self.shouldPresentWidgetError {
                self.widgetView.timeout()
                self.shouldPresentWidgetError = false
            }
        })
    }

    private func performCaptureChecksForDevice(_ device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
        } catch {
            // TODO: Handle error
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
    
    private func configureSubscribers() {
        visionUtility = VisionUtility()

        cancellable = visionUtility.subject.sink { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .finished:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                        self.stopScanning()
                        self.nameOnCardLabel.text = self.visionUtility.paymentCard.nameOnCard ?? ""
                        self.nameOnCardLabel.alpha = 1
                        self.guideImageView.layer.addBinkAnimation(.shake)
                    } completion: { _ in
                        HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            guard self.visionUtility.pan != nil else { return }
                            self.delegate?.binkScannerViewController(self, didScan: self.visionUtility.paymentCard)
                            self.nameOnCardLabel.text = ""
                            self.panLabel.text = ""
                            self.expiryLabel.text = ""
                            self.cancellable = nil
                        }
                    }
                }
            case .failure(let error):
                print("Received error: \(error)")
            }
        } receiveValue: { [weak self] paymentCard in
            DispatchQueue.main.async {
                self?.panLabel.text = paymentCard.fullPan
                if paymentCard.fullPan != nil {
                    self?.expiryLabel.text = paymentCard.formattedExpiryDate() ?? ""
                }
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                    self?.panLabel.alpha = 1
                    if let _ = paymentCard.formattedExpiryDate() {
                        self?.expiryLabel.alpha = 1
                    }
                }
            }
        }
    }
    
    @objc private func enterManually() {
        delegate?.binkScannerViewControllerShouldEnterManually(self, completion: { [weak self] in
            guard let self = self else { return }
            self.navigationController?.removeViewController(self)
        })
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
}


// MARK: - AV Delegate

extension BinkScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let croppedImage = cropImage(imageBuffer: imageBuffer) else { return }
        self.visionUtility.recognizePaymentCard(in: croppedImage)
    }
    
    private func cropImage(imageBuffer: CVImageBuffer) -> CIImage? {
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        guard let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer) else { return nil }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let scale = 3.0
        let cropWidth = Int(rectOfInterest.width * scale)
        let cropHeight = Int(rectOfInterest.height * scale)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Calculate start position
        let bytesPerPixel = 4
        let startPointX = Int(rectOfInterest.minX)
        let startPointY = Int(rectOfInterest.minY)
        let startAddress = baseAddress + startPointY * bytesPerRow + startPointX * bytesPerPixel
        let context = CGContext(data: startAddress, width: cropWidth, height: cropHeight, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        
        if let cgImage = context?.makeImage() {
            return CIImage(cgImage: cgImage)
        }
        return nil
    }
}

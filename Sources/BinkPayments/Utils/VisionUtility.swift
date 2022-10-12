//
//  VisionImageDetectionUtility.swift
//  binkapp
//
//  Created by Sean Williams on 22/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Combine
import UIKit
import Vision

public class VisionUtility: ObservableObject {
    private let requestHandler = VNSequenceRequestHandler()
    private var timer: Timer?

    // MARK: - Payment Card
    var pan: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    var name: String?
    
    public init() {}
    
    var paymentCard: PaymentCardCreateModel {
        return PaymentCardCreateModel(fullPan: pan, nameOnCard: name, month: expiryMonth, year: expiryYear)
    }
    
    var ocrComplete: Bool {
        return pan != nil && expiryMonth != nil && expiryYear != nil && name != nil
    }
    
    let subject = PassthroughSubject<PaymentCardCreateModel, Error>()
    
    func recognizePaymentCard(frame: CVImageBuffer, rectangle: VNRectangleObservation) {
        performTextRecognition(frame: frame, rectangle: rectangle) { [weak self] observations in
            guard let observations = observations else { return }
            guard let self = self else { return }
            let recognizedTexts = observations.compactMap { observation in
                return observation.topCandidates(1).first
            }
            
            if pan == nil, let validatedPanText = recognizedTexts.first(where: { PaymentCardType.validate(fullPan: $0.string) }) {
                self.pan = validatedPanText.string
                self.scheduleTimer()
                self.subject.send(PaymentCardCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear))
            }
            
            if expiryMonth == nil || expiryYear == nil, let (month, year) = self.extractExpiryDate(observations: observations) {
                self.expiryMonth = Int(month)
                self.expiryYear = Int("20\(year)")
                self.subject.send(PaymentCardCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear))
            }
            
            for text in recognizedTexts {
                if text.confidence == 1, let name = self.likelyName(text: text.string) {
                    self.name = name
                    self.subject.send(PaymentCardCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear))
                }
            }
            
            if ocrComplete {
                self.subject.send(completion: .finished)
            }
        }
    }
    
    public func performPaymentCardOCR(frame: CVImageBuffer) {
        let rectangleDetectionRequest = VNDetectRectanglesRequest()
        let paymentCardAspectRatio: Float = 85.60 / 53.98
        rectangleDetectionRequest.minimumAspectRatio = paymentCardAspectRatio * 0.95
        rectangleDetectionRequest.maximumAspectRatio = paymentCardAspectRatio * 1.10
        let textDetectionRequest = VNDetectTextRectanglesRequest()
        
        try? self.requestHandler.perform([rectangleDetectionRequest, textDetectionRequest], on: frame)
        
        guard let rectangle = (rectangleDetectionRequest.results)?.first, let text = (textDetectionRequest.results)?.first, rectangle.boundingBox.contains(text.boundingBox) else { return }
        
        recognizePaymentCard(frame: frame, rectangle: rectangle)
    }
    
    private func scheduleTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.subject.send(completion: .finished)
        }
    }
    
    private func performTextRecognition(frame: CVImageBuffer, rectangle: VNRectangleObservation, completion: ([VNRecognizedTextObservation]?) -> Void) {
        let cardPositionInImage = VNImageRectForNormalizedRect(rectangle.boundingBox, CVPixelBufferGetWidth(frame), CVPixelBufferGetHeight(frame))
        let ciImage = CIImage(cvImageBuffer: frame)
        let croppedImage = ciImage.cropped(to: cardPositionInImage)
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
        try? stillImageRequestHandler.perform([request])
        
        guard let observations = request.results, !observations.isEmpty else {
            /// No text detected
            completion(nil)
            return
        }
        
        completion(observations)
    }
    
    private func extractExpiryDate(observations: [VNRecognizedTextObservation]) -> (String, String)? {
        for text in observations.flatMap({ $0.topCandidates(1) }) {
            if text.confidence == 1, let expiry = likelyExpiry(text.string) {
                guard let expiryMonth = Int(expiry.0) else { return nil }
                guard let expiryYear = Int("20" + expiry.1) else { return nil }
                guard let date = Date.makeDate(year: expiryYear, month: expiryMonth, day: 01, hr: 12, min: 00, sec: 00) else { return nil }

                if date.monthHasNotExpired {
                    return expiry
                } else {
                    return nil
                }
            }
        }
        return nil
    }

    private func likelyName(text: String) -> String? {
        let words = text.split(separator: " ").map { String($0) }
        let validWords = words.filter { !PaymentCardNameRecognition.nonNameWordMatch($0) && PaymentCardNameRecognition.onlyLettersAndSpaces($0) }
        let validWordCount = validWords.count >= 2
        return validWordCount ? validWords.joined(separator: " ") : nil
    }
    
    private func likelyExpiry(_ string: String) -> (String, String)? {
        guard let regex = try? NSRegularExpression(pattern: "^.*(0[1-9]|1[0-2])[./]([1-2][0-9])$") else {
            return nil
        }
        
        let result = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
        guard !result.isEmpty else { return nil }
        guard let nsrange1 = result.first?.range(at: 1), let range1 = Range(nsrange1, in: string) else { return nil }
        guard let nsrange2 = result.first?.range(at: 2), let range2 = Range(nsrange2, in: string) else { return nil }
        return (String(string[range1]), String(string[range2]))
    }
}



public class PaymentCardCreateModel: Codable {
    public var fullPan: String?
    var nameOnCard: String?
    var month: Int?
    var year: Int?
    var cardType: PaymentCardType?
    var uuid = UUID().uuidString
    
    public init(fullPan: String?, nameOnCard: String?, month: Int?, year: Int?) {
        self.fullPan = fullPan
        self.nameOnCard = nameOnCard
        self.month = month
        self.year = year
        
        if let fullPan = fullPan {
            setType(with: fullPan)
            formattFullPanIfNecessary()
        }
    }
    
    func setType(with pan: String) {
        self.cardType = PaymentCardType.type(from: pan)
    }
    
    public func formattedExpiryDate() -> String? {
        guard let month = month, let year = year else { return nil }
        return "\(month)/\(year)"
    }
    
    private func formattFullPanIfNecessary() {
        /// If we have scanned a card, we will have a fullPan available
        /// This pan should not contain any spaces, but guard against it anyway
        if fullPan?.contains(" ") == false {
            /// Using the indexes given a card type, insert a whitespace character at each index in the array
            if var formattedFullPan = fullPan, let whitespaceIndexes = cardType?.lengthRange().whitespaceIndexes {
                whitespaceIndexes.forEach { index in
                    formattedFullPan.insert(" ", at: formattedFullPan.index(formattedFullPan.startIndex, offsetBy: index))
                }
                
                /// Set the full pan to our newly formatted pan which includes whitespace
                fullPan = formattedFullPan
            }
        }
    }
}

enum PaymentCardType: String, Codable {
    case visa = "Visa"
    case amex = "American Express"
    case mastercard = "Mastercard"

    var redactedPrefix: String {
        return "••••   ••••   ••••   "
    }

    var logoName: String {
        switch self {
        case .amex:
            return "cardPaymentLogoAmEx"
        case .mastercard:
            return "cardPaymentLogoMastercard"
        case .visa:
            return "cardPaymentLogoVisa"
        }
    }

    var sublogoName: String {
        switch self {
        case .amex:
            return "cardPaymentSublogoAmEx"
        case .mastercard:
            return "cardPaymentSublogoMasterCard"
        case .visa:
            return "cardPaymentSublogoVisa"
        }
    }
    
    var paymentSchemeIdentifier: Int {
        switch self {
        case .amex:
            return 2
        case .mastercard:
            return 1
        case .visa:
            return 0
        }
    }
    
    static let allValues: [PaymentCardType] = [.amex, .mastercard, .visa]
    
    private var formatValues: FormatValues {
        let prefix: [PrefixContainable], length: Int, whitespaceIndexLocations: [Int]
        
        switch self {
            /* // IIN prefixes and length requriements retreived from https://en.wikipedia.org/wiki/Bank_card_number on Sep 15, 2019 */
        case .amex:
            prefix = ["34", "37"]
            length = 15
            whitespaceIndexLocations = [4, 11]
        case .mastercard:
            prefix = ["51"..."55", "2221"..."2720"]
            length = 16
            whitespaceIndexLocations = [4, 9, 14]
        case .visa:
            prefix = ["4"]
            length = 16
            whitespaceIndexLocations = [4, 9, 14]
        }

        return FormatValues(prefixes: prefix, length: length, whitespaceIndexLocations: whitespaceIndexLocations)
    }
    
    static func type(from fullPan: String?) -> PaymentCardType? {
        guard let fullPan = fullPan, !fullPan.isEmpty,
            let card = PaymentCardType.allValues.first(where: { $0.prefixValid(fullPan) }) else {
            return nil
        }

        return card
    }
    
    static func validate(fullPan: String?) -> Bool {
        guard let fullPan = fullPan?.replacingOccurrences(of: " ", with: ""), !fullPan.isEmpty,
            let _ = PaymentCardType.allValues.first(where: { $0.fullyValidate(fullPan) }) else {
                return false
        }
        
        return true
    }
    
    func fullyValidate(_ fullPan: String) -> Bool {
        return formatValues.isValid(fullPan)
    }
    
    func lengthRange() -> (length: Int, whitespaceIndexes: [Int]) {
        return (length: formatValues.length, whitespaceIndexes: formatValues.whitespaceIndexLocations)
    }
    
    private func prefixValid(_ fullPan: String) -> Bool {
        return formatValues.isPrefixValid(fullPan)
    }
}

fileprivate extension PaymentCardType {
    struct FormatValues {
        let prefixes: [PrefixContainable]
        let length: Int
        let whitespaceIndexLocations: [Int]
        
        func isValid(_ fullPan: String) -> Bool {
            return isLengthValid(fullPan) && isPrefixValid(fullPan) && luhnCheck(fullPan)
        }
        
        func isPrefixValid(_ fullPan: String) -> Bool {
            guard !prefixes.isEmpty else { return true }
            return prefixes.contains { $0.hasCommonPrefix(with: fullPan) }
        }
        
        func isLengthValid(_ fullPan: String) -> Bool {
            return fullPan.count == length
        }
    }
    
    // from: https://gist.github.com/cwagdev/635ce973e8e86da0403a
    static func luhnCheck(_ fullPan: String) -> Bool {
        var sum = 0
        let reversedCharacters = fullPan.reversed().map { String($0) }
        for (idx, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            switch ((idx % 2 == 1), digit) {
            case (true, 9): sum += 9
            case (true, 0...8): sum += (digit * 2) % 9
            default: sum += digit
            }
        }
        
        return sum % 10 == 0
    }
}

fileprivate protocol PrefixContainable {
    func hasCommonPrefix(with text: String) -> Bool
}

extension String: PrefixContainable {
    func hasCommonPrefix(with text: String) -> Bool {
        return hasPrefix(text) || text.hasPrefix(self)
    }
}

extension ClosedRange: PrefixContainable {
    func hasCommonPrefix(with text: String) -> Bool {
        // Cannot include Where clause in protocol conformance, so have to ensure Bound == String :(
        guard let lower = lowerBound as? String, let upper = upperBound as? String else { return false }
        
        let trimmedRange: ClosedRange<Substring> = {
            let length = text.count
            let trimmedStart = lower.prefix(length)
            let trimmedEnd = upper.prefix(length)
            return trimmedStart...trimmedEnd
        }()
        
        let trimmedText = text.prefix(trimmedRange.lowerBound.count)
        return trimmedRange ~= trimmedText
    }
}


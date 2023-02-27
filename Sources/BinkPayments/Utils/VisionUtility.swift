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

@available(iOS 13.0, *)
class VisionUtility {

    // MARK: - Payment Card
    var pan: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    var name: String?
    
    public init() {}
    
    var paymentCard: PaymentAccountCreateModel {
        return PaymentAccountCreateModel(fullPan: pan, nameOnCard: name, month: expiryMonth, year: expiryYear, cardNickname: nil)
    }
    
    var ocrComplete: Bool {
        return pan != nil && expiryMonth != nil && expiryYear != nil && name != nil
    }
    
    let subject = PassthroughSubject<PaymentAccountCreateModel, Error>()
    
    func recognizePaymentCard(in image: CIImage) {
        performTextRecognition(in: image) { [weak self] observations in
            guard let observations = observations else { return }
            guard let self = self else { return }
            let recognizedTexts = observations.compactMap { observation in
                return observation.topCandidates(1).first
            }
            
            if pan == nil, let validatedPanText = recognizedTexts.first(where: { PaymentCardType.validate(fullPan: $0.string) }) {
                self.pan = validatedPanText.string
                self.scheduleTimer()
                self.subject.send(PaymentAccountCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear, cardNickname: nil))
            }
            
            if expiryMonth == nil || expiryYear == nil, let (month, year) = self.extractExpiryDate(observations: observations) {
                self.expiryMonth = Int(month)
                self.expiryYear = Int("20\(year)")
                self.subject.send(PaymentAccountCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear, cardNickname: nil))
            }
            
            for text in recognizedTexts {
                if text.confidence == 1, let name = self.likelyName(text: text.string) {
                    self.name = name
                    self.subject.send(PaymentAccountCreateModel(fullPan: self.pan, nameOnCard: self.name, month: self.expiryMonth, year: self.expiryYear, cardNickname: nil))
                }
            }
            
            if ocrComplete {
                self.subject.send(completion: .finished)
            }
        }
    }
    
    func reset() {
        pan = nil
        expiryYear = nil
        expiryMonth = nil
        name = nil
    }
    
    private func scheduleTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.subject.send(completion: .finished)
        }
    }
    
    private func performTextRecognition(in image: CIImage, completion: ([VNRecognizedTextObservation]?) -> Void) {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
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
            if text.confidence >= 0.5, let expiry = likelyExpiry(text.string) {
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

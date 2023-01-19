//
//  VoucherModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

public struct VoucherModel: Codable {
    public var apiId: Int?
    public let state: VoucherState?
    public let earnType: String?
    public let rewardText: String?
    public let headline: String?
    public let voucherCode: String?
    public let barcodeType: Int?
    public let progressDisplayText: String?
    public let bodyText: String?
    public let termsAndConditions: String?
    public let issuedDate, expiryDate: Int?
    public let redeemedDate: Int?

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case state
        case earnType = "earn_type"
        case rewardText = "reward_text"
        case headline
        case voucherCode = "voucher_code"
        case barcodeType = "barcode_type"
        case progressDisplayText = "progress_display_text"
        case bodyText = "body_text"
        case termsAndConditions = "terms_and_conditions"
        case issuedDate = "issued_date"
        case expiryDate = "expiry_date"
        case redeemedDate = "redeemed_date"
    }
}


public enum VoucherState: String, Codable {
    case redeemed
    case issued
    case inProgress = "inprogress"
    case expired
    case cancelled

    public var sort: Int {
        switch self {
        case .issued:
            return 0
        case .inProgress:
            return 1
        case .redeemed, .expired, .cancelled:
            return 2
        }
    }
}

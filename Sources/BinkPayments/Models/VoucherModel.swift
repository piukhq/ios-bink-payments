//
//  VoucherModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

struct VoucherModel: Codable {
    var apiId: Int?
    let state: VoucherState?
    let earnType: String?
    let rewardText: String?
    let headline: String?
    let voucherCode: String?
    let barcodeType: Int?
    let progressDisplayText: String?
    let bodyText: String?
    let termsAndConditions: String?
    let issuedDate, expiryDate: Int?
    let redeemedDate: Int?

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


enum VoucherState: String, Codable {
    case redeemed
    case issued
    case inProgress = "inprogress"
    case expired
    case cancelled

    var sort: Int {
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

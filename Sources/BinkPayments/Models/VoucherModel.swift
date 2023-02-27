//
//  VoucherModel.swift
//  LocalHero
//
//  Created by Sean Williams on 05/04/2022.
//

import Foundation

/// Represents a voucher  associated with the Loyalty Card.
public struct VoucherModel: Codable {
    /// Resource Id
    public var apiId: Int?
    
    /// The Voucher's current state, one of:
    /// inprogress
    /// pending
    /// issued
    /// redeemed
    /// expired
    /// cancelled
    public let state: VoucherState?
    
    /// Descriptive text for how Loyalty accrual is measured. E.g. Stamps, Accumulator, etc.
    public let earnType: String?
    
    /// Descriptive text for the voucher reward.
    public let rewardText: String?
    
    /// A string that describes this voucher's disposition in a readable way.
    public let headline: String?
    
    /// Unique identifier for the voucher as supplied by the merchant.
    public let voucherCode: String?
    
    /// 0 = Code128 (B or C),
    /// 1 = QR Code,
    /// 2 = AztecCode,
    /// 3 = Pdf417,
    /// 4 = EAN(13),
    /// 5 =Datamatrix,
    /// 6 = ITF(Interleaved 2 of 5),
    /// 7 = Code39,
    /// 9 = Barcode Not Supported
    public let barcodeType: Int?
    
    /// Describes the progress of loyalty accrual towards a reward.
    public let progressDisplayText: String?
    
    /// Additional explanatory text if required.
    public let bodyText: String?
    
    /// URL of terms and conditions for a voucher, if applicable.
    public let termsAndConditions: String?
    
    /// Date Voucher was issued.
    public let issuedDate: Int?
    
    /// Date Voucher will expire.
    public let expiryDate: Int?
    
    /// Date the pending reward converts to an issued, redeemable reward. 
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

/// Valid states a Voucher can be in
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

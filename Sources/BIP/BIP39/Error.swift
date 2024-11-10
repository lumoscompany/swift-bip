//
//  Created by Adam Stragner
//

import Essentials

// MARK: - BIP39.Error

public extension BIP39 {
    enum Error: Swift.Error {
        case invalidEntropyCount
        case invalidMnemonicaLength
        case invalidMnemonicaVocabulary
    }
}

// MARK: - BIP39.Error + LocalizedError

extension BIP39.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidEntropyCount: "Invalid entropy bytes length"
        case .invalidMnemonicaLength: "Unsupported mnemonica length"
        case .invalidMnemonicaVocabulary: "Invalid mnemonica words"
        }
    }
}

//
//  Created by Adam Stragner
//

extension StringProtocol {
    var base58EncodedString: String {
        [UInt8](utf8).base58EncodedString
    }

    var base58EncodedStringWithCheksum: String {
        [UInt8](utf8).base58EncodedStringWithCheksum
    }
}

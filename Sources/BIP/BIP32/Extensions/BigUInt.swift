//
//  Created by Adam Stragner
//

import BigInt

extension BigUInt {
    static let curveOrder: BigUInt = {
        let value = BigUInt(
            "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",
            radix: 16
        )

        guard let value
        else {
            fatalError("[BIP32.BigUInt]: Can't create `curveOrder`.")
        }

        return value
    }()
}

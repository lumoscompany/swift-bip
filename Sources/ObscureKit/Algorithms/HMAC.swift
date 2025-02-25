//
//  Created by Adam Stragner
//

import Essentials
import Crypto

public func hmac<H>(
    _ function: H.Type,
    bytes: any ContiguousBytes,
    key: any ContiguousBytes
) -> some ContiguousBytes where H: HashFunction {
    var hmac = HMAC<H>(key: SymmetricKey(data: key))
    hmac.update(data: Data(bytes.concreteBytes))
    return Data(hmac.finalize())
}

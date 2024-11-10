//
//  Created by Adam Stragner
//

import Essentials
import Crypto

public extension RangeReplaceableCollection where Element == Byte {
    var sha256: ByteCollection {
        SHA256.hash(data: Data(self)).concreteBytes
    }

    var sha512: ByteCollection {
        SHA512.hash(data: Data(self)).concreteBytes
    }
}

public extension RangeReplaceableCollection where Element == UInt8 {
    init?(base58EncodedString value: String) {
        guard let bytes = base58.decode(value)
        else {
            return nil
        }

        self.init(bytes)
    }

    var base58EncodedString: String {
        guard !isEmpty
        else {
            return ""
        }
        return base58.encode(Array(self))
    }

    init?(base58EncodedStringWithCheksum value: String) {
        guard var bytes = base58.decode(value), bytes.count >= 4
        else {
            return nil
        }

        let checksum = [UInt8](bytes[bytes.count - 4 ..< bytes.count])
        bytes = [UInt8](bytes[0 ..< bytes.count - 4])

        guard [UInt8](bytes.sha256.sha256[0 ..< 4]) == checksum
        else {
            return nil
        }

        self.init(bytes)
    }

    var base58EncodedStringWithCheksum: String {
        guard !isEmpty
        else {
            return ""
        }

        var bytes = self
        let checksum = [UInt8](bytes.sha256.sha256[0 ..< 4])

        bytes.append(contentsOf: checksum)
        return base58.encode(Array(bytes))
    }
}

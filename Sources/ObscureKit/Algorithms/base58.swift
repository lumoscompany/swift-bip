//
//  Created by Adam Stragner
//

import Essentials
import BigInt
import Crypto

// MARK: - base58

enum base58 {
    // MARK: Internal

    static func encode(_ contiguousBytes: any ContiguousBytes) -> String {
        var result: [UInt8] = []

        let bytes = contiguousBytes.concreteBytes
        var _bytes = BigUInt(Data(bytes))

        while _bytes > 0 {
            let (quotient, remainder) = _bytes.quotientAndRemainder(dividingBy: .base58Radix)
            result.insert(alphabet[Int(remainder)], at: 0)
            _bytes = quotient
        }

        let prefix = Array(bytes.prefix(while: {
            $0 == 0
        })).map({ _ in alphabet[0] })

        result.insert(contentsOf: prefix, at: 0)
        guard let string = String(bytes: result, encoding: .utf8)
        else {
            fatalError("Couldn't decode UTF8 string from bytes")
        }

        return string
    }

    static func decode(_ value: String) -> [UInt8]? {
        var result = BigUInt.base58Zero
        var i = BigUInt(1)

        let bytes = [UInt8](value.utf8)
        for char in bytes.reversed() {
            guard let index = alphabet.firstIndex(of: char)
            else {
                return nil
            }

            result += (i * BigUInt(index))
            i *= .base58Radix
        }

        return Array(bytes.prefix(while: {
            i in i == alphabet[0]
        })) + result.serialize()
    }

    // MARK: Fileprivate

    fileprivate static let checksuml = 4

    fileprivate static var alphabet: [UInt8] {
        [UInt8]("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".utf8)
    }
}

private extension BigUInt {
    static let base58Zero = BigUInt(0)
    static let base58Radix = BigUInt(base58.alphabet.count)
}

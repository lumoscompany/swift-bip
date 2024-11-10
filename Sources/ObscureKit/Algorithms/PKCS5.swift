//
//  Created by Adam Stragner
//

import Essentials
import Crypto

// MARK: - PKCS5

public enum PKCS5 {
    /// https://github.com/orlandos-nl/PBKDF2/blob/main/Sources/PBKDF2/PBKDF2.swift
    public struct PBKDF2<H> where H: HashFunction {
        // MARK: Lifecycle

        public init() {
            self.chunkSize = H.blockByteCount
            self.digestSize = H.Digest.byteCount
        }

        // MARK: Public

        public enum Error: Swift.Error {
            case invalidInput(String)
        }

        public func calculate(
            password: ByteCollection,
            salt: ByteCollection,
            iterations: Int32,
            derivedKeyLength: Int
        ) throws -> [UInt8] {
            try Error.invalidInput("You cannot hash an empty password").throwif(password.isEmpty)
            try Error.invalidInput("You cannot hash with an empty salt").throwif(salt.isEmpty)
            try Error.invalidInput("You must iterate in PBKDF2 at least once")
                .throwif(iterations == 0)
            try Error.invalidInput("Key length too long")
                .throwif(derivedKeyLength > Int(Int32.max) * chunkSize)

            let saltSize = salt.count
            var salt = salt + [0, 0, 0, 0]

            var password = password

            if password.count > chunkSize {
                password = Array(H.hash(data: password))
            }

            if password.count < chunkSize {
                password = password + [UInt8](repeating: 0, count: chunkSize - password.count)
            }

            var outerPadding = [UInt8](repeating: 0x5C, count: chunkSize)
            var innerPadding = [UInt8](repeating: 0x36, count: chunkSize)

            xor(&innerPadding, password, count: chunkSize)
            xor(&outerPadding, password, count: chunkSize)

            func authenticate(message: UnsafeRawBufferPointer) -> H.Digest {
                var hasher = H()
                hasher.update(data: innerPadding)
                hasher.update(data: message)

                let innerPaddingHash = hasher.finalize()

                hasher = H()
                hasher.update(data: outerPadding)

                innerPaddingHash.withUnsafeBytes({ bytes in
                    hasher.update(bufferPointer: bytes)
                })

                return hasher.finalize()
            }

            var output = [UInt8]()
            output.reserveCapacity(derivedKeyLength)

            func calculate(block: UInt32) {
                salt.withUnsafeMutableBytes({
                    $0.baseAddress!
                        .advanced(by: saltSize)
                        .assumingMemoryBound(to: UInt32.self)
                        .pointee = block.bigEndian
                })

                var ui: H.Digest = salt.withUnsafeBytes({ authenticate(message: $0) })
                var u1 = Array(ui)

                if iterations > 1 {
                    for _ in 1 ..< iterations {
                        ui = ui.withUnsafeBytes { buffer in
                            authenticate(message: buffer)
                        }
                        xor(&u1, ui, count: digestSize)
                    }
                }

                output.append(contentsOf: u1)
            }

            for block in 1 ... UInt32((derivedKeyLength + digestSize - 1) / digestSize) {
                calculate(block: block)
            }

            let extra = output.count &- derivedKeyLength
            if extra >= 0 {
                output.removeLast(extra)
            }

            return output
        }

        // MARK: Private

        private let chunkSize: Int
        private let digestSize: Int
    }
}

private func xor<D: Digest>(_ lhs: inout [UInt8], _ rhs: D, count: Int) {
    rhs.withUnsafeBytes({ rhs in
        precondition(lhs.count == rhs.count)
        var i = 0; while i < count {
            lhs[i] ^= rhs[i]
            i &+= 1
        }
    })
}

private func xor(_ lhs: inout [UInt8], _ rhs: [UInt8], count: Int) {
    precondition(lhs.count == rhs.count)
    var i = 0; while i < count {
        lhs[i] ^= rhs[i]
        i &+= 1
    }
}

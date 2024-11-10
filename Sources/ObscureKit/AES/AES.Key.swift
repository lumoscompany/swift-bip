//
//  Created by Adam Stragner
//

import Essentials
import Crypto

public extension AES {
    private static let KeyLength = 32

    struct Key {
        // MARK: Lifecycle

        /// - parameter rawValue: 32 bytes buffer (AES256)
        public init?(rawValue: Data) {
            guard rawValue.count == AES.KeyLength
            else {
                return nil
            }

            self.rawValue = .init(rawValue)
        }

        /// - parameter string: Any UTF8 string
        public init(string: String) {
            let data = [UInt8](string.utf8)
            let hash = try? PKCS5.PBKDF2<SHA512>().calculate(
                password: data.sha512,
                salt: ByteCollection("derived key encryption seed".utf8),
                iterations: 100_000,
                derivedKeyLength: AES.KeyLength
            )

            guard let hash
            else {
                fatalError("Couldn't derive password")
            }

            self.rawValue = .init(Data(hash.concreteBytes.sha256))
        }

        // MARK: Public

        public func perform<T>(with body: (Data) throws -> T) rethrows -> T {
            try rawValue.perform(with: body)
        }

        public func perform<T>(with body: (Data) async throws -> T) async rethrows -> T {
            try await rawValue.perform(with: body)
        }

        // MARK: Private

        /// - note: 32 bytes
        private let rawValue: SecureByteCollection
    }
}

// MARK: - AES.Key + Sendable

extension AES.Key: Sendable {}

// MARK: - AES.Key + Hashable

extension AES.Key: Hashable {}

// MARK: - AES.Key + CustomStringConvertible

extension AES.Key: CustomStringConvertible {
    public var description: String {
        "[AES.Key]"
    }
}

// MARK: - AES.Key + CustomDebugStringConvertible

extension AES.Key: CustomDebugStringConvertible {
    public var debugDescription: String {
        "[AES.Key]"
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: AES.Key) {
        appendInterpolation(value.description)
    }
}

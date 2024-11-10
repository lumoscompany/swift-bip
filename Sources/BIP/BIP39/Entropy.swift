//
//  Created by Adam Stragner
//

public extension BIP39 {
    struct Entropy {
        // MARK: Lifecycle

        public init(length: Mnemonica.Length) {
            self.init(count: length.entropyBytesCount)
        }

        public init(count: Int) {
            self.init(.srandom(count: count))
        }

        public init(_ bytes: [UInt8]) {
            self.count = bytes.count
            self.bytes = bytes
        }

        // MARK: Public

        public let count: Int
        public let bytes: [UInt8]
    }
}

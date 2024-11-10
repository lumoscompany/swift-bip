//
//  Created by Adam Stragner
//

import Essentials

#if canImport(Security)

import Security

private func RandomBytes(_ count: Int) -> ByteCollection {
    var bytes = [UInt8](repeating: 0, count: count)
    _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
    return bytes
}

#else

/// https://github.com/swiftlang/swift/blob/3707e49f9578fb828cb6a81442f20ba853a3fd31/stdlib/public/core/Random.swift#L134C27-L135C13
/// https://developer.apple.com/documentation/swift/systemrandomnumbergenerator
///
/// While the system generator is automatically seeded and thread-safe on every platform,
/// the cryptographic quality of the stream of random data produced by the generator may vary.
/// For more detail, see the documentation for the APIs used by each platform.
///
/// Apple platforms use arc4random_buf(3).
/// Linux platforms use getrandom(2) when available; otherwise, they read from /dev/urandom.
/// Windows uses BCryptGenRandom.
private func RandomBytes(_ count: Int) -> ByteCollection {
    var generator = SystemRandomNumberGenerator()
    var bytes = [UInt8](repeating: 0, count: count)
    for i in 0 ..< count { bytes[i] = .random(in: 0 ... .max, using: &generator) }
    return bytes
}

#endif

extension RangeReplaceableCollection where Element == UInt8 {
    static func srandom(count: Int) -> Self {
        Self(RandomBytes(count))
    }
}

//
//  Created by Adam Stragner
//

import Essentials
import ObscureKit
import BigInt
import Crypto

// MARK: - BIP32.ExtendedKey

public extension BIP32 {
    struct ExtendedKey {
        // MARK: Lifecycle

        private init(derivationPath: DerivationPath, keyPair: KeyPair) {
            self.derivationPath = derivationPath
            self.keyPair = keyPair
        }

        // MARK: Public

        public let derivationPath: DerivationPath
        public let keyPair: KeyPair
    }
}

// MARK: - BIP32.ExtendedKey + Equatable

extension BIP32.ExtendedKey: Equatable {}

// MARK: - BIP32.ExtendedKey + Sendable

extension BIP32.ExtendedKey: Sendable {}

public extension BIP32.ExtendedKey {
    init(_ digest: BIP39.Digest, _ derivationPath: BIP32.DerivationPath) {
        self.init(digest.seed, derivationPath)
    }

    init(_ seed: [UInt8], _ derivationPath: BIP32.DerivationPath) {
        var tuple = KeyPair.masterKeyPair(seed)
        derivationPath.indices.forEach({
            tuple = tuple.keyPair.next(with: $0, chain: tuple.chain)
        })

        self.init(
            derivationPath: derivationPath,
            keyPair: tuple.keyPair
        )
    }
}

extension BIP32.ExtendedKey.KeyPair {
    /// - note: Creates master `ExtendedKey.KeyPair` from `seed`
    static func masterKeyPair(
        _ seed: [UInt8]
    ) -> (keyPair: BIP32.ExtendedKey.KeyPair, chain: [UInt8]) {
        let privateKey = _master(from: seed)
        let publicKey: ByteCollection

        do {
            publicKey = try secp256k1.generatePublicKey(
                from: privateKey.key,
                compressed: true
            ).concreteBytes
        } catch {
            fatalError(error.localizedDescription)
        }

        let keyPair = BIP32.ExtendedKey.KeyPair(
            publicKey: .init(rawValue: publicKey),
            privateKey: .init(rawValue: privateKey.key)
        )

        return (keyPair, privateKey.chain)
    }

    func next(
        with index: BIP32.DerivationPath.KeyIndex,
        chain: [UInt8]
    ) -> (keyPair: BIP32.ExtendedKey.KeyPair, chain: ByteCollection) {
        var bytes: [UInt8] = []

        switch index {
        case .ordinary:
            bytes += [UInt8](publicKey.rawValue)
        case .hardened:
            bytes += [0x00]
            bytes += [UInt8](privateKey.rawValue)
        }

        bytes += index.rawValue.littleEndianBytes

        let derived = BIP32.ExtendedKey.KeyPair._key(from: bytes, key: chain)

        let currentFactor = BigUInt(Data(derived.key))
        let currentPrivateKey = BigUInt(Data(privateKey.rawValue))

        let privateKey = ((currentPrivateKey + currentFactor) % .curveOrder).serialize()
        let publicKey: ByteCollection

        do {
            publicKey = try secp256k1.generatePublicKey(
                from: privateKey,
                compressed: true
            ).concreteBytes
        } catch {
            fatalError(error.localizedDescription)
        }

        let keyPair = BIP32.ExtendedKey.KeyPair(
            publicKey: .init(rawValue: publicKey),
            privateKey: .init(rawValue: ByteCollection(privateKey))
        )

        return (keyPair, derived.chain)
    }

    /// The total number of possible extended keypairs is almost 2^512, but the
    /// produced keys are only 256 bits long, and offer about half of that in
    /// terms of security. Therefore, master keys are not generated directly, but instead from a
    /// potentially short seed value.
    ///
    /// 1. Generate a seed byte sequence S of a chosen length (between 128 and 512 bits; 256 bits is
    /// advised) from a (P)RNG.
    /// 2. Calculate I = HMAC-SHA512(Key = "Bitcoin seed", Data = S)
    /// 3. Split I into two 32-byte sequences, IL and IR.
    /// 4. Use parse256(IL) as master secret key, and IR as master chain code.
    ///
    /// - note: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#master-key-generation
    private static func _master(
        from seed: ByteCollection
    ) -> (key: ByteCollection, chain: ByteCollection) {
        _key(from: seed, key: [UInt8]("Bitcoin seed".utf8))
    }

    private static func _key(
        from value: ByteCollection,
        key: ByteCollection
    ) -> (key: ByteCollection, chain: ByteCollection) {
        let hash = hmac(SHA512.self, bytes: value, key: key).concreteBytes
        return (Array(hash[..<32]), Array(hash[32...]))
    }
}

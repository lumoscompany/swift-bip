//
//  Created by Adam Stragner
//

import Essentials

public extension Data {
    var sha256: Data {
        Data([UInt8](self).sha256)
    }

    var sha512: Data {
        Data([UInt8](self).sha512)
    }
}

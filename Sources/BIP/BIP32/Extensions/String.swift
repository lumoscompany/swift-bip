//
//  Created by Adam Stragner
//

extension String {
    var unescaped: String {
        replacingOccurrences(of: "\'", with: "`").replacingOccurrences(of: "'", with: "`")
    }
}

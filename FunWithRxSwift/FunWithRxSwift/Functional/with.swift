//
//  Created by Joachim Kret on 28/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

public func with<A>(_ a: A, _ f: (inout A) throws -> ()) rethrows -> A {
    var a = a
    try f(&a)
    return a
}

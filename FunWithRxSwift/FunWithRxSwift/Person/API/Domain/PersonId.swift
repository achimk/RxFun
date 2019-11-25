//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PersonId {
    let value: String
    
    init?(_ value: String) {
        guard value.count > 0 else { return nil }
        self.value = value
    }
}

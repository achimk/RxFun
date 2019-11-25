//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PersonListViewData {
    
    struct PersonViewData {
        
        typealias SelectHandler = () -> ()
        
        var name: String?
        var surname: String?
        var age: String?
        var selectHandler: SelectHandler?
    }
    
    var items: [PersonViewData]
}

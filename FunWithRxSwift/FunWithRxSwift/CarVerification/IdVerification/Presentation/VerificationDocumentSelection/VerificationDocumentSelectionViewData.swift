//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

struct VerificationDocumentSelectionViewData {
    
    enum ViewState {
        case empty
        case loading
        case success([Item])
        case failure(String)
    }

    struct Item {
        let name: String
        let selectHandler: () -> ()
    }

    let state: ViewState
}

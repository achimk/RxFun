//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

enum ViewState<Success, Failure> {
    case initial
    case loading
    case success(Success)
    case failure(Failure)
}

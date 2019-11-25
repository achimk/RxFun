//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

indirect enum ViewState<Success, Failure> {
    case initial
    case loading(previous: ViewState<Success, Failure>)
    case success(Success)
    case failure(Failure)
}

extension ViewState {
    
}

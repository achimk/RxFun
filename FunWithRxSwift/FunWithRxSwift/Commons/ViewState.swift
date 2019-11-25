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
    
    var isInitial: Bool {
        if case .initial = self { return true }
        else { return false }
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        else { return false }
    }
    
    var isSuccess: Bool {
        if case .success = self { return true }
        else { return false }
    }
    
    var isFailure: Bool {
        if case .failure = self { return true }
        else { return false }
    }
}

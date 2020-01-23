//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

indirect enum ViewState {
    case initial
    case loading(previous: ViewState)
    case success
    case failure
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
    
    func onInitial(_ action: () -> ()) {
        if case .initial = self { action() }
    }
    
    func onLoading(_ action: (Self) -> ()) {
        if case .loading(let previous) = self { action(previous) }
    }
    
    func onSuccess(_ action: () -> ()) {
        if case .success = self { action() }
    }
    
    func onFailure(_ action: () -> ()) {
        if case .failure = self { action() }
    }
}

extension ViewState: Equatable { }

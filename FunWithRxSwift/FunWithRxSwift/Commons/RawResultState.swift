//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

indirect enum RawResultState {
    case initial
    case loading(previous: RawResultState)
    case success
    case failure
}

extension RawResultState: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .initial: return "initial"
        case .loading: return "loading"
        case .success: return "success"
        case .failure: return "failure"
        }
    }
}

extension RawResultState: RawRepresentable {
    
    var rawValue: String { description }
    
    init?(rawValue: String) {
        switch rawValue {
        case "initial": self = .initial
        case "loading": self = .loading(previous: .initial)
        case "success": self = .success
        case "failure": self = .failure
        default: return nil
        }
    }
}

extension RawResultState {
    
    var previous: RawResultState? {
        if case .loading(let state) = self { return state }
        else { return nil }
    }
    
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

extension RawResultState: Equatable { }

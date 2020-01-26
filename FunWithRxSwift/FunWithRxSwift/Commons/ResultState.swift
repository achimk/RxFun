//
//  Created by Joachim Kret on 22/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation

indirect enum ResultState<Success, Failure> {
    case initial
    case loading(previous: ResultState<Success, Failure>)
    case success(Success)
    case failure(Failure)
}

extension ResultState {
    
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
    
    func onSuccess(_ action: (Success) -> ()) {
        if case .success(let value) = self { action(value) }
    }
    
    func onFailure(_ action: (Failure) -> ()) {
        if case .failure(let error) = self { action(error) }
    }
}

extension ResultState {
    
    var value: Success? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case .success(let value): return value
        case .failure: return nil
        }
    }
    
    var error: Failure? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case .success: return nil
        case .failure(let error): return error
        }
    }

    var lastValue: Success? {
        switch self {
        case .initial: return nil
        case .loading(let previous): return previous.lastValue
        case .success(let value): return value
        case .failure: return nil
        }
    }
    
    var lastError: Failure? {
        switch self {
        case .initial: return nil
        case .loading(let previous): return previous.lastError
        case .success: return nil
        case .failure(let error): return error
        }
    }
    
    var lastState: ResultState<Success, Failure> {
        switch self {
        case .initial: return self
        case .loading(let previous): return previous.lastState
        case .success: return self
        case .failure: return self
        }
    }
    
    var rawValue: RawResultState {
        switch self {
        case .initial: return .initial
        case .loading(let previous): return .loading(previous: previous.rawValue)
        case .success: return .success
        case .failure: return .failure
        }
    }
}

extension ResultState where Failure: Swift.Error {
    
    var result: Result<Success, Failure>? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case .success(let value): return .success(value)
        case .failure(let error): return .failure(error)
        }
    }
    
    var lastResult: Result<Success, Failure>? {
        switch self {
        case .initial: return nil
        case .loading(let previous): return previous.lastResult
        case .success(let value): return .success(value)
        case .failure(let error): return .failure(error)
        }
    }
}

extension ResultState: Equatable where Success: Equatable {
    
    static func ==(lhs: ResultState<Success, Failure>, rhs: ResultState<Success, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case let (.loading(l), .loading(r)): return l == r
        case let (.success(l), .success(r)): return l == r
        case (.failure, .failure): return true
        default: return false
        }
    }
}

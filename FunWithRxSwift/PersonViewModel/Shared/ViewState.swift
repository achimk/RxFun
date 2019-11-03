//
//  Created by Joachim Kret on 21/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

public enum ViewState<Success, Failure> {
    
    case empty
    
    case loading
    
    case completed(Success)
    
    case failed(Failure)
}

extension ViewState {
    
    public var value: Success? {
        if case .completed(let value) = self { return value }
        else { return nil }
    }
    
    public var error: Failure? {
        if case .failed(let error) = self { return error }
        else { return nil }
    }
}

extension ViewState {
    
    public var isEmpty: Bool {
        if case .empty = self { return true }
        else { return false }
    }
    
    public func ifEmpty(_ action: () -> ()) {
        if case .empty = self { action() }
    }
    
    public var isLoading: Bool {
        if case .loading = self { return true }
        else { return false }
    }
    
    public func ifLoading(_ action: () -> ()) {
        if case .loading = self { action() }
    }
    
    public var isCompleted: Bool {
        if case .completed = self { return true }
        else { return false }
    }
    
    public func ifCompleted(_ action: (Success) -> ()) {
        if case .completed(let success) = self { action(success) }
    }
    
    public var isFailed: Bool {
        if case .failed = self { return true }
        else { return false }
    }
    
    public func ifFailed(_ action: (Failure) -> ()) {
        if case .failed(let failure) = self { action(failure) }
    }
}

extension ViewState: Equatable where Success: Equatable, Failure: Equatable {
}

extension ViewState where Failure: Swift.Error {
    
    public func asResult(previousOnLoading: Bool = true) -> Result<Success, Failure>? {
        switch self {
        case .empty: return nil
        case .loading: return nil
        case .completed(let success): return .success(success)
        case .failed(let failure): return .failure(failure)
        }
    }
}


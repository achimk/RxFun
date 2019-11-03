//
//  Created by Joachim Kret on 21/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

public enum ViewState<Success, Failure: Swift.Error> {
    
    case empty
    
    case loading(previous: Result<Success, Failure>?)
    
    case completed(Success)
    
    case failed(Failure)
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
    
    public func ifLoading(_ action: (Result<Success, Failure>?) -> ()) {
        if case .loading(let result) = self { action(result) }
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

extension ViewState: Equatable {
    
    public static func == (lhs: ViewState<Success, Failure>, rhs: ViewState<Success, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty): return true
        case (.loading, .loading): return true
        case (.completed, .completed): return true
        case (.failed, .failed): return true
        default: return false
        }
    }   
}

extension ViewState {
    
    public func asResult(previousOnLoading: Bool = true) -> Result<Success, Failure>? {
        switch self {
        case .empty: return nil
        case .loading(let previous): return previousOnLoading ? previous : nil
        case .completed(let success): return .success(success)
        case .failed(let failure): return .failure(failure)
        }
    }
}

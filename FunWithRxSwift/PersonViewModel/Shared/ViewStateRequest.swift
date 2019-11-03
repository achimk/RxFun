//
//  Created by Joachim Kret on 03/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

public struct ViewStateRequest<Request, Success, Failure> {
    
    public typealias State = ViewState<Success, Failure>
    
    public let lastRequest: Request?
    public let lastValue: Success?
    public let lastError: Failure?
    public let state: State
    
    private init(
        lastRequest: Request?,
        lastValue: Success?,
        lastError: Failure?,
        state: State) {
        self.lastRequest = lastRequest
        self.lastValue = lastValue
        self.lastError = lastError
        self.state = state
    }
    
    public init(state: State = .empty) {
        self.lastRequest = nil
        self.lastValue = state.value
        self.lastError = state.error
        self.state = state
    }
    
    public func ifEmpty(_ action: () -> ()) {
        state.ifEmpty(action)
    }
    
    public func ifLoading(_ action: (Request) -> ()) {
        state.ifLoading {
            if let request = lastRequest { action(request) }
        }
    }
    
    public func ifCompleted(_ action: (Success) -> ()) {
        state.ifCompleted(action)
    }
    
    public func ifFailed(_ action: (Failure) -> ()) {
        state.ifFailed(action)
    }
    
    internal func toLoading(_ request: Request) -> ViewStateRequest<Request, Success, Failure> {
        return .init(lastRequest: request, lastValue: lastValue, lastError: lastError, state: .loading)
    }
    
    internal func toCompleted(_ value: Success) -> ViewStateRequest<Request, Success, Failure> {
        return .init(lastRequest: lastRequest, lastValue: value, lastError: lastError, state: .completed(value))
    }
    
    internal func toFailed(_ error: Failure) -> ViewStateRequest<Request, Success, Failure> {
        return .init(lastRequest: lastRequest, lastValue: lastValue, lastError: error, state: .failed(error))
    }
}

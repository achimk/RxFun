//
//  Created by Joachim Kret on 21/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonListTransformViewModel {
    
    struct Input {
        var refresh: Signal<Void> = .empty()
    }

    struct Output {
        var refresh: Driver<Void> = .empty()
        var inProgress: Driver<Bool> = .empty()
        var items: Driver<PersonListViewData> = .empty()
        var lastError: Driver<String?> = .empty()
    }
    
    let state: PersonListObservable
    let localizer: PersonListLocalizing
    let wireframe: (PersonListWireframe) -> ()
    
    func transform(_ input: Input) -> Output {
        
        let localizer = self.localizer
        var output = Output()
        
        let state = self.state.asObservable().share()
        
        output.inProgress = state
            .map { $0.isLoading }
            .asDriver(onErrorJustReturn: false)
        
        output.items = state
            .map(prepareViewDataFactory())
            .asDriver(onErrorDriveWith: .empty())
        
        output.lastError = state
            .flatMap { state -> Observable<String?> in
                if state.error != nil {
                    let message = localizer.localizedUnexpectedError
                    return Observable.concat(.just(message), .just(nil))
                } else {
                    return .just(nil)
                }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        output.refresh = input.refresh.do(onNext: self.state.refresh).asDriver(onErrorDriveWith: .empty())
        
        return output
    }
    
    private func prepareViewDataFactory() -> (PersonListObservable.State) -> PersonListViewData {
        let wireframe = self.wireframe
        return { state in
            return PersonListViewDataFactory(persons: state.items, wireframe: wireframe).create()
        }
    }
}

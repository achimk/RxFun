//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PersonDetailsViewModel {
    
    let state: PersonDetailsObservable
    let localizer: PersonDetailsLocalizing
    
    func transform(_ input: PersonDetailsInput) -> (DisposeBag) -> PersonDetailsOutput {
        
        let refresh = state.refresh
        let localizer = self.localizer
        var output = PersonDetailsOutput()
        
        output.inProgress = state
            .asObservable()
            .map { $0.isLoading }
            .asDriver(onErrorJustReturn: false)
        
        output.display = state
            .asObservable()
            .compactMap { state -> PersonDetailsOutput.DisplayViewModel? in
                switch state {
                case .initial:
                    return EmptyPersonDetailsViewModel().transform(_:)
                case .success(let data):
                    return DisplayPersonDetailsViewModel(details: data).transform(_:)
                case .loading:
                    return nil
                case .failure:
                    return nil
                }
            }
            .asDriver(onErrorDriveWith: .empty())
        
        output.lastError = state
            .asObservable()
            .compactMap { state in
                if case .failure = state { return localizer.localizedUnexpectedError }
                else { return nil }
            }
            .asDriver(onErrorDriveWith: .empty())

        return { bag in
            
            input.refresh.emit(onNext: refresh).disposed(by: bag)
            
            return output
        }
    }
}

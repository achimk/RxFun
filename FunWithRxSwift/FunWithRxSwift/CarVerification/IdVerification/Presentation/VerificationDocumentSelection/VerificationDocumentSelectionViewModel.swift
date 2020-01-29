//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct VerificationDocumentSelectionViewModel {
    
    struct Input {
        var refresh: Signal<Void>
    }
    
    struct Output {
        var viewData: Driver<VerificationDocumentSelectionViewData> = .empty()
    }
    
    let state: VerificationDocumentSelectionObservable
    
    func transform(_ input: Input) -> (DisposeBag) -> Output {
        let state = self.state
        var output = Output()
        output.viewData = state.asObservable()
            .map(prepareViewDataFactory())
            .asDriver(onErrorDriveWith: .empty())
        
        return { bag in
            input.refresh.emit(onNext: state.refresh).disposed(by: bag)
            return output
        }
    }
    
    private func prepareViewDataFactory() -> (ResultState<[VerificationDocumentType], Error>) -> VerificationDocumentSelectionViewData {
        let itemFactory = prepareViewDataItem()
        return { result in
            switch result {
            case .initial:
                return .init(state: .empty)
            case .loading:
                return .init(state: .loading)
            case .success(let types):
                let items = types.map(itemFactory)
                return .init(state: .success(items))
            case .failure:
                return .init(state: .failure("Unexpected error occurs!"))
            }
        }
    }
    
    private func prepareViewDataItem() -> (VerificationDocumentType) -> VerificationDocumentSelectionViewData.Item {
        return { type in
            switch type {
            case .id:
                return .init(name: "ID", selectHandler: { })
            case .drivingLicense:
                return .init(name: "Driving Licennce", selectHandler: { })
            case .passport:
                return .init(name: "Passport", selectHandler: { })
            }
        }
    }
}

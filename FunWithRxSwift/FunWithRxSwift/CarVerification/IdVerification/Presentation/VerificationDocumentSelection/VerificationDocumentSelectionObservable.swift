//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

final class VerificationDocumentSelectionObservable: ObservableConvertibleType {
    
    private let state: ResultStateObservable<Void, [VerificationDocumentType]>
    
    init(provider: @escaping () -> Single<[VerificationDocumentType]>) {
        state = .init(reducer: provider)
    }
    
    func refresh() {
        state.refresh()
    }
    
    func asObservable() -> Observable<ResultState<[VerificationDocumentType], Error>> {
        return state.asObservable()
    }
}

//
//  Created by Joachim Kret on 21/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct FetchInput {
    var refresh: Signal<Void> = .empty()
}

struct FetchOutput<R> {
    var inProgress: Driver<Bool> = .empty()
    var result: Driver<R> = .empty()
}

struct FetchViewModel<T, R> {

    let provider: () -> Single<T>
    let mapper: (T) -> R
    let progressIndicator = ActivityIndicator()
    
    func transform(_ input: FetchInput) -> FetchOutput<R> {
        
        let provider = self.provider
        let progress = progressIndicator
        
        var output = FetchOutput<R>()
        output.inProgress = progress.asDriver()
        output.result = Observable.merge(
            Observable<Void>.just(()),
            input.refresh.asObservable())
            .withLatestFrom(progress)
            .filter { $0 == false }
            .flatMapLatest { _ in provider().trackActivity(progress) }
            .map(mapper)
            .asDriver(onErrorDriveWith: .never())

        return output
    }
}

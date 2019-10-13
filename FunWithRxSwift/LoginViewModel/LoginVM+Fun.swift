//
//  Created by Joachim Kret on 13/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct LoginViewModelInput {
    var username: Observable<String?>
    var password: Observable<String?>
    var login: Observable<Void>
}

struct LoginViewModelOutput {
    var inProgress: Driver<Bool>
    var success: Driver<String>
    var failure: Driver<Swift.Error>
}

func loginViewModel(api: AuthenticationAPI) -> (LoginViewModelInput) -> LoginViewModelOutput {
    return { input in
        
        let errorTracker = ErrorTracker()
        let activityTracker = ActivityIndicator()
        let authenticate = prepareAuthenticate(api: api, errorTracker: errorTracker, activityTracker: activityTracker)
        
        let progress = activityTracker.asDriver()
        
        let success = Observable.combineLatest(input.username, input.password)
            .flatMap { (username, password) in
                input.login.map { (username, password) }
            }
            .flatMap(authenticate)
            .asDriver(onErrorDriveWith: .never())
        
        let failure = errorTracker.asDriver(onErrorDriveWith: .never())
        
        return LoginViewModelOutput(
            inProgress: progress,
            success: success,
            failure: failure)
    }
}

private func prepareAuthenticate(
    api: AuthenticationAPI,
    errorTracker: ErrorTracker,
    activityTracker: ActivityIndicator) -> (_ username: String?, _ password: String?) -> Single<String> {
    return { (username, password) in
        return api
            .authenticate(username: username, password: password)
            .trackError(errorTracker)
            .trackActivity(activityTracker)
            .asSingle()
            .map { _ in "Login success!" }
            
    }
}

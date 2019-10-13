//
//  Created by Joachim Kret on 13/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginViewModelType {
    
    // Input
    var username: BehaviorRelay<String?> { get }
    var password: BehaviorRelay<String?> { get }
    var login: PublishRelay<Void> { get }
    
    // Output
    var inProgress: BehaviorRelay<Bool> { get }
    var success: PublishRelay<String> { get }
    var failure: PublishRelay<Swift.Error> { get }
    
}

class LoginViewModelDefImpl: LoginViewModelType {

    // MARK: Input
    var username = BehaviorRelay<String?>(value: nil)
    var password = BehaviorRelay<String?>(value: nil)
    var login = PublishRelay<Void>()
    
    // MARK: Output
    var inProgress = BehaviorRelay<Bool>(value: false)
    var success = PublishRelay<String>()
    var failure = PublishRelay<Swift.Error>()
    
    private let api: AuthenticationAPI
    private var disposeBag = DisposeBag()
    
    // MARK: Init
    
    init(api: AuthenticationAPI) {
        self.api = api
        bind()
    }
    
    // MARK: Private
    
    private func bind() {
        login.subscribe(onNext: { [weak self] in
            self?.authenticate()
        }).disposed(by: disposeBag)
        
    }
    
    private func authenticate() {
        inProgress.accept(true)
        api.authenticate(username: username.value, password: password.value)
            .subscribe(onSuccess: { [weak self] (_) in
                self?.success.accept("Loggin success!")
                self?.inProgress.accept(false)
            }, onError: { [weak self] error in
                self?.failure.accept(error)
                self?.inProgress.accept(false)
            }).disposed(by: disposeBag)
    }
}

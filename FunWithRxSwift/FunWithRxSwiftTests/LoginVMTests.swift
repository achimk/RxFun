//
//  Created by Joachim Kret on 13/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import FunWithRxSwift

final class LoginVMTests: XCTestCase {
    
    final class Spy {
        
        var username: String?
        func set(username value: String?) { username = value }
        
        var password: String?
        func set(password value:String?) { password = value }
        
        var inProgress: Bool?
        func set(inProgress value: Bool) { inProgress = value }
        
        var success: String?
        func set(success value: String) { success = value }
        
        var failure: Swift.Error?
        func set(failure value: Swift.Error) { failure = value }
    }
    
    private var bag = DisposeBag()
    
    override func tearDown() {
        bag = DisposeBag()
    }
    
    func testVM() {
        
        let usernameInput = PublishSubject<String?>()
        let passwordInput = PublishSubject<String?>()
        let loginInput = PublishSubject<Void>()
        
        let input = LoginViewModelInput(
            username: usernameInput,
            password: passwordInput,
            login: loginInput)
        
        var authInvoked: Int = 0
        var revokeInvoked: Int = 0
        let spy = Spy()
        let stubAPI = StubAuthenticationService()
        stubAPI.onAuthenticate = { (username, password) in
            spy.set(username: username)
            spy.set(password: password)
            authInvoked += 1
            return Single.just(())
        }
        stubAPI.onRevokeAuthentication = {
            revokeInvoked += 1
            return Single.just(())
        }
        
        let transform = loginViewModel(api: stubAPI)
        let output = transform(input)
        
        
        output.inProgress.drive(onNext: spy.set(inProgress:)).disposed(by: bag)
        output.success.drive(onNext: spy.set(success:)).disposed(by: bag)
        output.failure.drive(onNext: spy.set(failure:)).disposed(by: bag)
        
        usernameInput.onNext("test")
        passwordInput.onNext("987")
        usernameInput.onNext("abc")
        passwordInput.onNext("123")
        
        XCTAssertNil(spy.username)
        XCTAssertNil(spy.password)
        XCTAssertEqual(authInvoked, 0)
        
        loginInput.onNext(())
        
        XCTAssertEqual(spy.username, "abc")
        XCTAssertEqual(spy.password, "123")
        XCTAssertEqual(authInvoked, 1)
    }
}

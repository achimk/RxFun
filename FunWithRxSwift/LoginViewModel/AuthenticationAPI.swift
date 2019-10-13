//
//  Created by Joachim Kret on 13/10/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

protocol AuthenticationAPI {
    func authenticate(username: String?, password: String?) -> Single<Void>
    func revokeAuthentication() -> Single<Void>
}

final class StubAuthenticationService: AuthenticationAPI {
    
    var onAuthenticate: (String?, String?) -> Single<Void> = { (_, _) in
        return Single.just(()).delay(.seconds(1), scheduler: MainScheduler.instance)
    }
    
    var onRevokeAuthentication: () -> Single<Void> = {
        return Single.just(()).delay(.seconds(1), scheduler: MainScheduler.instance)
    }
    
    func authenticate(username: String?, password: String?) -> Single<Void> {
        return onAuthenticate(username, password)
    }
    
    func revokeAuthentication() -> Single<Void> {
        return onRevokeAuthentication()
    }
}

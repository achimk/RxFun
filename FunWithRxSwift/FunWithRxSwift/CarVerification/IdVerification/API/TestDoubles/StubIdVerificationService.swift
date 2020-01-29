//
//  Created by Joachim Kret on 29/01/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import Foundation
import RxSwift

struct StubIdVerificationService: IdVerificationService {
    
    var dueTime: RxTimeInterval = .seconds(1)
    var result: Result<VerifiedIdentity, Error> = .success(VerifiedIdentity(name: "test", surname: "test"))
    
    func verifyIdentity(_ identity: VerificationReadyIndentity) -> Single<VerifiedIdentity> {
        let result = self.result
        let source = Single<VerifiedIdentity>.create { (consumer) -> Disposable in
            do {
                let value = try result.get()
                consumer(.success(value))
            } catch {
                consumer(.error(error))
            }
            return Disposables.create()
        }
        
        return source.delay(dueTime, scheduler: MainScheduler.instance)
    }
}

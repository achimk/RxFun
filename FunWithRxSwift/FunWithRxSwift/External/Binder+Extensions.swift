//
//  Created by Joachim Kret on 21/02/2020.
//  Copyright © 2020 Joachim Kret. All rights reserved.
//

import RxSwift
import RxCocoa

extension Binder {
    
    public init(_ publishRelay: PublishRelay<Value>) {
        self = Binder(publishRelay, binding: { $0.accept($1) })
    }
    
    public init(_ behaviourRelay: BehaviorRelay<Value>) {
        self = Binder(behaviourRelay, binding: { $0.accept($1) })
    }
}

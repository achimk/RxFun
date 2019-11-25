//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

extension Result {
    
    public var value: Success? {
        if case .success(let value) = self { return value }
        else { return nil }
    }
    
    public var error: Failure? {
        if case .failure(let error) = self { return error }
        else { return nil }
    }
    
    public var isSuccess: Bool {
        if case .success = self { return true }
        else { return false }
    }
    
    public var isFailure: Bool { return !isSuccess }
    
}

//
//  Created by Joachim Kret on 25/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

struct PostalAddressChange {
    
    struct Change<T> {
        var original: T
        var value: T
        var isModified: Bool
    }
    
    let street: Change<String?>
    let city: Change<String?>
    let postCode: Change<String?>
    let isModified: Bool
    
    private init(
        street: Change<String?>,
        city: Change<String?>,
        postCode: Change<String?>) {
        
        self.street = street
        self.city = city
        self.postCode = postCode
        self.isModified = street.isModified || city.isModified || postCode.isModified
    }
    
    init(street: String?, city: String?, postCode: String?) {
        self.street = .init(original: street, value: street, isModified: false)
        self.city = .init(original: city, value: city, isModified: false)
        self.postCode = .init(original: postCode, value: postCode, isModified: false)
        self.isModified = false
    }
    
    func updated(street value: String?) -> PostalAddressChange {
        var change = street
        change.value = value
        change.isModified = change.original != value
        return PostalAddressChange.init(street: change, city: city, postCode: postCode)
    }
    
    func updated(city value: String?) -> PostalAddressChange {
        var change = city
        change.value = value
        change.isModified = change.original != value
        return PostalAddressChange.init(street: street, city: change, postCode: postCode)
    }
    
    func updated(postCode value: String?) -> PostalAddressChange {
        var change = postCode
        change.value = value
        change.isModified = change.original != value
        return PostalAddressChange.init(street: street, city: city, postCode: change)
    }
}

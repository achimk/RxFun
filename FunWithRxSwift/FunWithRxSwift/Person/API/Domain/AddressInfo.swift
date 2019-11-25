//
//  Created by Joachim Kret on 24/11/2019.
//  Copyright © 2019 Joachim Kret. All rights reserved.
//

import Foundation

enum AddressInfo {
    case postalOnly(PostalAddress)
    case emailOnly(EmailAddress)
    case all(PostalAddress, EmailAddress)
}

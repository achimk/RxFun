//: [Previous](@previous)

/*:
 
 **Sample of using Observable Convertible Protocol**
 * State is encapsulated
 * State change only possible by defined functions
 * Specified Observable for Counter
*/

import RxSwift

final class CounterObservable: ObservableConvertibleType {
    
    private let state = BehaviorRelay<Int>(value: 0)
    
    var current: Int { return state.value }
    
    func increment() {
        state.accept(state.value + 1)
    }
    
    func decrement() {
        state.accept(state.value - 1)
    }
    
    func asObservable() -> Observable<Int> {
        return state.asObservable()
    }
}


//: [Next](@next)

//: [Previous](@previous)

/*:
 
 **Sample of integration in ViewModel **
*/

import RxSwift

final class CounterViewModel {
    
    struct Input {
        var increment: Binder<Void>
        var decrement: Binder<Void>
    }
    
    struct Output {
        var current: Driver<String>
    }
    
    let input: Input
    let output: Output
    
    init(observable: CounterObservable) {
        
        // Input
        let increment = Binder<Void>(observable, binding: { (state, _) in state.increment() })
        let decrement = Binder<Void>(observable, binding: { (state, _) in state.decrement() })
        
        // Output
        let current = observable.asObservable()
            .map { "Counter: \($0)" }
            .asDriver(onErrorDriveWith: .empty())
        
        // Setup
        self.input = Input(increment: increment, decrement: decrement)
        self.output = Output(current: current)
    }
    
}

//: [Next](@next)

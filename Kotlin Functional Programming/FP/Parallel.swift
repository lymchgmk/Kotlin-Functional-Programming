//
//  Parallel.swift
//  FP
//
//  Created by changmuk.im@phoenixdarts.com on 2023/10/25.
//

import Foundation

//final class Par<A> {
//    let get: A
//
//    init(_ get: A) {
//        self.get = get
//    }
//
//    func unit<Element>(_ a: () -> Element) -> Par<Element> {
//        return Par<Element>(a())
//    }
//
//    func get(_ a: Par<A>) -> A {
//        return a.get
//    }
//}
//
//extension Par where A == Int {
//    func sum(_ ints: List<Int>) -> Int {
//        if ints.size() <= 1 {
//            switch ints {
//            case .nil:
//                return 0
//            case .cons(let head, _):
//                return head
//            }
//        } else {
//            let (l, r) = ints.splitAt(ints.size() / 2)
//            let sumL = unit { sum(l) }
//            let sumR = unit { sum(r) }
//            return sumL.get + sumR.get
//        }
//    }
//}
//
//// 연습문제 7.1
//extension Par {
//    func map2<L, R, C>(
//        _ left: Par<L>,
//        _ right: Par<R>,
//        _ f: @escaping (L, R) -> C
//    ) -> Par<C> {
//        return unit { f(left.get, right.get) }
//    }
//
//    func sum2(_ ints: List<Int>) -> Par<Int> {
//        if ints.size() <= 1 {
//            switch ints {
//            case .nil:
//                return unit { 0 }
//            case .cons(let head, _):
//                return unit { head }
//            }
//        } else {
//            let (l, r) = ints.splitAt(ints.size() / 2)
//            return map2(sum2(l), sum2(r)) { lx, rx in lx + rx }
//        }
//    }
//}

// 연습문제 7.2
//final class Par<A> {
//    let get: A
//
//    init(_ get: A) {
//        self.get = get
//    }
//
//    func unit<A>(_ a: A) -> Par<A> {
//        return Par<A>(a)
//    }
//
//    func map2<L, R, C>(
//        _ left: Par<L>,
//        _ right: Par<R>,
//        _ f: @escaping (L, R) -> C
//    ) -> Par<C> {
//        return Par<C>(f(left.get, right.get))
//    }
//
//    func fork<A>(_ f: () -> Par<A>) -> Par<A> {
//        return f()
//    }
//
//    func lazyUnit<A>(_ a: () -> A) -> Par<A> {
//        return Par<A>(a())
//    }
//
//    func run<A>(_ a: Par<A>) -> A {
//        return a.get
//    }
//}

//protocol Callable {
//    associatedtype A
//
//    func call() -> A
//}
//
//protocol Future {
//    associatedtype A
//
//    func get() -> A
//    func get(timeout: TimeInterval) -> A
//    func cancel(evenIfRunning: Bool) -> Bool
//    func isDone() -> Bool
//    func isCancelled() -> Bool
//}
//
//protocol ExecuterService {
//    associatedtype Element
//    associatedtype C: Callable where C.A == Element
//    associatedtype F: Future where F.A == Element
//
//    func submit(c: C) -> F
//}

class Callable<A> {
    let a: A

    init(_ a: A) {
        self.a = a
    }

    func call() -> A {
        return a
    }
}

class Future<A> {
    let a: A

    init(_ a: A) {
        self.a = a
    }


    func get() -> A {
        return a
    }
}

protocol ExecuterService {
    func submit<A>(c: Callable<A>) -> Future<A>
}

final class Pars<A> {
    typealias Par<A> = (any ExecuterService) -> Future<A>

    func unit<A>(_ a: A) -> Par<A> {
        return { ex in UnitFuture(a) }
    }

    class UnitFuture<A>: Future<A> {
        let element: A

        override init(_ element: A) {
            self.element = element
            super.init(element)
        }

        override func get() -> A {
            return element
        }

        func get(timeout: TimeInterval) -> A {
            return element
        }

        func cancel(evenIfRunning: Bool) -> Bool {
            return false
        }

        func isDone() -> Bool {
            return true
        }

        func isCancelled() -> Bool {
            return false
        }
    }

    func map2<A, B, C>(
        _ a: @escaping Par<A>,
        _ b: @escaping Par<B>,
        _ f: @escaping (A, B) -> C
    ) -> Par<C> {
        return { es in
            let af = a(es)
            let bf = b(es)
            return UnitFuture(f(af.get(), bf.get()))
        }
    }
}


//
//final class Par<A> {
//    let get: A
//
//    init(_ get: A) {
//        self.get = get
//    }
//
//    func unit<Element>(_ a: () -> Element) -> Par<Element> {
//        return Par<Element>(a())
//    }
//}
//
//extension Par where A == Int {
//    func sum(_ ints: List<Int>) -> Int {
//        if ints.size() <= 1 {
//            switch ints {
//            case .nil:
//                return 0
//            case .cons(let head, _):
//                return head
//            }
//        } else {
//            let (l, r) = ints.splitAt(ints.size() / 2)
//            let sumL: Par<Int> = unit { sum(l) }
//            let sumR: Par<Int> = unit { sum(r) }
//            return sumL.get + sumR.get
//        }
//    }
//
//    func sum(_ ints: List<Int>) -> Par<Int> {
//        if ints.size() <= 1 {
//            switch ints {
//            case .nil:
//                return unit { 0 }
//            case .cons(let head, _):
//                return unit { head }
//            }
//        } else {
//            let (l, r) = ints.splitAt(ints.size() / 2)
//            return map2(sum(l), sum(r)) { lx, rx in lx + rx }
//        }
//    }
//}
//
//// 연습문제 7.1
//extension Par {
//    func map2<L, R, C>(
//        _ left: Par<L>,
//        _ right: Par<R>,
//        _ f: @escaping (L, R) -> C
//    ) -> Par<C> {
//        return unit { f(left.get, right.get) }
//    }
//}
//
//extension Par {
////    func unit<Element>(_ a: Element) -> Par<Element> {
////        return Par<Element>(a)
////    }
////
////    func fork<Element>(_ a: () -> Par<Element>) -> Par<Element> {
////
////    }
////
////    func lazyUnit<Element>(_ a: () -> Element) -> Par<Element> {
////        return fork { unit(a()) }
////    }
//}
//
//import Combine
//
//final class Pars {
//    static let shared = Pars()
//    private init() {}
//
//    func unit<A>(_ a: A) -> Par<A> {
//        return { _ in UnitFuture(a) }
//    }
//
//    struct UnitFuture<Element>: Future {
//        typealias A = Element
//        let a: A
//
//        init(_ a: A) {
//            self.a = a
//        }
//
//        func get() -> A {
//            return a
//        }
//
//        func get(timeout: Int64, timeUnit: TimeInterval) -> A {
//            return a
//        }
//
//        func cancel(evenIfRunning: Bool) -> Bool {
//            return false
//        }
//
//        func isDone() -> Bool {
//            return true
//        }
//
//        func isCancelled() -> Bool {
//            return false
//        }
//    }
//
//    func map2<A, B, C>(
//        _ a: Par<A>,
//        _ b: Par<B>,
//        _ f: @escaping (A, B) -> C
//    ) -> Par<C> {
//
//    }
//
//    // func fork<A>(_)
//}
//
//protocol Callable {
//    associatedtype A
//
//    func call() -> A
//}
//
//protocol Future {
//    associatedtype A
//
//    func get() -> A
//    func get(timeout: Int64, timeUnit: TimeInterval) -> A
//    func cancel(evenIfRunning: Bool) -> Bool
//    func isDone() -> Bool
//    func isCancelled() -> Bool
//}
//
////protocol ExecutorService {
////    func submit(_ c: any Callable) -> any Future
////}

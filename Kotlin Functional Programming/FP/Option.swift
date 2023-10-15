//
//  Option.swift
//  Kotlin Functional Programming
//
//  Created by lymchgmk on 2023/09/24.
//

import Foundation

enum Option<A> {
    case some(_ value: A)
    case none
    
    func isEmpty() -> Bool {
        switch self {
        case .some:
            return false
        case .none:
            return true
        }
    }
}

func lift<A, B>(_ f: @escaping (A) -> B) -> (Option<A>) -> Option<B> {
    return { oa in oa.map(f) }
}

extension Option: Equatable where A: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.some(let valueL), .some(let valueR)):
            return valueL == valueR
        default:
            return false
        }
    }
}

/*
 연습문제 4.1: map, flatMap, getOrElse, orElse, filter 함수를 구현하라.
 */
extension Option {
    func map<B>(_ f: (A) -> B) -> Option<B> {
        switch self {
        case .some(let value):
            return .some(f(value))
        case .none:
            return .none
        }
    }
    
    func flatMap<B>(_ f: (A) -> Option<B>) -> Option<B> {
        switch self {
        case .some(let value):
            return f(value)
        case .none:
            return .none
        }
    }
    
    func getOrElse(_ default: () -> A) -> A {
        switch self {
        case .some(let value):
            return value
        case .none:
            return `default`()
        }
    }
    
    func orElse(_ ob: () -> Option<A>) -> Option<A> {
        switch self {
        case .some:
            return self
        case .none:
            return ob()
        }
    }
    
    func filter(_ f: (A) -> Bool) -> Option<A> {
        switch self {
        case .some(let value):
            return f(value) ? self : .none
        case .none:
            return .none
        }
    }
}

/*
 연습문제 4.2: flatMap을 사용해 variance 함수를 구현하라.
 */
extension List<Double> {
    var isEmpty: Bool {
        switch self {
        case .nil:
            return true
        case .cons:
            return false
        }
    }
    
    func sum() -> Double {
        switch self {
        case .nil:
            return .zero
        case .cons(let head, let tail):
            return head + tail.sum()
        }
    }
    
    func size() -> Int {
        switch self {
        case .nil:
            return .zero
        case .cons(_, let tail):
            return 1 + tail.size()
        }
    }
}

extension List {
    func map<B>(_ f: (A) -> B) -> List<B> {
        return map(self, f)
    }
}

extension Option {
    func mean(_ xs: List<Double>) -> Option<Double> {
        if xs.isEmpty {
            return .none
        } else {
            return .some(xs.sum() / Double(xs.size()))
        }
    }
    
    func variance(_ xs: List<Double>) -> Option<Double> {
        return mean(xs).flatMap { m in
            mean(xs.map { x in
                pow(x - m, 2)
            })
        }
    }
}

/*
 연습문제 4.3: 두 Option 값을 이항 함수를 통해 조합하는 제네릭 함수 map2를 작성하라.
            두 Option 중 어느 하나라도 None이면 반환값도 None이다.
 */
extension Option {
    func map2<A, B, C>(_ a: Option<A>, _ b: Option<B>, f: (A, B) -> C) -> Option<C> {
        a.flatMap { aa in
            b.map { bb in
                f(aa, bb)
            }
        }
    }
}

/*
 연습문제 4.4: 원소가 Option인 List를 원소가 List인 Option으로 합쳐주는 sequence 함수를 작성하라.
             반환되는 Option의 원소는 원래 List에서 Some인 값만 모은 List이며, 원래 List 안에 None이 단 하나라도 있으면 결과값이 None이어야 한다.
 */
extension Option {
    func sequence(_ xs: List<Option<A>>) -> Option<List<A>> {
        switch xs {
        case .nil:
            return .some(.nil)
        case .cons(let head, let tail):
            return head.flatMap { hh in sequence(tail).map { .cons(hh, $0) } }
        }
    }
}

/*
 연습문제 4.5: traverse 함수를 구현하라.
 */
extension Option {
    func traverse<A, B>(_ xa: List<A>, _ f: (A) -> Option<B>) -> Option<List<B>> {
        switch xa {
        case .nil:
            return .some(.nil)
        case .cons(let head, let tail):
            return map2(f(head), traverse(tail, f)) { b, xb in .cons(b, xb) }
        }
    }
    
    func sequence2(_ xs: List<Option<A>>) -> Option<List<A>> {
        return traverse(xs) { $0 }
    }
}

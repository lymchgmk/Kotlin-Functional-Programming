//
//  List.swift
//  Kotlin Functional Programming
//
//  Created by lymchgmk on 2023/09/21.
//

import Foundation

/*
    List 및 기본 함수 구현
 */
indirect enum List<A> {
    case `nil`
    case cons(_ head: A, _ tail: List<A> = .nil)
    
    static func of<A>(_ aa: [A]) -> List<A> {
        guard let head = aa.first else { return .nil }
        let tail = Array(aa.dropFirst())
        return aa.isEmpty ? .nil : .cons(head, .of(tail))
    }
}

extension List {
    func sum(_ ints: List<Int>) -> Int {
        switch ints {
        case .nil:
            return .zero
        case .cons(let head, let tail):
            return head + sum(tail)
        }
    }
    
    func product(_ doubles: List<Double>) -> Double {
        switch doubles {
        case .nil:
            return 1.0
        case .cons(let head, let tail):
            if head == .zero {
                return .zero
            } else {
                return head * product(tail)
            }
        }
    }
}

/*
    연습문제 3.1: List의 첫 번째 원소를 제거하는 tail 함수를 구현하라.
 */
extension List {
    func tail(_ xs: List<A>) -> List<A> {
        switch xs {
        case .nil:
            return .nil
        case .cons(_, let tail):
            return self.tail(tail)
        }
    }
}

/*
    연습문제 3.2: List의 첫 원소를 다른 값으로 대치하는 setHead 함수를 작성하라.
 */
extension List {
    func setHead(_ xs: List<A>, _ x: A) -> List<A> {
        switch xs {
        case .nil:
            return .nil
        case .cons(_, let tail):
            return .cons(x, tail)
        }
    }
}

/*
    연습문제 3.3: tail을 더 일반화해서 drop 함수를 작성하라. drop은 리스트 맨 앞부터 n개 원소를 제거한다.
 */
extension List {
    func drop(_ l: List<A>, n: Int) -> List<A> {
        guard 0 < n else { return l }
        
        switch l {
        case .nil:
            return .nil
        case .cons(_, let tail):
            return drop(tail, n: n - 1)
        }
    }
}

/*
    연습문제 3.4: dropWhile을 구현하라. 이 함수는 List의 맨 앞에서부터 주어진 술어를 만족하는 연속적인 원소를 삭제한다.
 */
extension List {
    func dropWhile(_ l: List<A>, _ f: (A) -> Bool) -> List<A> {
        switch l {
        case .nil:
            return .nil
        case .cons(let head, let tail):
            return f(head) ? dropWhile(tail, f) : l
        }
    }
}

/*
    연습문제 3.5: 어떤 List에서 마지막 원소를 제외한 나머지 모든 원소로 이뤄진 새 List를 반환하는 init 함수를 정의하라.
 */
extension List {
    func `init`(_ l: List<A>) -> List<A> {
        switch l {
        case .nil:
            return .nil
        case .cons(let head, let tail):
            switch tail {
            case .nil:
                return .nil
            case .cons:
                return .cons(head, `init`(tail))
            }
        }
    }
}

/*
    연습문제 3.6: foldRight로 구현된 product가 리스트 원소로 0.0을 만나면 재귀를 즉시 중단하고 결과를 돌려줄 수 있는가?
                즉시 결과를 돌려줄 수 있거나 돌려줄 수 없는 이유는 무엇인가?
                긴 리스트에 대해 쇼트 서킷을 제공할 수 있으면 어떤 장점이 있을지 생각해보라.
                5장에서는 이 질문이 내포하고 있는 의미를 더 자세히 살펴본다.
 */

// FIXME: 책의 답 잘못 표기!

/*
    답: foldRight의 경우, f 함수를 호출하기 전에 함수에 전달할 인자를 평가하고, 리스트를 맨 마지막까지 순회하기 때문에 불가능하다.
        즉시 결과를 돌려줄 수 있는, 이른 중단을 지원하기 위해서는 f 함수에 대한 엄격하지 않은 평가가 필요하다.
 */

/*
    연습문제 3.7: 다음과 같이 Nil과 Cons를 foldRight에 넘길 때 각각 어떤 일이 벌어지는지 살펴보라.
 */

/*
    답: 원래의 Nil과 Cons를 그대로 가져온다.
 */
extension List {
    func foldRight<A, B>(_ xs: List<A>, _ z: B, _ f: (A, B) -> B) -> B {
        switch xs {
        case .nil:
            return z
        case .cons(let head, let tail):
            return f(head, foldRight(tail, z, f))
        }
    }
    
    static func empty() -> List<A> {
        return .nil
    }
}

/*
    연습문제 3.8: foldRight를 사용해 리스트 길이를 계산하라.
 */
extension List {
    func length(_ xs: List<A>) -> Int {
        return foldRight(xs, 0) { _, cal in cal + 1 }
    }
}

/*
    연습문제 3.9: 우리가 구현한 foldRight는 꼬리 재귀가 아니므로 리스트가 긴 경우 StackOverflowError를 발생시킨다.
                꼬리재귀를 사용하여 foldLeft를 작성하라.
 */
extension List {
    func foldLeft<A, B>(_ xs: List<A>, _ z: B, _ f: (B, A) -> B) -> B {
        switch xs {
        case .nil:
            return z
        case .cons(let head, let tail):
            return foldLeft(tail, f(z, head), f)
        }
    }
}

/*
    연습문제 3.10: foldLeft를 사용해 sum, product, length 함수를 작성하라.
 */
extension List<Int> {
    func sumL(_ ints: List<Int>) -> Int {
        return foldLeft(ints, .zero) { b, a in a + b }
    }
}

extension List<Double> {
    func productL(_ dbs: List<Double>) -> Double {
        return foldLeft(dbs, 1.0) { b, a in a * b }
    }
}

extension List {
    func lengthL(_ xs: List<A>) -> Int {
        return foldLeft(xs, 0) { acc, _ in acc + 1 }
    }
}

/*
    연습문제 3.11: List의 순서를 뒤집은 새 List를 반환하는 함수를 작성하라.
 */
extension List {
    func reversed(_ xs: List<A>) -> List<A> {
        return foldLeft(xs, .empty()) { tail, head in .cons(head, tail) }
    }
}

/*
    연습문제 3.12: foldLeft를 foldRight를 사용해 작성할 수 있는가? 반대로 foldRight를 foldLeft를 사용해 작성할 수 있는가?
                 foldRight를 foldLeft로 구현하면 foldRight를 꼬리 재귀로 구현할 수 있기때문에 StackOverflowError를 방지할 수 있어 유용하다.
 */
extension List {
    func foldLeftR<B>(_ xs: List<A>, _ z: B, _ f: @escaping (B, A) -> B) -> B {
        return foldRight(
            xs,
            { b in b },
            { a, g in
                { b in
                    g(f(b, a))
                }
            }
        )(z)
    }
    
    func foldRightL<B>(_ xs: List<A>, _ z: B, _ f: @escaping (A, B) -> B) -> B {
        return foldLeft(
            xs,
            { b in b },
            { g, a in
                { b in
                    g(f(a, b))
                }
            }
        )(z)
    }
}

/*
    연습문제 3.13: append를 foldLeft나 foldRight를 사용해 구현하라.
 */
extension List {
    func append<A>(_ xs1: List<A>, _ xs2: List<A>) -> List<A> {
        return foldRight(xs1, xs2) { head, tail in .cons(head, tail) }
    }
}

/*
    연습문제 3.14: List가 원소인 List를 단일 List로 연결해주는 함수를 작성하라.
                 이 함수의 실행 시간은 모든 리스트의 길이 합계에 선형으로 비례해야 한다.
 */
extension List {
    func concat(_ xxs: List<List<A>>) -> List<A> {
        return foldRight(xxs, .empty()) { xs1, xs2 in append(xs1, xs2) }
    }
}

/*
    연습문제 3.15: Int로 이뤄진 List의 각 원소에 1을 더한 List로 변환하는 함수를 작성하라.
                 이 함수는 순수 함수이면서 새 List를 반환해야 한다.
 */
extension List {
    func increment(_ xs: List<Int>) -> List<Int> {
        return foldRight(xs, .empty()) { n, xn in .cons(n + 1, xn) }
    }
}

/*
    연습문제 3.16: List<Double>의 각 원소를 String으로 변환하는 함수를 작성하라.
 */
extension List {
    func doubleToString(_ xs: List<Double>) -> List<String> {
        return foldRight(xs, .empty()) { d, xd in .cons(String(d), xd) }
    }
}

/*
    연습문제 3.17: List의 모든 원소를 변경하되 List 구조는 그대로 유지하는 map 함수를 작성하라.
 */
extension List {
    func map<A, B>(_ xs: List<A>, _ f: (A) -> B) -> List<B> {
        return foldRight(xs, .empty()) { a, xb in .cons(f(a), xb) }
    }
}

/*
    연습문제 3.18: List에서 주어진 조건을 만족하지 않는 원소를 제거해주는 filter 함수를 작성하라.
 */
extension List {
    func filter<A>(_ xs: List<A>, _ f: (A) -> Bool) -> List<A> {
        return foldRight(xs, .empty()) { a, xa in f(a) ? .cons(a, xa) : xa }
    }
}

/*
    연습문제 3.19: map과 유사하지만, 인자로 List를 반환하는 함수를 받는 flatMap 함수를 작성하라.
 */
extension List {
    func flatMap<A, B>(_ xa: List<A>, _ f: (A) -> List<B>) -> List<B> {
        return foldRight(xa, .empty()) { a, xb in append(f(a), xb) }
    }
}

/*
    연습문제 3.20: flatMap을 사용해 filter를 구현하라.
 */
extension List {
    func filter2<A>(_ xa: List<A>, _ f: (A) -> Bool) -> List<A> {
        return flatMap(xa) { a in f(a) ? .of([a]) : .empty() }
    }
}

/*
    연습문제 3.21: 두 List를 받아서 서로 같은 인덱스에 있는 원소들을 더한 값으로 이뤄진 새 List를 반환하는 함수를 작성하라.
 */
extension List {
    func add(_ xa: List<Int>, _ xb: List<Int>) -> List<Int> {
        switch (xa, xb) {
        case (.cons(let headA, let tailA), .cons(let headB, let tailB)):
            return .cons(headA + headB, add(tailA, tailB))
        default:
            return .nil
        }
    }
}

/*
    연습문제 3.22: 위의 add함수를 일반화해 정수 타입에 한정되지 않고 다양한 처리가 가능한 zipWith함수를 구현하라.
 */
extension List {
    func zipWith<A>(_ xa: List<A>, _ xb: List<A>, _ f: (A, A) -> A) -> List<A> {
        switch (xa, xb) {
        case (.cons(let headA, let tailA), .cons(let headB, let tailB)):
            return .cons(f(headA, headB), zipWith(tailA, tailB, f))
        default:
            return .nil
        }
    }
}

/*
    연습문제 3.23: 어떤 List가 다른 List를 부분열로 포함하는지 검사하는 hasSubsequence를 구현하라.
 */
extension List {
    func hasSubsequence<A: Equatable>(_ xs: List<A>, sub: List<A>) -> Bool {
        switch (xs, sub) {
        case (.nil, .nil):
            return true
        case (.nil, .cons):
            return false
        case (.cons, .nil):
            return true
        case (.cons(let headA, let tailA), .cons(let headB, let tailB)):
            return headA == headB ? hasSubsequence(tailA, sub: tailB) : hasSubsequence(tailA, sub: sub)
        }
    }
}

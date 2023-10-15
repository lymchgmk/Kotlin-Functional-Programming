//
//  Stream.swift
//  Kotlin Functional Programming
//
//  Created by lymchgmk on 2023/10/08.
//

import Foundation

/*
    Stream 구현
 */
indirect enum Stream<A> {
    case cons(_ head: () -> A, _ tail: () -> Stream<A>)
    case empty

    func headOption() -> Option<A> {
        switch self {
        case .empty:
            return .none
        case .cons(let head, _):
            return .some(head())
        }
    }

    static func cons(hd: @escaping () -> A, tl: @escaping () -> Stream<A>) -> Stream<A> {
        lazy var head: A = hd()
        lazy var tail: Stream<A> = tl()
        return .cons({ head }, { tail })
    }

    func empty() -> Stream<A> {
        return .empty
    }
    
    func exists(_ p: (A) -> Bool) -> Bool {
        switch self {
        case .cons(let head, let tail):
            return p(head()) || tail().exists(p)
        default:
            return false
        }
    }
    
    func exists2(_ p: @escaping (A) -> Bool) -> Bool {
        return foldRight({ false }, { a, b in p(a) || b() })
    }
    
    func find(_ p: @escaping (A) -> Bool) -> Option<A> {
        return filter(p).headOption()
    }
}

extension Stream {
    static func of<A>(_ xs: A...) -> Stream<A> {
        if xs.isEmpty {
            return .empty
        } else {
            return .cons({ xs[0] }, { of(Array(xs.dropFirst())) })
        }
    }
    
    static func of<A>(_ xs: [A]) -> Stream<A> {
        if xs.isEmpty {
            return .empty
        } else {
            return .cons({ xs[0] }, { of(Array(xs.dropFirst())) })
        }
    }
}

/*
    연습문제 5.1: Stream을 List로 변환하는 함수를 작성하라.
 */
extension Stream {
    func toList() -> List<A> {
        switch self {
        case .cons(let head, let tail):
            return .cons(head(), tail().toList())
        case .empty:
            return .nil
        }
    }
}

/*
    연습문제 5.2: Stream의 맨 앞에서 원소 n개를 반환하는 take(n), 맨 앞에서 원소를 n개 건너뛴 나머지를 반환하는 drop(n)을 작성하라.
 */
extension Stream {
    func take(_ n: Int) -> Stream<A> {
        func _take(xs: Stream<A>, n: Int) -> Stream<A> {
            switch xs {
            case .empty:
                return .empty
            case .cons(let head, let tail):
                if n == 0 {
                    return .empty
                } else {
                    return .cons(head, { _take(xs: tail(), n: n - 1) })
                }
            }
        }
        
        return _take(xs: self, n: n)
    }
    
    func drop(_ n: Int) -> Stream<A> {
        func _drop(xs: Stream<A>, n: Int) -> Stream<A> {
            switch xs {
            case .empty:
                return .empty
            case .cons(_, let tail):
                if n == 0 {
                    return xs
                } else {
                    return _drop(xs: tail(), n: n - 1)
                }
            }
        }
        
        return _drop(xs: self, n: n)
    }
}

/*
    연습문제 5.3: 조건을 만족하는 접두사를 돌려주는 takeWhile을 작성하라
 */
extension Stream {
    func takeWhile(_ p: @escaping (A) -> Bool) -> Stream<A> {
        switch self {
        case .empty:
            return empty()
        case .cons(let head, let tail):
            return p(head()) ? .cons(head, { tail().takeWhile(p) }) : empty()
        }
    }
}

/*
    연습문제 5.4: Stream의 모든 원소가 주어진 술어를 만족하는지 검사하는 forAll을 구현하라. 만족하지 않으면 순회를 최대한 빨리 중단해야만 한다.
 */
extension Stream {
    func forAll1(_ p: @escaping (A) -> Bool) -> Bool {
        switch self {
        case .empty:
            return true
        case .cons(let head, let tail):
            return p(head()) ? tail().forAll1(p) : false
        }
    }
    
    func foldRight<B>(
        _ z: @escaping () -> B,
        _ f: @escaping (A, @escaping () -> B) -> B
    ) -> B {
        switch self {
        case .cons(let head, let tail):
            return f(head()) { tail().foldRight(z, f) }
        case .empty:
            return z()
        }
    }
    
    
    func forAll2(_ p: @escaping (A) -> Bool) -> Bool {
        return foldRight({ true }, { a, b in p(a) && b() })
    }
}

/*
    연습문제 5.5: foldRight를 사용해 takeWhile을 구현하라.
 */
extension Stream {
    func takeWhileWithFoldRight(_ p: @escaping (A) -> Bool) -> Stream<A> {
        return foldRight(
            { empty() },
            { h, t in
                p(h) ? .cons({ h }, t) : empty()
            }
        )
    }
}

/*
    연습문제 5.6: foldRight를 사용해 headOption을 구현하라.
 */
extension Stream {
    func headOptionWithFoldRight() -> Option<A> {
        return self.foldRight(
            { .none },
            { a, _ in .some(a) }
        )
    }
}

/*
    연습문제 5.7: foldRight를 사용해 map, filter, append를 구현하라. append는 인자에 대해 엄격하지 않아야만 한다.
 */
extension Stream {
    func map<B>(_ f: @escaping (A) -> B) -> Stream<B> {
        return foldRight({ .empty }, { h, t in .cons({ f(h) }, t) })
    }
    
    func filter(_ f: @escaping (A) -> Bool) -> Stream<A> {
        return foldRight({ .empty }, { h, t in f(h) ? .cons({ h }, t) : t() })
    }
    
    func append(_ sa: @escaping () -> Stream<Any>) -> Stream<Any> {
        return foldRight(sa, { h, t in .cons({ h }, t) })
    }
}

/*
    연습문제 5.8: ones를 약간 일반화해서 정해진 값으로 이뤄진 무한 Stream을 돌려주는 constant 함수를 작성하라.
 */
extension Stream<Int> {
    static func ones() -> Stream<Int> {
        return .cons({ 1 }, { ones() })
    }
}

extension Stream {
    static func constant(_ a: A) -> Stream<A> {
        return .cons({ a }, { constant(a) })
    }
}

/*
    연습문제 5.9: n부터 시작해서 n + 1, n + 2 등을 차례로 내놓는 무한한 정수 Stream을 만드는 함수 from을 작성하라.
 */
extension Stream<Int> {
    static func from(_ n: Int) -> Stream<Int> {
        return .cons({ n }, { from(n + 1) })
    }
}

/*
    연습문제 5.10: 무한한 피보나치 수열을 만들어내는 fibs 함수를 작성하라
 */
extension Stream<Int> {
    static func fibs() -> Stream<Int> {
        func go(_ curr: Int, _ post: Int) -> Stream<Int> {
            return .cons({ curr }, { go(post, curr + post) })
        }
        
        return go(0, 1)
    }
}

/*
    연습문제 5.11: 더 일반적인 Stream 구성 함수인 unfold를 작성하라.
 */
extension Stream {
    func unfold<A, S>(_ z: S, _ f: @escaping (S) -> Option<(A, S)>) -> Stream<A> {
        f(z).map { a, s in
            .cons({ a }, { unfold(s, f)})
        }.getOrElse {
            .empty
        }
    }
}

/*
    연습문제 5.12: unfold를 사용해 fibs, from, constant, ones를 구현하라.
 */
extension Stream<Int> {
    func fibsWithUnfold() -> Stream<Int> {
        return unfold((0, 1)) { curr, post in .some((curr, (post, curr + post))) }
    }
    
    func fromWithUnfold(_ n: Int) -> Stream<Int> {
        return unfold(n) { a in .some((a, a + 1)) }
    }
    
    func constantWithUnfold(_ n: A) -> Stream<A> {
        return unfold(n) { a in .some((a, a)) }
    }
    
    func onesWithUnfold() -> Stream<Int> {
        return unfold(1, { _ in .some((1, 1)) })
    }
}

/*
    연습문제 5.13: unfold를 사용해 map, take, takeWhile, zipWith, zipAll을 구현하라.
 */
extension Stream {
    func mapWithUnfold<B>(_ f: @escaping (A) -> B) -> Stream<B> {
        return unfold(self) { s in
            switch s {
            case .cons(let head, let tail):
                return .some((f(head()), tail()))
            case .empty:
                return .none
            }
        }
    }
    
    func takeWithUnfold(_ n: Int) -> Stream<A> {
        return unfold(self) { s in
            switch s {
            case .cons(let head, let tail):
                return 0 < n ? .some((head(), tail().take(n - 1))) : .none
            case .empty:
                return .none
            }
        }
    }
    
    func takeWhileWithUnfold(_ p: @escaping (A) -> Bool) -> Stream<A> {
        return unfold(self) { s in
            switch s {
            case .cons(let head, let tail):
                return p(head()) ? .some((head(), tail())) : .none
            case .empty:
                return .none
            }
        }
    }
    
    func zipWith<B, C>(_ that: Stream<B>, _ f: @escaping (A, B) -> C) -> Stream<C> {
        return unfold((self, that)) { sa, sb in
            switch (sa, sb) {
            case (.cons(let headA, let tailA), .cons(let headB, let tailB)):
                return .some((f(headA(), headB()), (tailA(), tailB())))
            default:
                return .none
            }
        }
    }
    
    func zipAll<B>(_ that: Stream<B>) -> Stream<(Option<A>, Option<B>)> {
        return unfold((self, that)) { sa, sb in
            switch (sa, sb) {
            case (.cons(let headA, let tailA), .cons(let headB, let tailB)):
                return .some((
                    (.some(headA()), .some(headB())),
                    (tailA(), tailB())
                ))
            case (.cons(let headA, let tailA), .empty):
                return .some((
                    (.some(headA()), .none),
                    (tailA(), .empty)
                ))
            case (.empty, .cons(let headB, let tailB)):
                return .some((
                    (.none, .some(headB())),
                    (.empty, tailB())
                ))
            case (.empty, .empty):
                return .none
            }
        }
    }
}

/*
    연습문제 5.14: 연습문제 5.13에서 작성한 함수를 사용해 startsWith를 구현하라.
 */
extension Stream where A: Equatable {
    func startsWith(_ that: Stream<A>) -> Bool {
        return self.zipAll(that)
            .takeWhile { !$0.1.isEmpty() }
            .forAll2 { $0.0 == $0.1 }
    }
}

/*
    연습문제 5.15: 주어진 Stream의 모든 접미사를 돌려주는 tails를 unfold를 사용해 구현하라.
 */
extension Stream {
    func tails() -> Stream<Stream<A>> {
        return unfold(self) { s in
            switch s {
            case .cons(_, let tail):
                return .some((s, tail()))
            case .empty:
                return .none
            }
        }
    }
}

/*
    연습문제 5.16: tails를 일반화해서 scanRight를 만들라.
 */
extension Stream {
    func scanRight<B>(_ z: B, _ f: @escaping (A, () -> B) -> B) -> Stream<B> {
        return foldRight(
            { (z, Stream.of(z)) },
            { a, p0 in
                let p1 = { p0() }()
                let b2 = f(a) { p1.0 }
                return (b2, .cons({ b2 }, { p1.1 }))
            }
        ).1
    }
}

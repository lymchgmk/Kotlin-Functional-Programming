//
//  Either.swift
//  Kotlin Functional Programming
//
//  Created by lymchgmk on 2023/09/24.
//

import Foundation

enum Either<E, A> {
    case left(_ value: E)
    case right(_ value: A)
}

/*
 연습문제 4.6: Right 값에 대해 활용할 수 있는, map, flatMap, orElse, map2를 구현하라.
 */
extension Either {
    func map<B>(_ f: (A) -> B) -> Either<E, B> {
        switch self {
        case .left(let e):
            return .left(e)
        case .right(let a):
            return .right(f(a))
        }
    }
    
    func flatMap<B>(_ f: (A) -> Either<E, B>) -> Either<E, B> {
        switch self {
        case .left(let e):
            return .left(e)
        case .right(let a):
            return f(a)
        }
    }
    
    func orElse(_ f: () -> Either<E, A>) -> Either<E, A> {
        switch self {
        case .left:
            return f()
        case .right:
            return self
        }
    }
    
    func map2<E, A, B, C>(_ ae: Either<E, A>, _ be: Either<E, B>, _ f: (A, B) -> C) -> Either<E, C> {
        return ae.flatMap { a in
            be.map { b in f(a, b) }
        }
    }
}

/*
 연습문제 4.7: Either에 대한 sequence와 traverse를 구현하라. 오류가 생긴 경우 최초로 발생한 오류를 반환해야 한다.
 */
extension Either {
    func traverse<E, A, B>(_ xs: List<A>, _ f: (A) -> Either<E, B>) -> Either<E, List<B>> {
        switch xs {
        case .nil:
            return .right(.nil)
        case .cons(let head, let tail):
            return map2(f(head), traverse(tail, f)) { b, xb in .cons(b, xb) }
        }
    }
    
    func sequence(_ es: List<Either<E, A>>) -> Either<E, List<A>> {
        return traverse(es) { $0 }
    }
}

/*
 연습문제 4.8: 리스트 4.8에서는 이름과 나이가 모두 잘못되더라도 map2가 오류를 하나만 보고할 수 있다. 두 오류를 모두 보고하게 하려면 어디를 바꿔야 할까?
 */

// 리스트 4.8
struct Name {
    let value: String
}

struct Age {
    let value: Int
}

struct Person {
    let name: Name
    let age: Age
    
    func mkName(name: String) -> Either<String, Name> {
        if name.isEmpty {
            return .left("Name is empty.")
        } else {
            return .right(Name(value: name))
        }
    }
    
    func mkAge(age: Int) -> Either<String, Age> {
        if age < 0 {
            return .left("Age is out of range.")
        } else {
            return .right(Age(value: age))
        }
    }
    
    func map2<E, A, B, C>(_ ae: Either<E, A>, _ be: Either<E, B>, _ f: (A, B) -> C) -> Either<E, C> {
        return ae.flatMap { a in
            be.map { b in f(a, b) }
        }
    }
    
    func mkPerson(name: String, age: Int) -> Either<String, Person> {
        return map2(mkName(name: name), mkAge(age: age)) { n, a in Person(name: n, age: a) }
    }
}

// 풀이
extension Person {
    func map2<E, A, B, C>(_ ae: Either<E, A>, _ be: Either<E, B>, _ f: (A, B) -> C) -> Either<List<E>, C> {
        switch (ae, be) {
        case (.left(let errorA), .left(let errorB)):
            return .left(.cons(errorA, .cons(errorB)))
        case (.left(let errorA), .right):
            return .left(.cons(errorA))
        case (.right, .left(let errorB)):
            return .left(.cons(errorB))
        case (.right(let valueA), .right(let valueB)):
            return .right(f(valueA, valueB))
        }
    }
    
    func mkPerson(name: String, age: Int) -> Either<List<String>, Person> {
        return map2(mkName(name: name), mkAge(age: age)) { n, a in Person(name: n, age: a) }
    }
}

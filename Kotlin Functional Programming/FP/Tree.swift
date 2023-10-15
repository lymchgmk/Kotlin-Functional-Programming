//
//  Tree.swift
//  Kotlin Functional Programming
//
//  Created by lymchgmk on 2023/09/21.
//

import Foundation

/*
    Tree 구현
 */
indirect enum Tree<A> {
    case leaf(value: A)
    case branch(left: Tree<A>, right: Tree<A>)
}

/*
    연습문제 3.24: 트리 안에 들어 있는 노드의 갯수를 반환하는 size 함수를 작성하라.
 */
extension Tree {
    func size<A>(tree: Tree<A>) -> Int {
        switch tree {
        case .leaf:
            return 1
        case .branch(let left, let right):
            return 1 + size(tree: left) + size(tree: right)
        }
    }
}

/*
    연습문제 3.25: Tree<Int>에서 가장 큰 원소를 돌려주는 maximum 함수를 작성하라.
 */

// FIXME: 책의 답 3.24 중복, 3.25 누락
extension Tree<Int> {
    func maximum(tree: Tree<Int>) -> Int {
        switch tree {
        case .leaf(let value):
            return value
        case .branch(let left, let right):
            return max(maximum(tree: left), maximum(tree: right))
        }
    }
}

/*
    연습문제 3.26: Tree 뿌리에서 각 Leaf까지의 경로 중 가장 길이가 긴 간선의 길이 값을 돌려주는 depth 함수를 작성하라.
 */
extension Tree {
    func depth(tree: Tree<A>) -> Int {
        switch tree {
        case .leaf:
            return 0
        case .branch(let left, let right):
            return max(depth(tree: left), depth(tree: right)) + 1
        }
    }
}

/*
    연습문제 3.27: List에 정의했던 map과 대응되는 map 함수를 정의하라.
 */
extension Tree {
    func map<A, B>(tree: Tree<A>, f: (A) -> B) -> Tree<B> {
        switch tree {
        case .leaf(let value):
            return .leaf(value: f(value))
        case .branch(let left, let right):
            return .branch(left: map(tree: left, f: f), right: map(tree: right, f: f))
        }
    }
}

/*
    연습문제 3.28: Tree에서 size, maximum, depth, map을 일반화해 이 함수들의 유사한 점을 추상화한 새로운 fold 함수를 작성하라.
                 그리고 이 fold 함수를 사용해, size, maximum, depth, map을 재구현하라.
 */
extension Tree {
    func fold<A, B>(ta: Tree<A>, l: (A) -> B, b: (B, B) -> B) -> B {
        switch ta {
        case .leaf(let value):
            return l(value)
        case .branch(let left, let right):
            return b(fold(ta: left, l: l, b: b), fold(ta: right, l: l, b: b))
        }
    }
    
    func sizeF<A>(ta: Tree<A>) -> Int {
        return fold(ta: ta, l: { _ in 1 }, b: { b1, b2 in 1 + b1 + b2 })
    }
    
    func maximumF(ta: Tree<Int>) -> Int {
        return fold(ta: ta, l: { a in a }, b: { b1, b2 in max(b1, b2) })
    }
    
    func depthF<A>(ta: Tree<A>) -> Int {
        return fold(ta: ta, l: { _ in 0 }, b: { b1, b2 in max(b1, b2) + 1 })
    }
    
    func mapF<A, B>(ta: Tree<A>, f: (A) -> B) -> Tree<B> {
        return fold(ta: ta, l: { a in .leaf(value: f(a)) }, b: { b1, b2 in .branch(left: b1, right: b2) })
    }
}

//
//  Random.swift
//  FP
//
//  Created by changmuk.im@phoenixdarts.com on 2023/10/19.
//

import Foundation

infix operator >>> : BitwiseShiftPrecedence

extension Int {
    static func >>> (lhs: Int, rhs: Int) -> Int {
        return Int(bitPattern: UInt(bitPattern: lhs) >> UInt(rhs))
    }
}

protocol RNG {
    func nextInt() -> (Int, RNG)
}

struct SimpleRNG: RNG {
    let seed: Int

    init(seed: Int) {
        self.seed = seed
    }

    init(_ seed: Int) {
        self.seed = seed
    }

    func nextInt() -> (Int, RNG) {
        let newSeed = (seed &* 0x5DEECE66D &+ 0xB) & ((1 << 48) - 1)
        print(String(newSeed, radix: 16))
        let nextRNG = SimpleRNG(newSeed)
        let n = newSeed >> 16

        return (n, nextRNG)
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        var x = state
        x ^= x &+ 0x9e3779b97f4a7c15
        x ^= (x << 31) &* 0xb5026f5aa96619e9
        x ^= (x << 27) &* 0x68bbc46d56b84e10
        state = x
        return x
    }
}

/*
 연습문제 6.1: RNG.nextInt를 사용해 0 이상 Int.MAX_VALUE 이하의 정수 난수를 생성하는 함수를 작성하라.
 */
extension SimpleRNG {
//    func nonNegativeInt(rng: RNG) -> (Int, RNG) {
//        
//    }
}

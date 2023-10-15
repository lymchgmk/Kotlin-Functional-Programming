//
//  Lazy.swift
//  Kotlin Functional Programming
//
//  Created by lymchgmk on 2023/10/07.
//

import Foundation

func lazyIf<A>(cond: Bool, onTrue: () -> A, onFalse: () -> A) -> A {
    return cond ? onTrue() : onFalse()
}

//let a = 12
//let y: () = lazyIf(cond: a < 22, onTrue: { print("TRUE") }, onFalse: { print("FALSE") })

func maybeTwice1(b: Bool, i: () -> Int) {
    let _ = b ? i() + i() : 0
}

func maybeTwice2(b: Bool, i: () -> Int) {
    lazy var j = i()
    let _ = b ? j + j : 0
}

// let x: () = maybeTwice2(b: true, i: { print("hi"); return 1 + 41 })

//
//  main.swift
//  Kotlin Functional Programming
//
//  Created by lymchgmk on 2023/10/07.
//

import Foundation

let tc1 = Stream<Int>.of(1, 2, 3)
print("[ScanRight]", tc1.scanRight(0, { a, b in a + b() }).toList())


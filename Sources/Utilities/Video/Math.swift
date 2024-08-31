//
//  Math.swift
//
//
//  Created by Joel Tan on 31/8/2024.
//

import CoreGraphics

func cubicInterpolate(p0: CGFloat, p1: CGFloat, p2: CGFloat, p3: CGFloat, t: CGFloat) -> CGFloat {
    let a0 = p3 - p2 - p0 + p1
    let a1 = p0 - p1 - a0
    let a2 = p2 - p0
    return a0 * t * t * t + a1 * t * t + a2 * t + p1
}

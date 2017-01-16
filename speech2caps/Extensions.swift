//
//  Extensions.swift
//  speech2caps
//
//  Created by Tyler Angert on 1/14/17.
//  Copyright © 2017 Tyler Angert. All rights reserved.
//

import Foundation
import UIKit

extension Float {
    
    func Amplitude2dB() -> Float {
        return 20 * log(self) / Float(M_LN10);
    }
    
    func dB2Amplitude() -> Float {
        return pow(10, self / 20);
    }
    
}

//power function shortcut
infix operator ** { associativity left precedence 170 }

func ** (num: Double, power: Double) -> Double{
    return pow(num, power)
}


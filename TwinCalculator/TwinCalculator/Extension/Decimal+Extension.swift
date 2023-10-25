//
//  Decimal+Extension.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/25.
//

import Foundation

extension Decimal {
    func toString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let str = formatter.string(from: self as NSNumber) ?? ""
        return str
    }
}

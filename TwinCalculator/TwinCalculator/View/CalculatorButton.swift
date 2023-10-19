//
//  CalculatorButton.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/17.
//

import UIKit

// MARK: - CalculatorButton
class CalculatorButton: UIButton {
    
    private let title: String
    private let color: UIColor
    
    init(title: String, color: UIColor) {
        self.title = title
        self.color = color
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        backgroundColor = color
        layer.cornerRadius = 10
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - CalculatorButtonItem
enum CalculatorButtonItem {
    case digit(Int)
    case dot
    case `operator`(Operator)
    case command(Command)
    
    enum Command: String {
        case clear = "AC"
        case flip = "+/-"
        case percent = "%"
    }
    
    enum Operator: String {
        case plus = "+"
        case minus = "-"
        case multiply = "x"
        case divide = "÷"
        case equal = "="
    }
}

extension CalculatorButtonItem {
    var title: String {
        switch self {
        case .digit(let int):
            return "\(int)"
        case .dot:
            return "."
        case .operator(let `operator`):
            return `operator`.rawValue
        case .command(let command):
            return command.rawValue
        }
    }
    
    var widthFactor: CGFloat {
        if case .digit(let int) = self, int == 0 {
            return 2
        } else {
            return 1
        }
    }
}

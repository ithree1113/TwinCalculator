//
//  CalculatorButtonPad.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/17.
//

import UIKit

class CalculatorButtonPad: UIView {
    
    private(set) var buttons: [CalculatorButton] = []
    private let pad: [[CalculatorButtonItem]] = [
        [.command(.clear), .command(.flip), .command(.percent), .operator(.divide)],
        [.digit(7), .digit(8), .digit(9), .operator(.multiply)],
        [.digit(4), .digit(5), .digit(6), .operator(.minus)],
        [.digit(1), .digit(2), .digit(3), .operator(.plus)],
        [.digit(0), .dot, .operator(.equal)],
    ]
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = Constants.spacing
        return sv
    }()
    
    init() {
        super.init(frame: .zero)
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pad.forEach { row in
            let rowView = CalculatorButtonRow(row: row)
            stackView.addArrangedSubview(rowView)
            buttons.append(contentsOf: rowView.buttons)
        }
    }
}

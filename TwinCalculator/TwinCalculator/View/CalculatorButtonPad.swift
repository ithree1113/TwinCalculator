//
//  CalculatorButtonPad.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/17.
//

import UIKit

class CalculatorButtonPad: UIView {
    
    private(set) var buttons: [CalculatorButton] = []
    private let rows: [[CalculatorButtonItem]]
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = Constants.spacing
        return sv
    }()
    
    init(rows: [[CalculatorButtonItem]], configStackView: ((UIStackView) -> ())? = nil) {
        self.rows = rows
        super.init(frame: .zero)
        configStackView?(stackView)
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
        
        rows.forEach { row in
            let rowView = CalculatorButtonRow(row: row)
            stackView.addArrangedSubview(rowView)
            buttons.append(contentsOf: rowView.buttons)
        }
    }
}

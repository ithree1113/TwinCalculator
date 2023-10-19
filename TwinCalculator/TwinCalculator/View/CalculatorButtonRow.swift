//
//  CalculatorButtonRow.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/17.
//

import UIKit

class CalculatorButtonRow: UIView {
    
    let row: [CalculatorButtonItem]
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = Constants.spacing
        return sv
    }()
    
    init(row: [CalculatorButtonItem]) {
        self.row = row
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
        
        row.forEach { item in
            let button = CalculatorButton(item: item)
            stackView.addArrangedSubview(button)
        }
        
        for index in 1..<row.count {
            guard let button = stackView.arrangedSubviews[index] as? CalculatorButton else { return }
            let item = row[index]
            if let firstBtn = stackView.arrangedSubviews.first, let firstItem = row.first {
                let ratio = item.widthFactor/firstItem.widthFactor
                button.snp.remakeConstraints { make in
                    make.width
                        .equalTo(firstBtn)
                        .multipliedBy(ratio)
                        .offset((ratio - 1) * Constants.spacing)
                }
            }
        }
    }
}

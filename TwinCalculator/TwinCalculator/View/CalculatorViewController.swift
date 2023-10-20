//
//  CalculatorViewController.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/17.
//

import UIKit

class CalculatorViewController: UIViewController {

    var buttons: [CalculatorButton] {
        return calculatorButtonPad.buttons
    }
    let calculatorButtonPad: CalculatorButtonPad = {
        let cbp = CalculatorButtonPad(rows:[
            [.command(.clear), .command(.flip), .command(.percent), .operator(.divide)],
            [.digit(7), .digit(8), .digit(9), .operator(.multiply)],
            [.digit(4), .digit(5), .digit(6), .operator(.minus)],
            [.digit(1), .digit(2), .digit(3), .operator(.plus)],
            [.digit(0), .dot, .operator(.equal)],
        ])
        return cbp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLatout()
    }
    
    // MARK: Layout
    private func initLatout() {
        view.addSubview(calculatorButtonPad)
        calculatorButtonPad.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(2.0/3.0)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(Constants.spacing)
        }
    }
}

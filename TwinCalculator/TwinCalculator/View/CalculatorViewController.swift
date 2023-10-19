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
    private let calculatorButtonPad: CalculatorButtonPad = {
        let cbp = CalculatorButtonPad()
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

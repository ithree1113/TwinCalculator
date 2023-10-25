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
    let resultLabel: UILabel = {
        let rl = UILabel()
        rl.adjustsFontSizeToFitWidth = true
        rl.minimumScaleFactor = 0.2
        rl.text = "0"
        rl.textColor = .white
        rl.textAlignment = .right
        rl.font = .systemFont(ofSize: 64)
        return rl
    }()
    let processLabel: UILabel = {
        let pl = UILabel()
        pl.adjustsFontSizeToFitWidth = true
        pl.minimumScaleFactor = 0.2
        pl.text = "0"
        pl.textColor = .white
        pl.font = .systemFont(ofSize: 48)
        return pl
    }()
    private var viewModel: CalculatorViewModelPrortocol
    
    // MARK: Init
    init(viewModel: CalculatorViewModelPrortocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLatout()
        addButtonsSelectors()
        bindViewModel()
    }
    
    // MARK: Layout
    private func initLatout() {
        view.addSubview(calculatorButtonPad)
        calculatorButtonPad.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(Constants.padHeightRatio)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(Constants.spacing)
        }
        
        let resultLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(resultLayoutGuide)
        resultLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(calculatorButtonPad)
            make.bottom.equalTo(calculatorButtonPad.snp.top)
        }
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.left.right.centerY.equalTo(resultLayoutGuide)
        }
        
        let processLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(processLayoutGuide)
        processLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(resultLabel.snp.bottom)
            make.left.right.equalTo(calculatorButtonPad)
            make.bottom.equalTo(calculatorButtonPad.snp.top)
        }
        view.addSubview(processLabel)
        processLabel.snp.makeConstraints { make in
            make.left.right.centerY.equalTo(processLayoutGuide)
        }
    }
    
    // MARK: Binding
    private func bindViewModel() {
        viewModel.resultUpdated = { result in
            if result.contains(where: { $0 == "." }) {
                let splits = result.split(separator: ".")
                guard let intValue = Decimal(string: String(splits[0])) else { return }
                
                self.resultLabel.text = intValue.toString() + "."
                if splits.count > 1 {
                    self.resultLabel.text! += String(splits.last ?? "")
                }
            } else if let value = Decimal(string: result) {
                self.resultLabel.text = value.toString()
            } else {
                self.resultLabel.text = result
            }
        }
        
        viewModel.processUpdated = { process in
            self.processLabel.text = process
        }
    }
    
    // MARK: Method
    private func addButtonsSelectors() {
        buttons.forEach { button in
            button.addTarget(self, action: #selector(calculatorButtonDidTap(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func calculatorButtonDidTap(_ sender: CalculatorButton) {
        viewModel.acceptButtonInput(sender.item)
    }
}

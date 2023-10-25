//
//  ContainerViewController.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/17.
//

import UIKit
import SnapKit

class ContainerViewController: UIViewController {
    
    // MARK: Component
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leftCalculator.view, centerView, rightCalculator.view])
        sv.distribution = .fill
        sv.spacing = Constants.spacing
        return sv
    }()
    private let leftCalculator: CalculatorViewController = {
        let lc = CalculatorViewController(viewModel: CalculatorViewModel())
        lc.view.backgroundColor = .black
        return lc
    }()
    private let centerView: UIView = {
        let cv = UIView()
        cv.isHidden = true
        return cv
    }()
    private let centerPad: CalculatorButtonPad = {
        let cp = CalculatorButtonPad(rows: [
            [.function(.toLeft)],
            [.function(.toRight)],
            [.blank],
            [.command(.delete)],
        ],
                                     configStackView: { stackView in
            stackView.distribution = .equalSpacing
        })
        return cp
    }()
    private let rightCalculator: CalculatorViewController = {
        let rc = CalculatorViewController(viewModel: CalculatorViewModel())
        rc.view.backgroundColor = .black
        rc.view.isHidden = true
        return rc
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
        handleTrait(view.traitCollection)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.handleTrait(newCollection)
        })
    }
    
    // MARK: Layout
    private func initLayout() {
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        leftCalculator.view.snp.makeConstraints { make in
            make.width.equalTo(rightCalculator.view)
        }
        
        centerView.addSubview(centerPad)
        centerPad.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(leftCalculator.calculatorButtonPad.snp.height)
        }
        if let buttonToLayout = leftCalculator.buttons.first(where: { $0.item.widthFactor == 1 }) {
            centerPad.buttons.forEach { centerButton in
                centerButton.snp.makeConstraints { make in
                    make.size.equalTo(buttonToLayout)
                }
            }
        }
    }
    
    // MARK: Method
    private func handleTrait(_ traitCollection: UITraitCollection) {
        if traitCollection.verticalSizeClass == .regular {
            centerView.isHidden = true
            rightCalculator.view.isHidden = true
        } else {
            centerView.isHidden = false
            rightCalculator.view.isHidden = false
        }
    }
}

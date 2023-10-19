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
        return sv
    }()
    private let leftCalculator: CalculatorViewController = {
        let lc = CalculatorViewController()
        lc.view.backgroundColor = .black
        return lc
    }()
    private let centerView: UIView = {
        let cv = UIView()
        cv.backgroundColor = .gray
        cv.isHidden = true
        return cv
    }()
    private let rightCalculator: CalculatorViewController = {
        let rc = CalculatorViewController()
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
        centerView.snp.makeConstraints { make in
            make.width.equalTo(40)
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

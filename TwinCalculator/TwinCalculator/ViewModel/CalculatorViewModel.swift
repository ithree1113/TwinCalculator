//
//  CalculatorViewModel.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/20.
//

import Foundation

// MARK: - CalculatorViewModelPrortocol
protocol CalculatorViewModelPrortocol {
    
    var resultUpdated: ((String, Int) -> Void)? { get set }
    var processUpdated: ((String) -> Void)? { get set }
    
    func acceptButtonInput(_ input: CalculatorButtonItem)
    func getOperand() -> Decimal
    func setOperand(_ operand: Decimal)
    func reset()
}

// MARK: - CalculatorViewModel
class CalculatorViewModel: CalculatorViewModelPrortocol {

    var resultUpdated: ((String, Int) -> Void)?
    var processUpdated: ((String) -> Void)?
    fileprivate var state: CalculatorStateProtocol?
    fileprivate var firstOperand: Decimal = 0
    fileprivate var secondOperand: Decimal? = nil
    fileprivate var oprator: CalculatorButtonItem.Operator? = nil
    fileprivate var fractionDigits: Int = 0
    fileprivate var isPercent: Bool = false
    
    init() {
        state = FirstOperandState(context: self)
    }
    
    func acceptButtonInput(_ input: CalculatorButtonItem) {
        switch input {
        case .digit(let digit):
            state?.acceptDigit(digit)
        case .dot:
            state?.acceptDot()
        case .operator(let op):
            state?.acceptOperator(op)
        case .command(let command):
            handleCommand(command)
        case .function, .blank:
            break
        }
    }
    
    func getOperand() -> Decimal {
        return state!.getOperand()
    }
    
    func setOperand(_ operand: Decimal) {
        state?.setOperand(operand)
    }
    
    fileprivate func changeState(_ state: CalculatorStateProtocol) {
        self.state = state
    }
    
    fileprivate func handleCommand(_ command: CalculatorButtonItem.Command) {
        fractionDigits = 0
        switch command {
        case .clear:
            resultUpdated?("0", 0)
            processUpdated?("0")
            changeState(FirstOperandState(context: self))
        case .flip:
            handleFlip()
        case .percent:
            handlePercent()
        case .delete:
            break
        }
    }
    
    fileprivate func handleFlip() {
        guard let state = state else { return }
        state.setOperand(-state.getOperand())
        resultUpdated?("\(state.getOperand())", 0)
        showProcess(firstOperand: firstOperand, op: oprator?.rawValue, secondOperand: secondOperand)
    }
    
    fileprivate func handlePercent() {
        guard let state = state else { return }
        isPercent = true
        state.setOperand(state.getOperand()/100)
        resultUpdated?("\(state.getOperand())", 0)
        showProcess(firstOperand: firstOperand, op: oprator?.rawValue, secondOperand: secondOperand)
    }
    
    fileprivate func showProcess(firstOperand: Decimal, op: String? = nil, secondOperand: Decimal? = nil, result: Decimal? = nil) {
        let firstString = "\(firstOperand)"
        let operatorString = op == nil ? "" : op!
        let secondString = secondOperand == nil ? "" : String(describing: secondOperand!)
        let resultString = result == nil ? "" : "=" + String(describing: result!)
        processUpdated?(firstString + operatorString + secondString + resultString)
    }
    
    func reset() {
        firstOperand = 0
        secondOperand = nil
        oprator = nil
        fractionDigits = 0
        isPercent = false
    }
}

// MARK: - CalculatorStateProtocol
protocol CalculatorStateProtocol {
    
    func acceptDigit(_ digit: Int)
    func acceptDot()
    func acceptOperator(_ op: CalculatorButtonItem.Operator)
    func getOperand() -> Decimal
    func setOperand(_ operand: Decimal)
}

// MARK: - FirstOperandState
private class FirstOperandState: CalculatorStateProtocol {
    
    unowned var context: CalculatorViewModel
    
    init(context: CalculatorViewModel) {
        self.context = context
        context.reset()
    }
    
    func acceptDigit(_ digit: Int) {
        if context.isPercent {
            context.isPercent = false
            context.firstOperand = Decimal(digit)
        } else if context.fractionDigits == 0 {
            context.firstOperand = context.firstOperand * 10 + Decimal(digit)
        } else {
            context.firstOperand = context.firstOperand + Decimal(digit) / pow(10, context.fractionDigits)
            context.fractionDigits += 1
        }
        updateInfo()
    }
    
    func acceptDot() {
        if context.firstOperand == 0 || context.isPercent {
            context.isPercent = false
            context.fractionDigits = 0
            context.firstOperand = 0
        }
        guard context.fractionDigits == 0 else { return }
        context.fractionDigits += 1
        
        context.resultUpdated?("\(context.firstOperand)", context.fractionDigits)
    }
    
    func acceptOperator(_ op: CalculatorButtonItem.Operator) {
        guard op != .equal else {
            return
        }
        context.oprator = op
        context.changeState(SecondOperandState(context: context))
        context.showProcess(firstOperand: context.firstOperand, op: op.rawValue)
    }
    
    func getOperand() -> Decimal {
        return context.firstOperand
    }
    
    func setOperand(_ operand: Decimal) {
        context.firstOperand = operand
        updateInfo()
    }
    
    private func updateInfo() {
        context.resultUpdated?("\(context.firstOperand)", context.fractionDigits)
        context.showProcess(firstOperand: context.firstOperand)
    }
}

// MARK: - SecondOperandState
private class SecondOperandState: CalculatorStateProtocol {

    unowned var context: CalculatorViewModel

    init(context: CalculatorViewModel) {
        self.context = context
        context.isPercent = false
        context.fractionDigits = 0
    }

    func acceptDigit(_ digit: Int) {
        if context.secondOperand == nil || context.isPercent {
            context.isPercent = false
            context.secondOperand = Decimal(digit)
        } else if context.fractionDigits == 0 {
            context.secondOperand = context.secondOperand! * 10 + Decimal(digit)
        } else {
            context.secondOperand = context.secondOperand! + Decimal(digit) / pow(10, context.fractionDigits)
            context.fractionDigits += 1
        }
        updateInfo()
    }
    
    func acceptDot() {
        if context.secondOperand == 0 || context.secondOperand == nil || context.isPercent {
            context.isPercent = false
            context.fractionDigits = 0
            context.secondOperand = 0
        }
        guard context.fractionDigits == 0 else { return }
        context.fractionDigits += 1
        
        context.resultUpdated?("\(context.secondOperand!)", context.fractionDigits)
    }
    
    func acceptOperator(_ op: CalculatorButtonItem.Operator) {
        if context.secondOperand == nil {
            context.secondOperand = context.firstOperand
        }
        var result: Decimal = 0
        do {
            guard let ope = context.oprator else { throw CalculatorButtonItem.OperatorError.noFunction }
            result = try ope.calculate(x: context.firstOperand, y: context.secondOperand!)
            updateInfo(result: result)
        } catch CalculatorButtonItem.OperatorError.divisorIsZero {
            context.resultUpdated?("No number", 0)
        } catch {
            
        }
        let newState = FirstOperandState(context: context)
        context.changeState(newState)
        context.firstOperand = result
        newState.acceptOperator(op)
    }
    
    func getOperand() -> Decimal {
        if let secondOperand = context.secondOperand {
            return secondOperand
        } else {
            return context.firstOperand
        }
    }
    
    func setOperand(_ operand: Decimal) {
        context.secondOperand = operand
        updateInfo()
    }
    
    private func updateInfo(result: Decimal? = nil) {
        if let result = result {
            context.resultUpdated?("\(result)", 0)
        } else {
            context.resultUpdated?("\(context.secondOperand ?? 0)", context.fractionDigits)
        }
        
        context.showProcess(firstOperand: context.firstOperand,
                            op: context.oprator?.rawValue,
                            secondOperand: context.secondOperand,
                            result: result)
    }
}

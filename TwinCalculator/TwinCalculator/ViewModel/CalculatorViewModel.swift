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
    fileprivate var state: CalculatorState?
    
    init() {
        state = CalculatorState(context: self, previousOperand: 0)
    }
    
    func acceptButtonInput(_ input: CalculatorButtonItem) {
        state?.acceptButtonInput(input)
    }
    
    func getOperand() -> Decimal {
        return state?.currentOperand ?? state?.previousOperand ?? 0
    }
    
    func setOperand(_ operand: Decimal) {
        state?.currentOperand = operand
    }
    
    fileprivate func changeState(_ state: CalculatorState) {
        self.state = state
    }
    
//    fileprivate func handleCommand(_ command: CalculatorButtonItem.Command) {
//        switch command {
//        case .clear:
//            resultUpdated?("0")
//            processUpdated?("0")
//            changeState(FirstOperandState(context: self))
//        case .flip:
//            handleFlip()
//        case .percent:
//            handlePercent()
//        case .delete:
//            break
//        }
//    }
    
//    fileprivate func handleFlip() {
//        guard let state = state else { return }
//        state.setOperand(-state.getOperand())
//        resultUpdated?("\(state.getOperand())")
//        showProcess(firstOperand: firstOperand, op: oprator?.rawValue, secondOperand: secondOperand)
//    }
    
//    fileprivate func handlePercent() {
//        guard let state = state else { return }
//        isPercent = true
//        state.setOperand(state.getOperand()/100)
//        resultUpdated?("\(state.getOperand())")
//        showProcess(firstOperand: firstOperand, op: oprator?.rawValue, secondOperand: secondOperand)
//    }
    
//    fileprivate func showProcess(firstOperand: Decimal, op: String? = nil, secondOperand: Decimal? = nil, result: Decimal? = nil) {
//        let firstString = "\(firstOperand)"
//        let operatorString = op == nil ? "" : op!
//        let secondString = secondOperand == nil ? "" : String(describing: secondOperand!)
//        let resultString = result == nil ? "" : "=" + String(describing: result!)
//        processUpdated?(firstString + operatorString + secondString + resultString)
//    }
    
    func reset() {
        changeState(CalculatorState(context: self, previousOperand: 0))
    }
}

// MARK: - CalculatorStateProtocol
//protocol CalculatorStateProtocol {
//
//    func acceptDigit(_ digit: Int)
//    func acceptDot()
//    func acceptOperator(_ op: CalculatorButtonItem.Operator)
//    func getOperand() -> Decimal
//    func setOperand(_ operand: Decimal)
//}

// MARK: - FirstOperandState
//private class FirstOperandState: CalculatorStateProtocol {
//
//    unowned var context: CalculatorViewModel
//
//    init(context: CalculatorViewModel) {
//        self.context = context
//        context.reset()
//    }
//
//    func acceptDigit(_ digit: Int) {
//        if context.isPercent {
//            context.isPercent = false
//            context.firstOperand = Decimal(digit)
//        } else if context.fractionDigits == 0 {
//            context.firstOperand = context.firstOperand * 10 + Decimal(digit)
//        } else {
//            context.firstOperand = context.firstOperand + Decimal(digit) / pow(10, context.fractionDigits)
//            context.fractionDigits += 1
//        }
//        updateInfo()
//    }
//
//    func acceptDot() {
//        if context.firstOperand == 0 || context.isPercent {
//            context.isPercent = false
//            context.fractionDigits = 0
//            context.firstOperand = 0
//        }
//        guard context.fractionDigits == 0 else { return }
//        context.fractionDigits += 1
//
//        context.resultUpdated?("\(context.firstOperand).")
//    }
//
//    func acceptOperator(_ op: CalculatorButtonItem.Operator) {
//        guard op != .equal else {
//            return
//        }
//        context.oprator = op
//        context.changeState(SecondOperandState(context: context))
//        context.showProcess(firstOperand: context.firstOperand, op: op.rawValue)
//    }
//
//    func getOperand() -> Decimal {
//        return context.firstOperand
//    }
//
//    func setOperand(_ operand: Decimal) {
//        context.firstOperand = operand
//        updateInfo()
//    }
//
//    private func updateInfo() {
//        var valueString = "\(context.firstOperand)"
//        if context.fractionDigits != 0, context.firstOperand == 0 {
//            valueString += "."
//            for _ in 1..<context.fractionDigits {
//                valueString += "0"
//            }
//        }
//        context.resultUpdated?(valueString)
//        context.showProcess(firstOperand: context.firstOperand)
//    }
//}

// MARK: - SecondOperandState
//private class SecondOperandState: CalculatorStateProtocol {
//
//    unowned var context: CalculatorViewModel
//
//    init(context: CalculatorViewModel) {
//        self.context = context
//        context.isPercent = false
//        context.fractionDigits = 0
//    }
//
//    func acceptDigit(_ digit: Int) {
//        if context.secondOperand == nil || context.isPercent {
//            context.isPercent = false
//            context.secondOperand = Decimal(digit)
//        } else if context.fractionDigits == 0 {
//            context.secondOperand = context.secondOperand! * 10 + Decimal(digit)
//        } else {
//            context.secondOperand = context.secondOperand! + Decimal(digit) / pow(10, context.fractionDigits)
//            context.fractionDigits += 1
//        }
//        updateInfo()
//    }
//
//    func acceptDot() {
//        if context.secondOperand == 0 || context.secondOperand == nil || context.isPercent {
//            context.isPercent = false
//            context.fractionDigits = 0
//            context.secondOperand = 0
//        }
//        guard context.fractionDigits == 0 else { return }
//        context.fractionDigits += 1
//
//        context.resultUpdated?("\(context.secondOperand!).")
//    }
//
//    func acceptOperator(_ op: CalculatorButtonItem.Operator) {
//        if context.secondOperand == nil {
//            context.secondOperand = context.firstOperand
//        }
//        var result: Decimal = 0
//        do {
//            guard let ope = context.oprator else { throw CalculatorButtonItem.OperatorError.noFunction }
//            result = try ope.calculate(x: context.firstOperand, y: context.secondOperand!)
//            updateInfo(result: result)
//        } catch CalculatorButtonItem.OperatorError.divisorIsZero {
//            context.resultUpdated?("No number")
//        } catch {
//
//        }
//        let newState = FirstOperandState(context: context)
//        context.changeState(newState)
//        context.firstOperand = result
//        newState.acceptOperator(op)
//    }
//
//    func getOperand() -> Decimal {
//        if let secondOperand = context.secondOperand {
//            return secondOperand
//        } else {
//            return context.firstOperand
//        }
//    }
//
//    func setOperand(_ operand: Decimal) {
//        context.secondOperand = operand
//        updateInfo()
//    }
//
//    private func updateInfo(result: Decimal? = nil) {
//        if let result = result {
//            context.resultUpdated?("\(result)")
//        } else {
//            var valueString = "\(context.secondOperand!)"
//            if context.fractionDigits != 0, context.secondOperand == 0 {
//                valueString += "."
//                for _ in 1..<context.fractionDigits {
//                    valueString += "0"
//                }
//            }
//            context.resultUpdated?("\(valueString)")
//        }
//
//        context.showProcess(firstOperand: context.firstOperand,
//                            op: context.oprator?.rawValue,
//                            secondOperand: context.secondOperand,
//                            result: result)
//    }
//}

private class CalculatorState {
    unowned var context: CalculatorViewModel
    var previousOperand: Decimal
    var currentOperand: Decimal? = nil
    var oprator: CalculatorButtonItem.Operator?
    var fractionDigits: Int = 0
    var isPercent: Bool = false

    init(context: CalculatorViewModel, previousOperand: Decimal, oprator: CalculatorButtonItem.Operator? = nil) {
        self.context = context
        self.previousOperand = previousOperand
        self.oprator = oprator
    }

    func acceptButtonInput(_ input: CalculatorButtonItem) {
        switch input {
        case .digit(let digit):
            handleDigit(digit)
        case .dot:
            handleDot()
        case .operator(let op):
            handleOperator(op)
        case .command(let command):
            handleCommand(command)
        case .function, .blank:
            break
        }
    }

    func handleDigit(_ digit: Int) {
        let digitDecimal = Decimal(digit)
        if isPercent {
            isPercent = false
            currentOperand = digitDecimal
        } else if fractionDigits == 0 {
            currentOperand = (currentOperand ?? 0) * 10 + digitDecimal
        } else {
            currentOperand = (currentOperand ?? 0) + digitDecimal / pow(10, fractionDigits)
            fractionDigits += 1
        }

        context.resultUpdated?("\(currentOperand!)", fractionDigits)
        showProcess()
    }

    func handleDot() {
        if isPercent || currentOperand == nil {
            isPercent = false
            fractionDigits = 0
            currentOperand = 0
        }
        guard fractionDigits == 0 else { return }
        fractionDigits += 1

        context.resultUpdated?("\(currentOperand!)", fractionDigits)
    }

    func handleOperator(_ op: CalculatorButtonItem.Operator) {
        if currentOperand == nil {
            if op == .equal {
                currentOperand = previousOperand
            } else {
                oprator = op
                showProcess()
                return
            }
        }
        if let oprator = oprator {
            do {
                let result = try oprator.calculate(x: previousOperand, y: currentOperand!)
                let newState = CalculatorState(context: context, previousOperand: result, oprator: op)
                context.changeState(newState)
                context.resultUpdated?("\(result)", 0)
                showProcess(result: result)
            } catch CalculatorButtonItem.OperatorError.divisorIsZero {
                context.resultUpdated?("Not number", 0)
            } catch {

            }
        } else {
            let newState = CalculatorState(context: context, previousOperand: currentOperand!, oprator: op)
            context.changeState(newState)
            newState.showProcess()
        }
    }

    fileprivate func handleCommand(_ command: CalculatorButtonItem.Command) {
        fractionDigits = 0
        switch command {
        case .clear:
            context.resultUpdated?("0", 0)
            context.processUpdated?("0")
            context.changeState(CalculatorState(context: context, previousOperand: 0))
        case .flip:
            handleFlip()
        case .percent:
            handlePercent()
        case .delete:
            break
        }
    }

    func handleFlip() {
        if currentOperand == nil {
            currentOperand = previousOperand
        }
        currentOperand = -currentOperand!
        context.resultUpdated?("\(currentOperand!)", 0)
        showProcess()
    }

    func handlePercent() {
        isPercent = true
        if currentOperand == nil {
            currentOperand = previousOperand
        }
        currentOperand! /= 100
        context.resultUpdated?("\(currentOperand!)", 0)
        showProcess()
    }

    fileprivate func showProcess(result: Decimal? = nil) {
        if let oprator = oprator {
            let firstString = "\(previousOperand)"
            let operatorString = oprator.rawValue
            let secondString = currentOperand == nil ? "" : String(describing: currentOperand!)
            let resultString = result == nil ? "" : "=" + String(describing: result!)
            context.processUpdated?(firstString + operatorString + secondString + resultString)
        } else {
            context.processUpdated?(currentOperand == nil ? "" : String(describing: currentOperand!))
        }
    }
}

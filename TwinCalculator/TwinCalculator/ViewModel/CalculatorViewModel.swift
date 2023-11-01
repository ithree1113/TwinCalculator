//
//  CalculatorViewModel.swift
//  TwinCalculator
//
//  Created by eddiecheng on 2023/10/20.
//

import Foundation

// MARK: - CalculatorViewModelPrortocol
protocol CalculatorViewModelPrortocol {
    
    var resultUpdated: ((String) -> Void)? { get set }
    var processUpdated: ((String) -> Void)? { get set }
    
    func acceptButtonInput(_ input: CalculatorButtonItem)
    func getOperand() -> Decimal
    func setOperand(_ operand: Decimal)
    func reset()
}

// MARK: - CalculatorViewModel
class CalculatorViewModel: CalculatorViewModelPrortocol {

    var resultUpdated: ((String) -> Void)?
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
        switch command {
        case .clear:
            resultUpdated?("0")
            processUpdated?("0")
            changeState(FirstOperandState(context: self))
        case .flip:
            state?.acceptFlip()
        case .percent:
            state?.acceptPercent()
        case .delete:
            break
        }
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
    func acceptFlip()
    func acceptPercent()
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
        
        context.resultUpdated?("\(context.firstOperand).")
    }
    
    func acceptOperator(_ op: CalculatorButtonItem.Operator) {
        guard op != .equal else {
            return
        }
        context.oprator = op
        context.changeState(SecondOperandState(context: context))
        context.showProcess(firstOperand: context.firstOperand, op: op.rawValue)
    }
    
    func acceptFlip() {
        context.firstOperand = -context.firstOperand
        updateInfo()
    }
    
    func acceptPercent() {
        context.isPercent = true
        context.firstOperand /= 100
        updateInfo()
    }
    
    func getOperand() -> Decimal {
        return context.firstOperand
    }
    
    func setOperand(_ operand: Decimal) {
        context.firstOperand = operand
        updateInfo()
    }
    
    private func updateInfo() {
        var valueString = "\(context.firstOperand)"
        if context.fractionDigits != 0, context.firstOperand == 0 {
            valueString += "."
            for _ in 1..<context.fractionDigits {
                valueString += "0"
            }
        }
        context.resultUpdated?(valueString)
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
        
        context.resultUpdated?("\(context.secondOperand!).")
    }
    
    func acceptOperator(_ op: CalculatorButtonItem.Operator) {
        guard op == .equal else {
            context.oprator = op
            context.showProcess(firstOperand: context.firstOperand, op: op.rawValue)
            return
        }
        if context.secondOperand == nil {
            context.secondOperand = context.firstOperand
        }
        var result: Decimal = 0
        do {
            guard let ope = context.oprator else { throw CalculatorButtonItem.OperatorError.noFunction }
            result = try ope.calculate(x: context.firstOperand, y: context.secondOperand!)
            updateInfo(result: result)
        } catch CalculatorButtonItem.OperatorError.divisorIsZero {
            context.resultUpdated?("No number")
        } catch {
            
        }
        context.changeState(FirstOperandState(context: context))
        context.firstOperand = result
    }
    
    func acceptFlip() {
        if context.secondOperand == nil {
            context.secondOperand = context.firstOperand
        }
        context.secondOperand = -context.secondOperand!
        updateInfo()
    }
    
    func acceptPercent() {
        context.isPercent = true
        if context.secondOperand == nil {
            context.secondOperand = context.firstOperand
        }
        context.secondOperand! /= 100
        updateInfo()
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
            context.resultUpdated?("\(result)")
        } else {
            var valueString = "\(context.secondOperand!)"
            if context.fractionDigits != 0, context.secondOperand == 0 {
                valueString += "."
                for _ in 1..<context.fractionDigits {
                    valueString += "0"
                }
            }
            context.resultUpdated?("\(valueString)")
        }
        
        context.showProcess(firstOperand: context.firstOperand,
                            op: context.oprator?.rawValue,
                            secondOperand: context.secondOperand,
                            result: result)
    }
}

//private class CalculatorState: CalculatorStateProtocol {
//    unowned var context: CalculatorViewModel
//    var currentOperand: Decimal?
//    var dotDecimal: Decimal = 0
//    var processString: String = ""
//    var isPercent: Bool = false
//
//    init(context: CalculatorViewModel) {
//        self.context = context
//    }
//
//    func acceptInput(_ input: CalculatorButtonItem) {
//        switch input {
//        case .digit(let value):
//            handleDigit(Decimal(value))
//        case .dot:
//            handleDot()
//        case .operator(let op):
//            handleOperator(op)
//        case .command(let command):
//            handleCommand(command)
//        default:
//            break
//        }
//    }
//
//    func handleDigit(_ digit: Decimal) {
//        if currentOperand == 0 || isPercent {
//            isPercent = false
//            currentOperand = digit
//        } else if dotDecimal == 0 {
//            currentOperand = currentOperand * 10 + digit
//        } else {
//            currentOperand = currentOperand + digit / dotDecimal
//            dotDecimal *= 10
//        }
//        context.resultUpdated?("\(currentOperand)")
//    }
//
//    func handleDot() {
//        if currentOperand == 0 || isPercent {
//            isPercent = false
//            dotDecimal = 0
//            currentOperand = 0
//        }
//        guard dotDecimal == 0 else { return }
//        dotDecimal = 10
//        context.resultUpdated?("\(currentOperand).")
//    }
//
//    func handleOperator(_ op: CalculatorButtonItem.Operator) {
//
//    }
//
//    func handleCommand(_ command: CalculatorButtonItem.Command) {
//        if command == .clear {
//            currentOperand = 0
//            processString = "0"
//            context.resultUpdated?("\(currentOperand)")
//            context.processUpdated?(processString)
//        } else if command == .percent {
//            isPercent = true
//            currentOperand /= 100
//            context.resultUpdated?("\(currentOperand)")
//        }
//    }
//}
//

//
//    override func handleDot() {
//        super.handleDot()
//    }
//
//    override func handleOperator(_ op: CalculatorButtonItem.Operator) {
//        guard op != .equal else { return }
//        super.handleOperator(op)
//        context.changeState(SecondOperandState(context: context, previousOperand: currentOperand, oprator: op))
//    }
//
//    override func handleCommand(_ command: CalculatorButtonItem.Command) {
//        super.handleCommand(command)
//    }

////    func acceptInput(_ input: CalculatorButtonItem) {
////        switch input {
////        case .digit(let value):
////
////            secondOperand = secondOperand * 10 + Decimal(value)
////            context.resultUpdated?("\(secondOperand)")
////        case .dot:
////            guard dotPower == 0 else { return }
////            dotPower = 10
////            context.resultUpdated?("\(secondOperand).")
////        case .operator(let `operator`):
////            handleOperator(`operator`)
////        case .command(let command):
////            handleCommand(command)
////        default:
////            break
////        }
////    }
//
//    override func handleOperator(_ op: CalculatorButtonItem.Operator) {
//        super.handleOperator(op)
//
//    }
//
////    private func handleCommand(_ command: CalculatorButtonItem.Command) {
////
////    }

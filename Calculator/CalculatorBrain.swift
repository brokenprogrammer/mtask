//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Oskar Mendel on 1/19/16.
//  Copyright © 2016 Oskar Mendel. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible{
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = Dictionary<String, Op>() // Can be initalized like an array " = [String:Op]()"
    
    init() {
        knownOps["*"] = Op.BinaryOperation("*", {$0 * $1})
        knownOps["÷"] = Op.BinaryOperation("÷", { (op1, op2) in return op2 / op1 })
        knownOps["+"] = Op.BinaryOperation("+", {$0 + $1})
        knownOps["-"] = Op.BinaryOperation("-", {$1 - $0})
        knownOps["√"] = Op.UnaryOperation("√", {sqrt($0)})
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func preformOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func evaluate() -> Double? {
        let (result, remaining) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remaining) left over.")
        return result
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remaining: [Op]) {
        
        if (!ops.isEmpty){
            var remaining = ops
            let op = remaining.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remaining)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remaining)
                
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remaining)
                }
                
            case .BinaryOperation(_, let operation1):
                let op1Evaluation = evaluate(remaining)
                
                if let  operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remaining)
                    
                    if let operand2 = op2Evaluation.result {
                        return (operation1(operand1, operand2), op2Evaluation.remaining)
                    }
                }
                
            }
        }
        return (nil, ops)
    }
}
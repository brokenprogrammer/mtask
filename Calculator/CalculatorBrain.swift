//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Oskar Mendel on 1/19/16.
//  Copyright © 2016 Oskar Mendel. All rights reserved.
//

import Foundation
/*
 * CalculatorBrain
 * This is the model in our MVC that preforms the backend operations
 * this will act as our brain which makes all the calculations.
 */

class CalculatorBrain {
    var description: String {
        get {
            var history = [String]()
            var contents = opStack
            var info = evaluateDescription(contents)
            
            repeat {
            if (info.result != nil) {
                //history = info.result! + ", " + history
                //history.append(info.result!)
                history.insert(info.result!, atIndex: 0)
                contents = info.remaining
                info = evaluateDescription(contents)
                }
            } while(contents.count > 0)
            
            //print(history)
            return history.joinWithSeparator(", ")
            
        }
    }
    
    /*
     * Op is an enumeration that holds the different types of Operations our
     * calculator can make. 
     * Operand: Is a value that the calculator can work with. 
     * UnaryOperation: Is a one parameter function that manipulates one value, for example sqrt.
     * BinaryOperation: Is a two parameter function that works with two values, for example *. 
     *
     * The Op enum inherits the CustomStringConvertible which is the new "Printable".
     * It handles cases of how the different cases should be converted to strings. 
     * The operands are numbers so they can just be converted normally, the functions are converted
     * by using their symbols.
     */
    private enum Op: CustomStringConvertible{
        case Operand(Double)
        case Variable(String)
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
        
        /*
         * Precedence
         * This is a way for us to organize the order of how the calulation history should be shown.
         * For example in the calculation of 3 * 5 + 4 the history should look like 3 * (5 + 4)
         * So what Precedence is doing is that it returns a Integer value depending on what type the Op is
         * if the Op is for example a Operand, Variable, Constant or a UnaryOperation we want the Precedence
         * to be the max value since theese are always prioritized.
         * 
         * Multiplication & Division also have the max value since in the recuring evaluation of the 
         * description the loop will check if the currently checked Op has a higher Precedence than the next one
         * if that is the case the value currently being calculated will get parentesis appended to it.
         * This will only become true if there is a division or multiplication combined with any other kind of operation.
         *
         */
        var precedence: Int {
            get {
                switch self {
                case .Operand(_), .Variable(_), .Constant(_, _), .UnaryOperation(_, _):
                    return Int.max
                case .BinaryOperation(let symbol, _):
                    switch symbol {
                        case "*":
                        return Int.max
                        case "÷":
                        return Int.max
                    default:
                        return Int.min
                    }
                }
            }
        }
    }
    
    private let missingValueSign = "?"
    private var opStack = [Op]()                      // opStack is the stack of Operations in the order they are added.
    private var knownOps = Dictionary<String, Op>()   // knownOps uses the operation symbols as keys and operation function as values.
    var variableValues = Dictionary<String, Double>() //variableValues holds variables the user pushes to the opStack with their values
    
    /*
     * CalculatorBrain Initializer
     * Here we are appending the knownOps dictionary to remember all the operations,
     * the operations are of the Op enum and stores different types of Op functions
     * as values. For example an UnaryOperation that returns the square root of target value.
     */
    init() {
        knownOps["*"] = Op.BinaryOperation("*", {$0 * $1})
        knownOps["÷"] = Op.BinaryOperation("÷", { (op1, op2) in return op2 / op1 })
        knownOps["+"] = Op.BinaryOperation("+", {$0 + $1})
        knownOps["-"] = Op.BinaryOperation("-", {$1 - $0})
        knownOps["√"] = Op.UnaryOperation("√", {sqrt($0)})
        knownOps["sin"] = Op.UnaryOperation("sin", {sin($0)})
        knownOps["cos"] = Op.UnaryOperation("cos", {cos($0)})
        knownOps["±"] = Op.UnaryOperation("±", {(value) in
            if(value>0) {
                return value * -1
            }
            return abs(value)})
        knownOps["π"] = Op.Constant("π", M_PI)
        //variableValues["x"] = 10
        //pushOperand("x")
    }
    
    /*
     * pushOperand
     * This function pushes an operand to our opStack and then returns the function
     * evaluate which will evaluate the entire stack. 
     *
     * @param operand - A double that will represent a number the calculator can work with.
     * @returns evaluate() - A function that evaluates the entire opStack.
     */
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    /*
    * pushOperand
    * This function pushes an variable to our opStack and then returns the function
    * evaluate which will evaluate the entire stack.
    *
    * @param symbol - A String that will represent a varialbe the calculator can work with.
    * @returns evaluate() - A function that evaluates the entire opStack.
    */
    func pushOperand(symbol: String) -> Double? {
        //if variableValues[symbol] != nil {
            opStack.append(Op.Variable(symbol))
        //}
        return evaluate()
    }
    
    /*
     * preformOperation
     * This function pushes an operation to our opStack by using the knownOps dicionary,
     * then calls the evaluate which will evaluate the entire stack.
     *
     * @param symbol - A String representing a mathematical operation like "+" or "√"
     * @returns evaluate() - A function that evaluates the entire opStack.
     */
    func preformOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    /*
     * evaluate
     * This function is calling an overloaded function that recursively works through
     * the entire opStack using the Operands and Operations that got appended to it and
     * returns the result of the entire opStack.
     *
     * @returns Double? - The result of evaluating the entire stack.
     */
    func evaluate() -> Double? {
        let (result, remaining) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remaining) left over.")
        return result
    }
    
    /*
     * evaluate
     * This function is an overloaded version of evaluate that uses this class
     * opStack to recursively work through the array combining operands with operations.
     * The way this functions uses recursion is by using a copy of the opStack and uses the
     * removeLast function to decrement the array.
     *
     * @returns a touple containing the result and the remaining opStack
     * in failiure returns a touple with nil as the first value setting the result optional
     * to non existing.
     */
    private func evaluate(ops: [Op]) -> (result: Double?, remaining: [Op]) {
        
        if (!ops.isEmpty){
            var remaining = ops
            let op = remaining.removeLast()
            
            // Switches over the removed value that remaining.removeLast() returns.
            switch op {
            case .Operand(let operand):                 //If its an Operand then we can just return it together with the remaining opStack
                return (operand, remaining)
                
            case .Variable(let symbol):                 //If its an variable we can just return the value of that variable.
                if let variable = variableValues[symbol] {
                    return (variable, remaining)
                }
                print("Returned Nil")
                return (nil, remaining)
                
            case .Constant(_, let operand):
                return (operand, remaining)
                
            case .UnaryOperation(_, let operation):     //If its an UnaryOperation we use the operation function for this operation.
                
                //We got sqrt now we look whats behind it in the array to know which operand we should apply it to.
                let operandEvaluation = evaluate(remaining)
                
                //If the rest of the values could be evaluated we use the operand result it returned.
                if let operand = operandEvaluation.result {
                    //Then returns the new result which is the operation for this UnaryOperation.
                    return (operation(operand), operandEvaluation.remaining)
                }
                
            case .BinaryOperation(_, let operation):   //If its an BinaryOperation we use the operation function for this operation.
                
                //Look behind the current operation in the opStack using the remaining variable to see what operands we apply this operation to
                let op1Evaluation = evaluate(remaining)
                
                //First operand we finds is the op1Evaluations result.
                if let  operand1 = op1Evaluation.result {
                    //Then we need a second operand for the BinaryOperation so we evaluate using op1Evaluations remainder.
                    let op2Evaluation = evaluate(op1Evaluation.remaining)
                    
                    //If we found a second operand we use the result.
                    if let operand2 = op2Evaluation.result {
                        //Returns the operation using operand1 and operand2 as well as the remainder for op2Evaluation since its used last.
                        return (operation(operand1, operand2), op2Evaluation.remaining)
                    }
                }
                
            }
        }
        return (nil, ops)
    }
    
    private func evaluateDescription(opss: [Op]) -> (result: String?, remaining: [Op]) {
        
        if (!opss.isEmpty) {
            var remaining = opss
            let op = remaining.removeLast()
            
            // Switches over the removed value that remaining.removeLast() returns.
            switch op {
            case .Operand(_), .Variable(_), .Constant(_, _):        //If the case is either a Operand, Variable or Constant it will not be changed just return the symbol or number.
                return (op.description, remaining)
                
            case .UnaryOperation(_, _):                             //If the case is UnaryOperation the content will always be inside parantesis so its appended to the operand.
                let operandEvaluation = evaluateDescription(remaining)
                
                if let operand = operandEvaluation.result {
                    //Returning the symbol for the operation as well as whats being operated on within the parentesis.
                    return (op.description + "(\(operand))", operandEvaluation.remaining)
                } else {
                    //If there is not enough values in the opStack we replace the values with a missingSign
                    return (op.description + "(\(missingValueSign))", remaining)
                }
                
            case .BinaryOperation(_, _):                            //If the case is BinaryOperation we are using Precedence to check if it should append a parentesis to right value
                let operandEval1 = evaluateDescription(remaining)
                
                if var operand1 = operandEval1.result {
                    let operandEval2 = evaluateDescription(operandEval1.remaining)
                    
                    //second is Op that comes after op in the opStack
                    let second = remaining.removeLast().precedence
                    
                    if let operand2 = operandEval2.result {
                        //If the current Op types precedence is higher than the upcoming one then put the value in parameters.
                        if (op.precedence > second) {
                            operand1 = "(\(operand1))"
                        }
                        //Return a standard BinaryOperation
                        return (operand2 + op.description + operand1, operandEval2.remaining)
                    } else {
                        //Not enough values for BinaryOperation, missing one value.
                        return (missingValueSign + op.description + operand1, operandEval1.remaining)
                    }
                } else {
                    //Two missing values for BinaryOperation.
                    return (missingValueSign + op.description + missingValueSign, remaining)
                }
            }
        }
        return (nil, opss)
    }
    
    /*
     * clearStack
     * This function is used to reset the stack of operations the calculator
     * uses.
     */
    func clearStack() {
        opStack = [Op]()
    }
    
    /*
     * clearVariables
     * This function resets the variables array by removing all values in it.
     */
    func clearVariables() {
        variableValues.removeAll()
    }
}
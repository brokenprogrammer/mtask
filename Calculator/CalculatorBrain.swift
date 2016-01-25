//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Oskar Mendel on 1/19/16.
//  Copyright © 2016 Oskar Mendel. All rights reserved.
//

import Foundation

/*
 * OperationResult
 * An enum that is used within this class and its controller class.
 * this is the backbone of how the Error system works.
 * What happends is that our evaluateAndReportErrors function returns this enum
 * type instead of an integer, this enum type has two cases either a success 
 * or a fail. Success being the result in a double and Fail being the error 
 * message in a string.
 */
enum OperationResult {
    case Success(Double)
    case Failiure(String)
}

/*
 * CalculatorBrain
 * This is the model in our MVC that preforms the backend operations
 * this will act as our brain which makes all the calculations.
 */
class CalculatorBrain {
    /*
     * CalculatorBrain Description
     * This is the class description property, it is used to return a string
     * value representing the history of a calculation using the evaluateDescription
     * function.
     */
    var description: String {
        get {
            var history = [String]()                //Array for all separate calculations.
            var contents = opStack                  //Copy of the opStack.
            var info = evaluateDescription(contents)//Retrieving the first part of the description.
            
            repeat {
            if (info.result != nil) {
                //history = info.result! + ", " + history
                //history.append(info.result!)
                history.insert(info.result!, atIndex: 0)
                contents = info.remaining
                info = evaluateDescription(contents)
                }
            } while(contents.count > 0)
            
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
    
    private let missingValueSign = "?"                // Private constant used as a placeholder if a value is missing in a calculation.
    private var opStack = [Op]()                      // opStack is the stack of Operations in the order they are added.
    private var knownOps = Dictionary<String, Op>()   // knownOps uses the operation symbols as keys and operation function as values.
    var variableValues = Dictionary<String, Double>() //variableValues holds variables the user pushes to the opStack with their values
    var error = String?()                             //If there is an error in the evaluation that the enum cannot find it will be stored here
    
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
    }
    
    /*
     * pushOperand
     * This function pushes an operand to our opStack and then returns the function
     * evaluate which will evaluate the entire stack. 
     *
     * @param operand - A double that will represent a number the calculator can work with.
     * @returns OperationResult() - An enum type that can contain either
     * a string or double depending on success or fail. Because this function returns
     * OperationResult which is used inside the Controller to display the result this
     * function can be called directly while setting the display value.
     */
    func pushOperand(operand: Double) -> OperationResult? {
        opStack.append(Op.Operand(operand))
        return evaluateAndReportErrors()
    }
    
    /*
     * pushOperand
     * This function pushes an variable to our opStack and then returns the function
     * evaluate which will evaluate the entire stack.
     *
     * @param symbol - A String that will represent a variable the calculator can work with.
     * @returns OperationResult() - An enum type that can contain either
     * a string or double depending on success or fail. Because this function returns
     * OperationResult which is used inside the Controller to display the result this
     * function can be called directly while setting the display value.
     */
    func pushOperand(symbol: String) -> OperationResult? {
        opStack.append(Op.Variable(symbol))
        return evaluateAndReportErrors()
    }
    
    /*
     * preformOperation
     * This function pushes an operation to our opStack by using the knownOps dicionary,
     * then calls the evaluate which will evaluate the entire stack.
     *
     * @param symbol - A String representing a mathematical operation like "+" or "√"
     * @returns OperationResult() - An enum type that can contain either
     * a string or double depending on success or fail. Because this function returns
     * OperationResult which is used inside the Controller to display the result this
     * function can be called directly while setting the display value.
     */
    func preformOperation(symbol: String) -> OperationResult? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluateAndReportErrors()
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
     * evaluateAndReportErrors
     * This function is just as the normal evaluate function calling the 
     * evaluate(opStack) to calculate the values inside the opStack.
     * Then after its finished this function will check if either the Double? 
     * retrieved from the function is not a number or infinite and return errors
     * accordingly.
     *
     * @returns OperationResult() - An enum type that can contain either
     * a string or double depending on success or fail.
     */
    func evaluateAndReportErrors() -> (OperationResult){
        if let result = evaluate(opStack).result {
        
            if (result.isNaN) {
                return OperationResult.Failiure("Not a number.")
            } else if (result.isInfinite) {
                return OperationResult .Failiure("Infinite number.")
            } else {
                return OperationResult.Success(result)
            }
        } else {
            if let resultError = error {
                error = nil
                
                return OperationResult.Failiure(resultError)
            } else {
                return OperationResult.Failiure("Error")
            }
        }
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
                error = "\(symbol) is not set."
                return (nil, remaining)
                
            case .Constant(_, let operand):
                return (operand, remaining)
                
            case .UnaryOperation(_, let operation):     //If its an UnaryOperation we use the operation function for this operation.
                
                //We got sqrt now we look whats behind it in the array to know which operand we should apply it to.
                let operandEvaluation = evaluate(remaining)
                
                //If the rest of the values could be evaluated we use the operand result it returned.
                if let operand = operandEvaluation.result {
                    let operationResult = operation(operand)
                    
                    //Then returns the new result which is the operation for this UnaryOperation.
                    return (operationResult, operandEvaluation.remaining)
                } else {
                    error = "Missing unary operand"
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
                    } else {
                        error = "Missing binary operand."
                    }
                } else {
                    error = "Missing binary operand."
                }
                
            }
        }
        error = "Operation Stack Empty."
        return (nil, ops)
    }
    
    /*
     * evaluateDescription
     * This function works in theory the same as evaluate the only difference is that
     * this is fully based on strings, this function is used to recursivley retrieve
     * history of the calculations that has been made. It also handles rules when it
     * comes to precedence and adding parantesis for values. It uses the indivudual Ops
     * description from the Op enum to return the string description of the values which is
     * symbol for variables and constants and numbers for operands.
     *
     * @returns a touple containing the result as a string value and the remaining opStack
     * in failiure returns a touple with nil as the first value setting the result optional
     * to non existing.
     */
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
    * clearLastAction
    * This function is used to remove the last action made in the calculator.
    */
    func clearLastAction() {
        if (!opStack.isEmpty){
            opStack.removeLast()
        }
    }
    
    /*
     * clearVariables
     * This function resets the variables array by removing all values in it.
     */
    func clearVariables() {
        variableValues.removeAll()
    }
}
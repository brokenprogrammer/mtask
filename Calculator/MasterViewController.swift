//
//  MasterViewController.swift
//  Calculator
//
//  Created by Oskar Mendel on 1/16/16.
//  Copyright © 2016 Oskar Mendel. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {

    @IBOutlet weak var display: NSTextField!
    @IBOutlet weak var history: NSTextField!
    
    var brain = CalculatorBrain()
    
    private let defaultDisplayText = "0"
    var isTyping = false
    var clearHistory = false
    
    //var opperandStack = Array<Double>()
    
    /*
     * a getter setter variable that we use to append values to the display
     * @get - returns a formatted version of the display value, formatted to Double
     * @set - sets the displays string value to the newValue entered in the set statement
     */
    var displayValue: Double? {
        get {
            if let displayValue = NSNumberFormatter().numberFromString(display.stringValue) {
                return displayValue.doubleValue
            } else {
                return nil
            }
        }
        set {
            if (newValue != nil) {
                display.stringValue = "\(newValue!)"
                isTyping = false
            } else {
                display.stringValue = defaultDisplayText
            }
        }
    }
    
    /*
     * appendHistory is a function used to append actions to the history label
     * @param value - String to append to the history label
     */
    func appendHistory(value: String) {
        if (!clearHistory) {
            history.stringValue = history.stringValue + "\(value)"
        } else {
            history.stringValue = "\(value)"
            clearHistory = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /*
     * appendDigit appends a digit to the display. It also checks how many commas there are
     * only allowing one. If the user is in the middle of typing the display value will be appended
     * otherwise the value is set to the digit. 
     * @param sender - an NSButton object for the pressed button.
     */
    @IBAction func appendDigit(sender: NSButton) {
        let digit = sender.title
        if isTyping {
            if (digit != "."  || digit == "." && display.stringValue.rangeOfString(".") == nil)  {
                display.stringValue = display.stringValue + digit
            }
        } else {
            display.stringValue = digit
            isTyping = true
        }
    }
    
    /*
     * enter adds the current numbers on the display to the opperandStack as well as adding
     * the enter action to the history.
     * @param sender - is not used.
     */
    @IBAction func enter(sender: AnyObject) {
        isTyping = false
        if (displayValue != nil) {
            //opperandStack.append(displayValue!)
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = nil
            }
            appendHistory("\(displayValue!) ⏎ ")
        }
    }
    
    /*
     * enter adds the current numbers on the display to the opperandStack. The difference between
     * this overloaded function is that this one does not append anything to the history.
     * @param sender - is not used.
     */
    func enter() {
        isTyping = false
        if (displayValue != nil) {
            //opperandStack.append(displayValue!)
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }
    
    /*
     * operate uses the opperand stack together with the title of the button pressed
     * to choose an operation to preform. It depends on the title of the button then
     * it calls a closure function. This function also appends the choosen operation to
     * the history.
     * @param sender - The pressed button.
     */
    @IBAction func operate(sender: NSButton) {
        let operation = sender.title
        
        if (!history.stringValue.containsString("\(operation)")) {
            appendHistory("\(operation)")
        }
        
        if (isTyping) {
            appendHistory("\(displayValue!)")
            enter()
        }
        
        if let result = brain.preformOperation(operation) {
            displayValue = result
        } else {
            displayValue = nil
        }
        
        //appendHistory("=")
       /*
        switch operation {
        case "*": preformOperation({ $0 * $1 })
        case "÷":
            preformOperation({ (op1: Double, op2: Double) -> Double in
                return op2 / op1
            })
        case "+": preformOperation({ (op1, op2) in return op1 + op2 })
        case "-": preformOperation({ (op1, op2) in return op2 - op1 })
        case "√": preformOperation{sqrt($0)}
        case "sin": preformOperation{ sin($0) }
        case "cos": preformOperation{ cos($0) }
        case "π": addConstant(M_PI)
        default: break
        }*/
    }
    
    /*
     * preformOperation Closure function that takes in a function in the parameters 
     * that returns a double, then uses the closure function while removing the 
     * last values on the opperand stack. Also calls the empty enter function to not
     * display the enter press.
     * @param operation - a function that takes in two doubles and returns one double.
     */
   /* func preformOperation(operation: (Double, Double) -> Double) {
        if (opperandStack.count >= 2) {
            displayValue = operation(opperandStack.removeLast(),opperandStack.removeLast())
            if (displayValue != nil) {
                appendHistory("= \(displayValue!)")
            }
            clearHistory = true
            enter()
        }
    }
    
    /*
     * preformOperation Closure function that takes in a function in the parameters
     * that returns a double, then uses the closure function while removing the
     * last value on the opperand stack. Also calls the empty enter function to not
     * display the enter press.
     * @param operation - a function that takes in a double and returns one double.
     */
    private func preformOperation(operation: Double -> Double) {
        if (opperandStack.count >= 1) {
            displayValue = operation(opperandStack.removeLast())
            if (displayValue != nil) {
                appendHistory("= \(displayValue!)")
            }
            clearHistory = true
            enter()
        }
    } */
    
    /*
     * addConstant A function used to add constants to the display.
     * This function just directly enters the constant value, users cannot append them.
     * @param value - Double value for a constant, for example PI
     */
    func addConstant(value: Double) {
        isTyping = false
        displayValue = value
        enter()
    }
    
    /*
     * reset A function that resets the calculator, removing all history and typed values.
     * resets like it is when the application starts.
     * @param sender - A Button object holding the current button pressed.
     */
    @IBAction func reset(sender: AnyObject) {
        isTyping = false
        //opperandStack.removeAll()
        displayValue = 0
        history.stringValue = ""
        display.stringValue = "0"
    }
    
    /*
    * back A function to undo the latest digit appended to the current display value.
    * @param sender - A Button object holding the current button pressed.
    */
    @IBAction func back(sender: AnyObject) {
        if (isTyping) {
            if (display.stringValue.characters.count > 1){
                display.stringValue = String(display.stringValue.characters.dropLast())
            } else {
                isTyping = false
                displayValue = 0
            }
        }
    }
    
    /*
     * changeSign A function that changes the current value in the display to the either negative
     * or positive value of the current one. Example: 55 would turn into -55
     * @param sender - A Button object holding the current button pressed.
     */
    @IBAction func changeSign(sender: NSButtonCell) {
        if (display.stringValue.characters.count > 1) {
            if (displayValue < 0) {
                displayValue = displayValue! * -1
            } else {
                displayValue = displayValue! - displayValue! * 2
            }
        }
    }
}

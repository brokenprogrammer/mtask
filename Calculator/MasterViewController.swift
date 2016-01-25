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
    private let defaultHistory = " "
    var isTyping = false
    var clearHistory = false
    
    
    /*
     * displayValue
     * A getter variable that we use to format values to doubles.
     * @get - returns a formatted version of the display value, formatted to Double 
     * returns nil if the value cannot be formatted.
     */
    var displayValue: Double? {
        if let displayValue = NSNumberFormatter().numberFromString(display.stringValue) {
            return displayValue.doubleValue
        } else {
            return nil
        }
    }
    
    /*
    * displayResult
    * A getter setter variable that we use to append values to the display
    * @set - checks if the newValue is nil, if not it sets the display.stringValue
    * to the newValue. Else it sets the display to show the default text.
    * @get - returns a double if the value inside it can be converted to a Double
    * otherwise it returns the Failiure case with the current stringValue
    */
    var displayResult: OperationResult? {
        get {
            //Doing optional binding to see if displayValue contains a number.
            if let displayValue = displayValue {
                //Return the number within displayValue.
                return .Success(displayValue)
            } else {
                //Return the error string found in display.stringValue.
                return .Failiure(display.stringValue)
            }
        }
        set {
            history.stringValue = brain.description + " ="
            //Checking if the newValue is nil since this is of type optional.
            if (newValue != nil) {
                //Wraping newValue into non optional and switching through it.
                switch newValue! {
                case let .Success(newValue):
                    //Case its a number value use displayValue to set the number.
                    display.stringValue = "\(newValue)"
                case let .Failiure(newValue):
                    //Else if its a string value set it manually to the display.
                    display.stringValue = newValue
                }
            } else {
                display.stringValue = defaultDisplayText
            }
            
            isTyping = false
            
            //Appending history found in the brain.description
            if !brain.description.isEmpty {
                history.stringValue = "\(brain.description) ="
            } else {
                history.stringValue = defaultHistory
            }
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
     * enter pushes the current values on the display to the CalculatorBrain.
     * Sets the displays value to the result of pushing the operand and appending the
     * action made to the history.
     * @param sender - is not used.
     */
    @IBAction func enter(sender: AnyObject) {
        isTyping = false
        if (displayValue != nil) {
            if let result = brain.pushOperand(displayValue!) {
                displayResult = result
            } else {
                displayResult = nil
            }
        }
    }
    
    /*
     * enter pushes the current values on the display to the CalculatorBrain.
     * Sets the displays value to the result of pushing the operand.
     */
    func enter() {
        isTyping = false
        if (displayValue != nil) {
            if let result = brain.pushOperand(displayValue!) {
                displayResult = result
            } else {
                displayResult = nil
            }
        }
    }
    
    /*
     * operate sends the title of the button pressed to our CalculatorBrain that
     * processes the title and preforms an operation depending on the case.
     * if the operation from CalculatorBrain fails the display will be set to the default
     * value.
     * operate also appends the operation to the history.
     * @param sender - The pressed button.
     */
    @IBAction func operate(sender: NSButton) {
        let operation = sender.title
        
        if (!history.stringValue.containsString("\(operation)")) {
        }
        
        if (isTyping) {
            enter()
        }
        
        if let result = brain.preformOperation(operation) {
            displayResult = result
        } else {
            displayResult = nil
        }
    }
    
    /*
     * addConstant A function used to add constants to the display.
     * This function just directly enters the constant value, users cannot append them.
     * @param value - Double value for a constant, for example PI
     */
    func addConstant(value: Double) {
        isTyping = false
        //displayValue = value
        displayResult = OperationResult.Success(value)
        enter()
    }
    
    /*
     * reset A function that resets the calculator, removing all history and typed values.
     * resets like it is when the application starts.
     * @param sender - A Button object holding the current button pressed.
     */
    @IBAction func reset(sender: AnyObject) {
        isTyping = false
        displayResult = nil
        history.stringValue = defaultHistory
        display.stringValue = defaultDisplayText
        brain.variableValues.removeAll()
        brain.clearStack()
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
                displayResult = OperationResult.Success(0)
            }
        } else {
            //Here we remove last appended thing to the opStack and update display.
            brain.clearLastAction()
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    /*
     * changeSign A function that changes the current value in the display to the either negative
     * or positive value of the current one. Example: 55 would turn into -55
     * @param sender - A Button object holding the current button pressed.
     */
    @IBAction func changeSign(sender: NSButtonCell) {
        if (isTyping) {
            //if (displayValue < 0) {
            if (displayResult != nil) {
                displayResult = OperationResult.Success(displayValue! * -1)
                isTyping = true
            } else {
                displayResult = OperationResult.Success(displayValue! * 2)
            }
        } else if(!isTyping) {
            if let result = brain.preformOperation("±") {
                displayResult = result
            } else {
                displayResult = nil
            }
        }
    }
    
    /*
     * getM
     * pushes the variable M to the CalculatorBrains operation stack.
     * @param sender - The NSButton object for the button pressed.
     */
    @IBAction func getM(sender: NSButton) {
        if (isTyping) {
            enter()
        }
        if let result = brain.pushOperand("𝛭") {
            displayResult = result
        }
    }
    
    /*
     * setM
     * sets a new value to the variable M in the CalculatorBrain.
     * @param sender - The NSButton object for the button pressed.
     */
    @IBAction func setM(sender: NSButton) {
        if displayValue != nil {
            brain.variableValues["𝛭"] = displayValue
        }
        
        let result = brain.evaluateAndReportErrors()
        print("\(result)")
        switch result {
        case .Failiure("Operation Stack Empty."):
            print("IsTrue")
            displayResult = nil
        default:
            displayResult = result
        }
        
        print("Pushed 𝛭 = \(brain.variableValues["𝛭"])")
    }
}

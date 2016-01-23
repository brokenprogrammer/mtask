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
            history.stringValue = brain.description + " ="
            if (newValue != nil) {
                display.stringValue = "\(newValue!)"
                //isTyping = false
            } else {
                display.stringValue = defaultDisplayText
            }
            
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
                //displayValue = result
                switch result {
                case .Success(let num):
                    displayValue = num
                case .Failiure(let str):
                    display.stringValue = str
                }
                print(brain.evaluateAndReportErrors())
            } else {
                displayValue = nil
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
                //displayValue = result
                switch result {
                case .Success(let num):
                    displayValue = num
                case .Failiure(let str):
                    display.stringValue = str
                }
                print(brain.evaluateAndReportErrors())
            } else {
                displayValue = nil
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
            //displayValue = result
            switch result {
            case .Success(let num):
                displayValue = num
            case .Failiure(let str):
                display.stringValue = str
            }
            print(brain.evaluateAndReportErrors())
        } else {
            displayValue = nil
        }
    }
    
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
        displayValue = nil
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
                displayValue = 0
            }
        } else {
            //Here we remove last appended thing to the opStack and update display.
            brain.clearLastAction()
            displayValue = brain.evaluate()
        }
    }
    
    /*
     * changeSign A function that changes the current value in the display to the either negative
     * or positive value of the current one. Example: 55 would turn into -55
     * @param sender - A Button object holding the current button pressed.
     */
    @IBAction func changeSign(sender: NSButtonCell) {
        print(isTyping)
        if (isTyping) {
            if (displayValue < 0) {
                displayValue = displayValue! * -1
            } else {
                displayValue = displayValue! - displayValue! * 2
            }
        } else if(!isTyping) {
            if let result = brain.preformOperation("±") {
                //displayValue = result
                switch result {
                case .Success(let num):
                    displayValue = num
                case .Failiure(let str):
                    display.stringValue = str
                }
            } else {
                displayValue = nil
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
       //displayValue = brain.pushOperand("𝛭")
        if let result = brain.pushOperand("") {
            switch result {
            case .Success(let num):
                displayValue = num
            case .Failiure(let str):
                display.stringValue = str
            }
        }
    }
    
    /*
     * setM
     * sets a new value to the variable M in the CalculatorBrain.
     * @param sender - The NSButton object for the button pressed.
     */
    @IBAction func setM(sender: NSButton) {
            brain.variableValues["𝛭"] = displayValue
            displayValue = brain.evaluate()
            print("Pushed 𝛭 = \(brain.variableValues["𝛭"])")
    }
}

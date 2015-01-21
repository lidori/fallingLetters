//
//  ViewController.swift
//  fallingLetters
//
//  Created by Shira Yoked on 1/18/15.
//  Copyright (c) 2015 Shira Yoked. All rights reserved.
//
//  Tap a label of words for the letters to fall down and pile up
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var someWords : UILabel!
    
    var animator:UIDynamicAnimator? = nil
    
    let gravity = UIGravityBehavior()
    
    let collider = UICollisionBehavior()
    
    let itemBehavior = UIDynamicItemBehavior()
    
    let itemSize : CGFloat = 41
    
    var items: [UILabel] = []
    
    var maxSpace = CGFloat(100000)
    
    var spaceTaken: CGFloat = CGFloat(0)
    
    let someWordsTapRec = UITapGestureRecognizer()
    
    var lastLocation:CGPoint = CGPointMake(0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Caldulate the max space the fallen letter can take
        maxSpace = view.frame.width * view.frame.height*0.35
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad
        {
            maxSpace = maxSpace/3
        }
        
        createAnimator()
        
        // Initialize tap recognizer for tapping the word on the screen
        someWordsTapRec.addTarget(self, action: "tappedWords")
        someWords.addGestureRecognizer(someWordsTapRec)
        someWords.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        removeLettersLabels()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // Create animator with collider, gravity and elasticity
    func createAnimator() {
        animator = UIDynamicAnimator(referenceView:self.view);
        
        collider.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collider)
        
        gravity.gravityDirection = CGVectorMake(0, 0.8)
        animator?.addBehavior(gravity);
        
        itemBehavior.elasticity = 0.4
        animator!.addBehavior(itemBehavior)
    }

    // Animate one item with the above collider, gravity and elasticity
    func animate(item: UIDynamicItem) {
        collider.addItem(item)
        gravity.addItem(item)
        itemBehavior.addItem(item)
    }

    // Add one UILabel
    func addLabelItemWithLocation(location: CGRect, color: UIColor, backgroundColor: UIColor, text: String, fontSize: Int) -> UILabel {
        let newItem = UILabel(frame: location)
        newItem.backgroundColor = backgroundColor
        newItem.enabled = true
        newItem.textColor = UIColor.clearColor()
        newItem.textColor = color
        newItem.text = text
        newItem.font = newItem.font.fontWithSize(CGFloat(fontSize))
        newItem.textAlignment = NSTextAlignment.Center
        view.addSubview(newItem)
        animate(newItem)
        items.append(newItem)
        return newItem
    }
    
    // Place individual UILabels in the location of the original words' label, so they would fall starting from this location
    func lettersLabelsOfSomeWords()
    {
        if spaceTaken > maxSpace
        {
            removeLettersLabels()
            
            return
        }
        
        let someWordsTextWidth = someWords.intrinsicContentSize().width
        let someWordsTextHeight = someWords.intrinsicContentSize().height
        
        var someWordsWordArr = split(someWords!.text!) {$0 == " "}
        if someWordsWordArr.count < 1
        {
            someWordsWordArr = [""]
        }
        
        var startX = someWords.center.x - CGFloat(someWordsTextWidth/2)
        var startY = someWords.center.y - CGFloat(someWordsTextHeight/2)
        
        var rect: CGRect = CGRectMake(0, 0, 0, 0)
        
        var currLetterWidth = CGFloat(0)
        var currLetterHeight = CGFloat(0)
        var letterLabel = UILabel()
        letterLabel.font = UIFont.systemFontOfSize(41)
        
        if someWords.text!.length > 0
        {
            var currWordIndex = 0
            var currTextLabel = UILabel()
            currTextLabel.font = UIFont.systemFontOfSize(41)
            var currText = someWordsWordArr[0]
            
            for i in 0...someWords.text!.length-1
            {
                var currLetter = someWords.text![i]
                
                // Check if need to go down one line, in case of a long label with many words
                if currLetter == " "
                {
                    currWordIndex++
                    var restOfNewLine = ""
                    var restOfNewLineIndex = currWordIndex
                    if someWordsWordArr.count > currWordIndex
                    {
                        currText += " "+someWordsWordArr[currWordIndex]
                        currTextLabel.text = currText
                        if currTextLabel.intrinsicContentSize().width > someWordsTextWidth
                        {
                            restOfNewLine = someWordsWordArr[restOfNewLineIndex]
                            currText = someWordsWordArr[currWordIndex]
                            currTextLabel.text = currText
                            var newLineWidth = currTextLabel.intrinsicContentSize().width
                            while currTextLabel.intrinsicContentSize().width <= someWordsTextWidth && restOfNewLineIndex < (someWordsWordArr.count - 1)
                            {
                                restOfNewLineIndex++
                                restOfNewLine += " "+someWordsWordArr[restOfNewLineIndex]
                                currTextLabel.text = restOfNewLine
                                if currTextLabel.intrinsicContentSize().width <= someWordsTextWidth
                                {
                                    newLineWidth = currTextLabel.intrinsicContentSize().width
                                }
                            }
                            
                            startX =  someWords.center.x - newLineWidth/2
                            startY += itemSize
                        }
                        else
                        {
                            letterLabel.text = currLetter
                            currLetterWidth = letterLabel.intrinsicContentSize().width
                            startX += currLetterWidth
                        }
                    }
                }
                else
                {
                    // Each letter is will be in a rectangle label, 
                    // make this label smaller if necessary, 
                    // to have smaller spaces between the letters after they have fallen down
                    letterLabel.text = currLetter
                    currLetterWidth = letterLabel.intrinsicContentSize().width
                    currLetterHeight = letterLabel.intrinsicContentSize().height
                    if currLetter ~= "[a-z&&[^gpqy]]"
                    {
                        currLetterHeight = currLetterHeight*0.75
                    }
                    else if currLetter ~= "[A-Z]"
                    {
                        currLetterHeight = currLetterHeight*0.85
                    }
                    else if currLetter ~= "[']"
                    {
                        currLetter = "|"
                        currLetterHeight = currLetterHeight*0.25
                    }
                    
                    rect = CGRectMake(startX, startY, currLetterWidth, currLetterHeight)
                    
                    startX += currLetterWidth + 1
                    
                    addLabelItemWithLocation(rect, color: UIColor.blackColor(), backgroundColor: UIColor.clearColor(), text: currLetter, fontSize: 41)
                    
                    spaceTaken =  spaceTaken + CGFloat(currLetterWidth*currLetterHeight)
                }
            }
        }
        
        // Can change the original label of words to "", to make it look as it is falling down
    }
    
    // Remove the letters' labels when reaching maximum space
    // Too many letters or remains of letters will need more resources from iOS
    func removeLettersLabels()
    {
        if(items.count>0)
        {
            for i in 0...items.count-1
            {
                collider.removeItem(items[i])
                gravity.removeItem(items[i])
                itemBehavior.removeItem(items[i])
                items[i].removeFromSuperview()
            }
            
            items = []
        }
        
        spaceTaken = CGFloat(0)
    }
    
    // Called by the tap recognizer when the words' label is tapped
    func tappedWords()
    {
        lettersLabelsOfSomeWords()
    }
    
}


// String extension for convenient methods on Strings
extension String {
    var length: Int { return countElements(self) }
    
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }

}

// Custom operator for easy regular expression check
infix operator ~= { associativity left precedence 140 }
func ~= (string: String, pattern: String) -> Bool {
    
    var options: NSRegularExpressionOptions =
    NSRegularExpressionOptions.DotMatchesLineSeparators
    
    let regex = NSRegularExpression(pattern: pattern,
        options: options,
        error: nil)
    
    var matches = 0
    if let regex = regex {
        matches = regex.numberOfMatchesInString(string,
            options: nil,
            range: NSMakeRange(0, countElements(string)))
    }
    return matches > 0
}





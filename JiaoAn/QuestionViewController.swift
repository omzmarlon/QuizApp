//
//  ViewController.swift
//  JiaoAn
//
//  Created by Marlon Ou on 2015-12-22.
//  Copyright (c) 2015 TPTJ. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {
    
    //typeOtherInfoLabel stores information of title param. Use this to decide display of grade selected view when tap back image view
    

    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    
    @IBOutlet weak var mainQContainerView: UIView!
    
    //@IBOutlet weak var difficultyImage: UIImageView!
    //@IBOutlet weak var typeOtherInfoLabel: UILabel!
    @IBOutlet weak var mainQuestionLabel: UILabel!
    

    @IBOutlet weak var answerAButton: UIButton!
    
    @IBOutlet weak var answerBButton: UIButton!
    
    @IBOutlet weak var answerCButton: UIButton!
    
    @IBOutlet weak var answerDButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    private var selectedA = false
    private var selectedB = false
    private var selectedC = false
    private var selectedD = false
    private var numselected : Int = 0 //super important field. also used to handle cases like 012
    
    //byron's
    var multiple4 : Multiple4Choice?
    let analysis = "analysis: blabla.........."
    var problemSet : [Question] = []
    var islevelTest:Bool!
    var myGrade : String?
    var numCorrectAnswer : Int = 0

    
    var correctChoice : Int?
    
    var selection : Int?
    

    //var fillInBlank : ?????
    
    private var jumpToNext : Bool = false
    
    // progress recorder
    private var current : Int = 0{
        // property observer
        didSet {
            let progress_rate = Float(current) / Float(problemSet.count)
            let animated = current != 0
            
            progressView.setProgress(progress_rate, animated: animated)
            progressLabel.text = ("\(Int(progress_rate * 100))%")
        }
    }
    
    

    func shuffle(){
        //TODO
        
    }
    
    
    var unselectedColor : UIColor?
    //var selectedColor : UIColor = UIColor(red: 100, green: 100, blue: 255, alpha: 0.5)
    var selectedColor : UIColor = UIColor.grayColor()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        unselectedColor = answerAButton.backgroundColor
        
        loadQuestion()
        
        numCorrectAnswer = 0
        
        // progress bar
        progressView.setProgress(0.0, animated: true)
          print("isLevelTest \(islevelTest)")
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //Below Section for answer selection
    
    
    @IBOutlet weak var answerResultView: AnswerResultView!
    
    private func curlDownAnimation(view : UIView,animationTime : Float){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationDuration(NSTimeInterval(animationTime))
        UIView.setAnimationTransition(UIViewAnimationTransition.CurlDown, forView: view, cache: false)
        UIView.commitAnimations()
    }
    
    func goBackFunc(alert:UIAlertAction!){
        //Print out you have finished all questions, please hit back button to go back to grade selected view
        self.curlDownAnimation(answerResultView, animationTime: 1.0)
        answerResultView.hidden = false
        //display: completed picture
        //hault question view controller
        
        questionBackTap("")
        
        /*let vc = self.storyboard?.instantiateViewControllerWithIdentifier("GradeSelectedVC") as! GradeSelectedViewController
        self.presentViewController(vc, animated: true, completion: nil)*/
    }
    
    func setDifficulty(dif:Int){
        var key = "grade7difficulty"
        switch myGrade!{
        case "grade 7":
            break
        case "grade 8":
            key = "grade8difficulty"
        case "grade 9":
            key = "grade9difficulty"
        default:
            break
            
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults();
        userDefaults.setInteger(dif, forKey: key)
        userDefaults.synchronize()
    }
    
    
    @IBAction func submitButton(sender: AnyObject) {
        
        
        if jumpToNext {
            
            
            if current >= problemSet.count{
                let alter = UIAlertController(title: "恭喜你", message: "你已经完成所有题目，共答对\(numCorrectAnswer)/\(problemSet.count)题，点击确定返回上一界面",preferredStyle: .Alert)
                let goBack = UIAlertAction(title: "确定", style: .Default, handler: goBackFunc)
                alter.addAction(goBack)
                //set difficulty
                var setDifTo = 0
                if((self.islevelTest) != nil){
                    if(self.islevelTest!){
                        if(numCorrectAnswer == 0 || numCorrectAnswer == 1){
                            setDifTo = 0
                        }else if(numCorrectAnswer == 2 || numCorrectAnswer == 3){
                            setDifTo = 1
                        }else if(numCorrectAnswer >= 4){
                            setDifTo = 2
                        }else{
                            setDifTo = 3
                        }
                        self.setDifficulty(setDifTo)
                    }
                }
                presentViewController(alter, animated: true, completion: nil)
            }else{
                prepareForNext()
                loadQuestion()
                answerResultView.hidden = true
                self.jumpToNext = false
                return //nothing
            }
            
        }else{
            
            
            //To make animation go with view's appearance(unhide it) set the hidden property to false AFTER animation call
            if selection != nil{
                self.curlDownAnimation(answerResultView, animationTime: 1.0)
                answerResultView.hidden = false
                if matchWithCorrect(){
                    answerResultView.answerResultImage.image = UIImage(named: "correct")
                    answerResultView.setTextForLabel("correct")
                    
                    numCorrectAnswer++
                    
                }
                else {
                    answerResultView.answerResultImage.image = UIImage(named: "wrong")
                    answerResultView.setTextForLabel("incorrect")
                }
                
                current++
                self.jumpToNext = true
            }
        }
        
        
    }
    
    @IBAction func answerAButton(sender: AnyObject) {
        if selectedA {
            selectedA = false
            removeChoice(0)
            numselected--
            answerAButton.backgroundColor = unselectedColor
            
            
        }else{
            selectedA = true
            addChoice(0)
            numselected++
            answerAButton.backgroundColor = selectedColor
        }
        
    }
    
    @IBAction func answerBButton(sender: AnyObject) {
        if selectedB {
            selectedB = false
            removeChoice(1)
            numselected--
            answerBButton.backgroundColor = unselectedColor
        }else{
            selectedB = true
            addChoice(1)
            numselected++
            answerBButton.backgroundColor = selectedColor
        }
    }
    
    @IBAction func answerCButton(sender: AnyObject) {
        if selectedC {
            selectedC = false
            removeChoice(2)
            numselected--
            answerCButton.backgroundColor = unselectedColor
        }else{
            selectedC = true
            addChoice(2)
            numselected++
            answerCButton.backgroundColor = selectedColor
        }
    }
    
    @IBAction func answerDButton(sender: AnyObject) {
        if selectedD {
            selectedD = false
            removeChoice(3)
            numselected--
            answerDButton.backgroundColor = unselectedColor
            
        }else{
            selectedD = true
            addChoice(3)
            numselected++
            answerDButton.backgroundColor = selectedColor
        }
    }
    
    //Above section for answer selection
    
    //Below section for back to grade selected
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let desView = segue.destinationViewController as! GradeSelectedViewController
        //desView.name = typeOtherInfoLabel.text!
        desView.name = myGrade!
        
    }
    
    @IBAction func questionBackTap(sender: AnyObject) {
        performSegueWithIdentifier("questionToSelected", sender: sender)
    }
    
    private func prepareForNext(){
        multiple4 = nil //all Qs set to nil before load. For type recognizing purposes
        selection = nil //set to nil to avoid  bug
        numselected = 0 //set to zero to avoid bug
        selectedA = false
        selectedB = false
        selectedC = false
        selectedD = false
        answerAButton.backgroundColor = unselectedColor
        answerBButton.backgroundColor = unselectedColor
        answerCButton.backgroundColor = unselectedColor
        answerDButton.backgroundColor = unselectedColor
    }
    
    private func loadQuestion(){
        //clear up information and fill for next question
        let q : Question = self.problemSet[current]
        
        if let t = q as? Multiple4Choice{
            multiple4 = t
        }
        //else, other type of questions?
        
        if multiple4 != nil{
           // difficultyImage.image = UIImage(named: multiple4!.difficulty.rawValue)
           //typeOtherInfoLabel.text = multiple4!.title
            mainQuestionLabel.text = multiple4!.mainQuestion
            answerAButton.setTitle("A. \(multiple4!.answers[0])", forState: UIControlState.Normal)
            answerBButton.setTitle("B. \(multiple4!.answers[1])", forState: UIControlState.Normal)
            answerCButton.setTitle("C. \(multiple4!.answers[2])", forState: UIControlState.Normal)
            answerDButton.setTitle("D. \(multiple4!.answers[3])", forState: UIControlState.Normal)
            correctChoice = multiple4?.correct
        }
        
        //answer type fill in blank??
        
    }
    
    private func addChoice(ans : Int){
        //TODO
        if selection == nil{ selection = ans; return; }
        selection = (selection! * 10) + ans
    }
    
    private func removeChoice(item : Int){
        //TODO
        var ansArray : [Int] = []
        for var i = 0 ; i < numselected ; ++i {
            ansArray.append(selection!%10)
            selection = selection! / 10
        }
        //Always set selection to nil when all chocies pulled out
        selection = nil
        ansArray.removeAtIndex(ansArray.indexOf(item)!)
        for a in ansArray{
            addChoice(a)
        }
    }
    
    private func matchWithCorrect()->Bool{
        //TODO
        //IMPORTANT: choice 0 cannot be place in the front!
        //Ans matching requires correctAns's digits to be in DECSENDING ORDER
        var ansArray : [Int] = []
        for var i = 0 ; i < numselected ; ++i {
            ansArray.append(selection!%10)
            selection = selection! / 10
        }
        selection = nil
        ansArray.sortInPlace({(a : Int, b : Int) -> Bool in
            return a > b
        })
        print(ansArray)
        for a in ansArray{
            addChoice(a)
        }
        
        return selection! == correctChoice!;
    }
    
}


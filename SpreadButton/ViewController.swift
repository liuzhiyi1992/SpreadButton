//
//  ViewController.swift
//  SpreadButton
//
//  Created by lzy on 16/1/18.
//  Copyright © 2016年 lzy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn1 = SpreadSubButton(backgroundImage: UIImage(named: "clock"), highlightImage: UIImage(named: "clock_highlight")) { (index, sender) -> Void in
            print("first")
        }
        
        let btn2 = SpreadSubButton(backgroundImage: UIImage(named: "pencil"), highlightImage: UIImage(named: "pencil")) { (index, sender) -> Void in
            print("second")
        }
        
        let btn3 = SpreadSubButton(backgroundImage: UIImage(named: "juice"), highlightImage: UIImage(named: "juice")) { (index, sender) -> Void in
            print("third")
        }
        
        let btn4 = SpreadSubButton(backgroundImage: UIImage(named: "service"), highlightImage: UIImage(named: "service")) { (index, sender) -> Void in
            print("fourth")
        }
        
        let btn5 = SpreadSubButton(backgroundImage: UIImage(named: "shower"), highlightImage: UIImage(named: "shower")) { (index, sender) -> Void in
            print("fifth")
        }
        
        
        
        let spreadButton = SpreadButton(image: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton"), position: CGPointMake(40, UIScreen.mainScreen().bounds.height - 40))
        
        spreadButton?.setSubButtons([btn1, btn2, btn3, btn4, btn5])
        spreadButton?.mode = SpreadMode.SpreadModeSickleSpread
        spreadButton?.direction = SpreadDirection.SpreadDirectionRightUp
        
        //and you can assign a newValue to change the default
        /*
        spreadButton?.animationDuring = 0.2
        spreadButton?.animationDuringClose = 0.25
        spreadButton?.radius = 180
        spreadButton?.coverAlpha = 0.3
        spreadButton?.coverColor = UIColor.yellowColor()
        */
        spreadButton?.radius = 120
        
        if spreadButton != nil {
            self.view.addSubview(spreadButton!)
        }
    }

    
    @IBAction func clickMainViewButton(sender: AnyObject) {
        print("on click")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


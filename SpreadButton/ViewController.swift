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
        
        let btn1 = SpreadSubButton(backgroundImage: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton")) { (index, sender) -> Void in
            print("first")
        }
        
        let btn2 = SpreadSubButton(backgroundImage: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton")) { (index, sender) -> Void in
            print("second")
        }
        
        let btn3 = SpreadSubButton(backgroundImage: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton")) { (index, sender) -> Void in
            print("third")
        }
        
        let btn4 = SpreadSubButton(backgroundImage: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton")) { (index, sender) -> Void in
            print("fourth")
        }
        
        let btn5 = SpreadSubButton(backgroundImage: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton")) { (index, sender) -> Void in
            print("fifth")
        }
        
        
        let spreadButton = SpreadButton(image: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton_highlight"))
        
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


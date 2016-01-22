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
        
        
//        self.view.backgroundColor = UIColor.yellowColor()
        
        let btn1 = UIButton()
        btn1.setBackgroundImage(UIImage(named: "powerButton"), forState: .Normal)
        let btn2 = UIButton()
        btn2.setBackgroundImage(UIImage(named: "powerButton"), forState: .Normal)
        let btn3 = UIButton()
        btn3.setBackgroundImage(UIImage(named: "powerButton"), forState: .Normal)
        
        
        let spreadButton = SpreadButton(image: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton_highlight"))
        
        spreadButton?.subButtons = [btn1, btn2, btn3]
        if spreadButton != nil {
            self.view.addSubview(spreadButton!)
        }
    }

    @IBAction func clickButton(sender: AnyObject) {
        print("12364")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


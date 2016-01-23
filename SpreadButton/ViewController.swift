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
            print("第一个按钮被按了")
        }
        
        let btn2 = SpreadSubButton(backgroundImage: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton")) { (index, sender) -> Void in
            print("第二个按钮被按了")
        }
        
        let btn3 = SpreadSubButton(backgroundImage: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton")) { (index, sender) -> Void in
            print("第三个按钮被按了")
        }
        
        
        
        let spreadButton = SpreadButton(image: UIImage(named: "powerButton"), highlightImage: UIImage(named: "powerButton_highlight"))
        spreadButton?.setSubButtons([btn1, btn2, btn3])
        
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


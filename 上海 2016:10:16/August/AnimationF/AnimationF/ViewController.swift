//
//  ViewController.swift
//  AnimationF
//
//  Created by AugustRush on 10/12/16.
//  Copyright © 2016 August. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var blueViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blueViewWidthContraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARk: event methods

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        //
//        animation0()
        //
//        animation1()
        //
//        animation2()
        //
//        animataion3()
        //
//        animation4()
        
//        animation5()
        
        animation6()
    }
    
    func animation0() {
        let transimission = BasicTransmission()
        transimission.delay = 1.0
        transimission.duration = 1.0
        
        let animation = Animation<CGFloat>()
        animation.from = 0.0
        animation.to = 200
        animation.transmission = transimission
        animation.render = { (f) in
            self.redView.center.x = f
        }
        animation.completion = {
            print("spring is completion")
        }
        
        let identifier = String(unsafeBitCast(animation, to: Int.self))
        Animator.shared.addAnimation(animation, forKey: identifier)
    }
    
    func animation1() {
        let x = CGFloat(arc4random() % 300)
        let y = CGFloat(arc4random() % 400)
        let toPoint = CGPoint(x: x, y: y)
//        blueView.center.animateTo(toPoint, duration: 1.0, delay: 0.5, timingFunction: .Default, render: { (p) in
//            self.blueView.center = p
//            }) {
//                self.delayRelayoutView()
//        }

        
//        //Custom Easing
//        blueView.bounds.size.animateTo(size, duration: 1.0, easing: { (t) -> Double in
//            return sin(13.0 * M_PI_2 * t) * pow(2, 10 * (t - 1))
//            }, render: { (s) in
//                print("blueView size is \(s)")
//                self.blueView.bounds.size = s
//            }, completion: {
//                print("animation completion!")
//        })
        
        blueView.center.springTo(toPoint, render: { (p) in
            self.blueView.center = p
            self.redView.center = p
            }) { 
                print("spring completion, relayout views!")
                self.delayRelayoutView()
        }
    }
    
    func animation2()  {
        
        let x = CGFloat(arc4random() % 300)
        let y = CGFloat(arc4random() % 300)
        
        UIView.st_animate(withDuration: 2.0, delay: 0.5, type: .SwiftOut, animations: {
            self.blueView.center = CGPoint(x: x, y: y)
            self.blueView.bounds.size = CGSize(width: x,height: y)
            self.blueView.backgroundColor = UIColor(red: x / 300.0, green: y / 300.0, blue: x/300.0, alpha: 1)
            
            self.redView.backgroundColor = UIColor.brown
            self.redView.layer.setTransformRotationZ(20)
            self.redView.layer.cornerRadius = CGFloat(arc4random() % 30)
            }) { () in
                print("compeltion")
        }
    }
    
    //AutoLayout Animation / Color
    func animataion3() {
        let w = CGFloat(arc4random() % 300)
        let h = CGFloat(arc4random() % 300)
        
        self.blueViewHeightConstraint.constant = w
        self.blueViewWidthContraints.constant = h
        
        self.view.setNeedsLayout()
        
        UIView.st_animate(withDuration: 2.0, delay: 0.5, type: .SwiftOut, animations: {
            self.view.layoutIfNeeded()
        }) { () in
            print("compeltion")
        }
    }
    
    //Spring
    func animation4() {
        let transimission = SpringTransmission()
        transimission.delay = 1.0
        transimission.mass = 3.0
        transimission.initialVelocity = 0.0
        
        let animation = Animation<CGFloat>()
        animation.from = 0.0
        animation.to = 200
        animation.transmission = transimission
        animation.render = { (f) in
            print("alpha is \(f)")
            self.redView.center.x = f
        }
        animation.completion = {
            print("spring is completion")
        }
        
        let identifier = String(unsafeBitCast(animation, to: Int.self))
        Animator.shared.addAnimation(animation, forKey: identifier)
    }
    
    //Block Spring
    
    func animation5() {
        let x = CGFloat(arc4random() % 300)
        let y = CGFloat(arc4random() % 300)

        
        UIView.st_spring(animations: { 
            self.blueView.center = CGPoint(x: x, y: y)
            self.blueView.bounds.size = CGSize(width: x,height: y)
            self.blueView.backgroundColor = UIColor(red: x / 300.0, green: y / 300.0, blue: x/300.0, alpha: 1)
            
            self.redView.backgroundColor = UIColor.brown
            self.redView.center.x = x
            self.redView.layer.cornerRadius = CGFloat(Int(x) % 30)

            }) { 
                print("compeltion")
        }
    }
    
    //Spring && AutoLayout
    func animation6() {
        let w = CGFloat(arc4random() % 300)
        let h = CGFloat(arc4random() % 300)
        
        self.blueViewHeightConstraint.constant = w
        self.blueViewWidthContraints.constant = h
        
        self.view.setNeedsLayout()
        
        UIView.st_spring(withDamping: 10.0, stiffness: 200, mass: 1.0, initialVelocity: 0.3, animations: {
            self.view.layoutIfNeeded()
            }) { 
            print("spring layout completion")
        }
        
    }
    
    func delayRelayoutView() {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.view.setNeedsLayout()
            UIView.st_animate(withDuration: 1.0, animations: { 
              self.view.layoutIfNeeded()  
            })
        })
    }
}


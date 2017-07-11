//
//  PulseAnimationExtension.swift
//  Blade Runner
//
//  Created by Alfred Ly on 5/18/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit

extension UIView{
	func pulseAnimation(){
		let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
		
		scaleAnimation.duration = 0.5
		scaleAnimation.repeatCount = Float.infinity
		scaleAnimation.autoreverses = true
		scaleAnimation.fromValue = 1.1;
		scaleAnimation.toValue = 0.9;
		layer.add(scaleAnimation, forKey: "scale")
		
		let opacityAnimation = CABasicAnimation(keyPath: "opacity")
		opacityAnimation.duration = 0.5
		opacityAnimation.repeatCount = Float.infinity
		opacityAnimation.autoreverses = true
		opacityAnimation.fromValue = 1.0
		opacityAnimation.toValue = 0.2
		layer.add(opacityAnimation, forKey: "opacity")
	}
}

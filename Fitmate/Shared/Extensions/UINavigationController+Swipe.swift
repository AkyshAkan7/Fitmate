//
//  UINavigationController+Swipe.swift
//  Fitmate
//
//  Created by Akan Akysh on 08/04/26.
//

import UIKit

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}

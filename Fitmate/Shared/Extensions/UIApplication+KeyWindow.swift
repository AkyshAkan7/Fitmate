//
//  UIApplication+KeyWindow.swift
//  Fitmate
//
//  Created by Akan Akysh on 28/07/26.
//

import UIKit

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }

    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }
}

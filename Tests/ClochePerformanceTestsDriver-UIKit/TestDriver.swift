//
//  TestsDriver.swift
//  Cloche Performance Tests Driver UIKit
//
//  Created by Yoshinori Atarashi on 2019/07/31.
//

import UIKit
import ClochePerformanceTests

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global().async {
            runPerformanceTests()
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()

        return true
    }
}

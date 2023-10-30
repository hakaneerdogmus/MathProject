//
//  TabBarView.swift
//  MathProject
//
//  Created by Hakan ERDOĞMUŞ on 30.10.2023.
//

import UIKit


class TabBarView: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let keyboardView = KeyboardView()
//        let cameraView = CameraView()
//        let tabBarController = [keyboardView, cameraView]
//
//        keyboardView.tabBarItem = UITabBarItem(title: "Keyboard", image: UIImage(systemName: "keyboard"), selectedImage: UIImage(systemName: "keyboard.fill"))
//        cameraView.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), selectedImage: UIImage(systemName: "camera.fill"))
//
//
//        self.viewControllers = tabBarController
//        self.tabBar.barTintColor = .green
        
        self.setupTabs()
        self.selectedIndex = 1
        self.tabBar.backgroundColor = .white
        self.tabBar.tintColor = .red
        self.tabBar.unselectedItemTintColor = .blue
                
        navigationItem.hidesBackButton = true
    }
    
    
    //MARK: Tab Setup
    private func setupTabs() {
        let pencilView = self.createNavigation(title: "Pencil", image: UIImage(systemName: "pencil.circle"), selectedImage: UIImage(systemName: "pencil.circle.fill"), vc: PencilView())
        let cameraView = self.createNavigation(title: "Camera", image: UIImage(systemName: "camera"), selectedImage: UIImage(systemName: "camera.fill"), vc: CameraView())
        let historyView = self.createNavigation(title: "History", image: UIImage(systemName: "arrow.counterclockwise"), selectedImage: UIImage(systemName: "arrow.counterclockwise.circle.fill"), vc: HistoryView())
        
        self.setViewControllers([pencilView, cameraView, historyView], animated: true)
        
    }
    
    private func createNavigation(title: String, image: UIImage?, selectedImage: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        nav.tabBarItem.selectedImage = selectedImage
       // nav.viewControllers.first?.navigationItem.title = title + " Controller"
       // nav.viewControllers.first?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Button", style: .plain, target: nil, action: nil)
        return nav
    }
}


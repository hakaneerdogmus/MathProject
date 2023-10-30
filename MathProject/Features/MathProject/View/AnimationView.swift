//
//  AnimationView.swift
//  MathProject
//
//  Created by Hakan ERDOĞMUŞ on 30.10.2023.
//

import UIKit
import Lottie

protocol AnimationViewProtocol: AnyObject {
    func configureAnimation()
    func pushNavigation()
    func stopAnimation()
}
class AnimationView: UIViewController {
    
    private let animationViewModel = AnimationViewModel()
    private let animation = LottieAnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationViewModel.view = self
        animationViewModel.viewDidLoad()
        
    }
}
extension AnimationView: AnimationViewProtocol {
    func configureAnimation() {
        animation.animation = LottieAnimation.named("MathWhite")
        //animation.frame = CGRect(x:20, y:50 , width: 100, height: 100)
        animation.frame = view.bounds
        animation.backgroundColor = .systemBackground
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.play()
        animation.backgroundColor = .gray
        //animation.removeFromSuperview()
        
        view.addSubview(animation)
        
    }
    
    func pushNavigation() {
        let tabBarView = TabBarView()
        self.navigationController?.pushViewController(tabBarView, animated: true)
    }
    
    func stopAnimation() {
        animation.stop()
        animation.isHidden = true
    }
    
    
}

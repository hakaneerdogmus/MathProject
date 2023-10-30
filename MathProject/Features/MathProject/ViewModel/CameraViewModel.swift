//
//  CameraViewModel.swift
//  MathProject
//
//  Created by Hakan ERDOĞMUŞ on 30.10.2023.
//

import UIKit

protocol CameraViewModelProtocol {
    var view: CameraViewProtocol? { get set }
    
    func viewDidLoad()

}

final class CameraViewModel {
    weak var view: CameraViewProtocol?
    
    var image: UIImage?
}

extension CameraViewModel: CameraViewModelProtocol {
    func viewDidLoad() {
        view?.configureVC()
        view?.configureCaptureSession()
        view?.configureCamera()
        view?.labelButton()
        
    }

}

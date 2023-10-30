//
//  PencilViewModel.swift
//  MathProject
//
//  Created by Hakan ERDOĞMUŞ on 30.10.2023.
//

import Foundation

protocol PencilViewModelProtocol {
    var view: PencilViewProtocol? { get set }
    
    func viewDidLoad()
}

final class PencilViewModel {
    weak var view: PencilViewProtocol?
}

extension PencilViewModel: PencilViewModelProtocol {
    func viewDidLoad() {
        view?.configureVC()
        view?.configureDrawingView()
       // view?.configureBarButton()
        view?.configureClearButton()
    }
}

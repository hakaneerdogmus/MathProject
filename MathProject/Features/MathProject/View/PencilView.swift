//
//  PencilView.swift
//  MathProject
//
//  Created by Hakan ERDOĞMUŞ on 30.10.2023.
//

import UIKit
import SnapKit

protocol PencilViewProtocol: AnyObject {
    func configureVC()
    func configureDrawingView()
    func configureBarButton()
    func configureClearButton()
    
}


class PencilView: UIViewController {
    private let pencilViewModel = PencilViewModel()
    private var clearAllButton: UIButton!
 
    private var drawingView: UIView!
    private var lastPoint: CGPoint?
    private var currentColor: UIColor = .white
    private var currentLineWidth: CGFloat = 2.0
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pencilViewModel.view = self
        pencilViewModel.viewDidLoad()
    }
    
}

extension PencilView: PencilViewProtocol {
    func configureVC() {
        view.backgroundColor = .orange
        navigationController?.navigationBar.isHidden = true
        
    }
    //DrawingView Configure
    func configureDrawingView() {
        drawingView = UIView()
        view.addSubview(drawingView)
        
        drawingView.backgroundColor = .black
        drawingView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top )
            
        }
        
        drawingViewSet()
    }
    //DrawingViewSet
    private func drawingViewSet() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        drawingView.addGestureRecognizer(panGesture)
    }
    //DrawingView selector handlePan
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let currentPoint = gesture.location(in: drawingView)
        
        if gesture.state == .began {
            lastPoint = currentPoint
        } else if gesture.state == .changed {
            if let lastPoint = lastPoint {
                drawLine(from: lastPoint, to: currentPoint)
            }
            lastPoint = currentPoint
        } else if gesture.state == .ended {
            lastPoint = nil
        }
    }
    //Draw Line
    func drawLine(from startPoint: CGPoint, to endPoint: CGPoint) {
        let drawingView = view.subviews.first!
        
        UIGraphicsBeginImageContext(drawingView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawingView.layer.render(in: context)
        
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(currentLineWidth)
        context.setStrokeColor(currentColor.cgColor)
        context.strokePath()
        
        drawingView.layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
    }
    //UIBarButtonItem
    func configureBarButton() {
            let clearButton = UIBarButtonItem()
            navigationItem.rightBarButtonItem = clearButton
            clearButton.style = .plain
            clearButton.target = self
            clearButton.title = "Clear"
            clearButton.tintColor = .white
            clearButton.action = #selector(clearAll)
        
    }
    //Clear All Button Configure
    func configureClearButton() {
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: tabBarController!.view.frame.size.width, height: 100)
        customView.backgroundColor = UIColor.blue
        tabBarController!.view.addSubview(customView)

//        clearAllButton = UIButton()
//        customView.addSubview(clearAllButton)
//
//        clearAllButton.backgroundColor = .red
//        clearAllButton.setTitle("Clear", for: .normal)
//        clearAllButton.setTitleColor(.white, for: .normal)
//        clearAllButton.addTarget(self, action: #selector(clearAll), for: .touchUpInside)
//        clearAllButton.snp.makeConstraints { make in
//            make.bottom.equalTo(drawingView.snp.top)
////            make.height.width.equalTo(50)
//            make.trailing.equalToSuperview().offset(-50)
//
//        }
        
    }
    //View All Clear Button
    @objc func clearAll() {
        DispatchQueue.main.async { [self] in
            drawingView.layer.contents = nil
            print("Clear All")
        }
    }
}

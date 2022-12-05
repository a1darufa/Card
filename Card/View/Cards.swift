//
//  Cards.swift
//  Card
//
//  Created by Айдар Абдуллин on 30.11.2022.
//

import UIKit

//MARK: Protocols
protocol FlippableView: UIView {
    var isFlipped: Bool { get set }
    var flipComplitionHandler: ((FlippableView) -> Void)? { get set }
    func flip()
}

//MARK: CardView
class CardView<ShapeType: ShapeLayerProtocol>: UIView, FlippableView {
    //MARK: CardView properties
    var color: UIColor!
    var isFlipped: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var flipComplitionHandler: ((FlippableView) -> Void)?
    var cornerRadius = 20
    
    //MARK: CardView private properties
    private let margin: Int = 10
    private var startTouchPoint: CGPoint!
    
    lazy var frontSideView: UIView = self.getFrontSideView()
    lazy var backSideView: UIView = self.getBackSideView()
    
    //MARK: Initialization
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        self.color = color
        
        setupBorders()
    }
    
    //MARK: Override methods
    override func draw(_ rect: CGRect) {
        backSideView.removeFromSuperview()
        frontSideView.removeFromSuperview()
        
        if isFlipped {
            self.addSubview(backSideView)
            self.addSubview(frontSideView)
        } else {
            self.addSubview(frontSideView)
            self.addSubview(backSideView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startTouchPoint = frame.origin
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sv = superview, let touch = touches.first else { return }
        
        let gameBoardFrame = sv.bounds
        let newLocation = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        
        var newFrame = self.frame.offsetBy(dx: newLocation.x - previousLocation.x, dy: newLocation.y - previousLocation.y)
        
        newFrame.origin.x = max(newFrame.origin.x, 0)
        newFrame.origin.x = min(newFrame.origin.x, gameBoardFrame.size.width - newFrame.size.width)
        
        newFrame.origin.y = max(newFrame.origin.y, 0)
        newFrame.origin.y = min(newFrame.origin.y, gameBoardFrame.size.height - newFrame.size.height)

        self.frame = newFrame
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.frame.origin == startTouchPoint {
            flip()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Methods
    func flip() {
        let fromView = isFlipped ? frontSideView : backSideView
        let toView = isFlipped ? backSideView : frontSideView
        
        UIView.transition(from: fromView, to: toView, duration: 0.5, options: [.transitionFlipFromTop], completion: { _ in
            self.flipComplitionHandler?(self)
        })
        
        isFlipped.toggle()
    }
    
    //MARK: Private methods
    private func setupBorders() {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    private func getFrontSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        
        view.backgroundColor = .white
        
        let shapeView = UIView(frame: CGRect(x: margin,
                                             y: margin,
                                             width: Int(self.bounds.width) - margin * 2,
                                             height: Int(self.bounds.height) - margin * 2))
        view.addSubview(shapeView)
        
        let shapeLayer = ShapeType(size: shapeView.frame.size, fillColor: color.cgColor)
        shapeView.layer.addSublayer(shapeLayer)
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
        
        return view
    }
    
    private func getBackSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        
        view.backgroundColor = .white
        
        switch ["circle", "line"].randomElement()! {
        case "circle":
            let layer = BackSideCirle(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer)
        case "line":
            let layer = BackSideLine(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer)
        default:
            break
        }
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
        
        return view
    }
}

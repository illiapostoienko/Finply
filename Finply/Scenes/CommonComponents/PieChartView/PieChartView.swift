//
//  PieChartView.swift
//  Finply
//
//  Created by Illia Postoienko on 09.11.2020.
//

import UIKit

@objc protocol PieChartViewDelegateType: class {
    @objc func itemSelected(index: Int)
    @objc func itemDeselected(index: Int)
}

struct PieChartItem {
    let value: CGFloat
    let color: UIColor
}

final class PieChartView: UIView {
    
    weak var delegate: PieChartViewDelegateType?

    var contentView: UIView!
    
    private(set) var items: [PieChartItem] = []
    
    private(set) var outerRadius: CGFloat = 0
    private(set) var innerRadius: CGFloat = 0
    private(set) var innerRadiusMultiplier: CGFloat = 0.5
    private(set) var selectedPieOffset: CGFloat = 0.0
    private(set) var animationDuration: Double = 1.0
    private(set) var isPieInteractionEnabled: Bool = false
    private(set) var selectedItemIndex: Int?
    private(set) var pieCenter: CGPoint = CGPoint()
    
    let startAngle: CGFloat = CGFloat(-Double.pi / 2)
    var endAngle: CGFloat { CGFloat(M_PI * 2) + startAngle }
    var strokeWidth: CGFloat { outerRadius - innerRadius }
    var strokeRadius: CGFloat { (outerRadius + innerRadius) / 2 }
    var total: CGFloat { items.reduce(0, { $0 + $1.value }) }
    
    private var currentFrame: CGRect = CGRect()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let newFrame = self.bounds
        guard contentView.frame != newFrame else { return }
        
        contentView.frame = newFrame
        outerRadius = newFrame.width / 2
        innerRadius = outerRadius * innerRadiusMultiplier
        pieCenter = CGPoint(x: newFrame.midX, y: newFrame.midY)
        reloadData(animated: false)
    }
    
    func setup(innerRadiusMultiplier: CGFloat = 0.5,
               selectedItemOffset: CGFloat = 0,
               animationDuration: Double = 1.0,
               isPieInteractionEnabled: Bool = false)
    {
        if innerRadiusMultiplier <= 1, innerRadiusMultiplier >= 0 {
            self.innerRadiusMultiplier = innerRadiusMultiplier
        }
        self.selectedPieOffset = selectedItemOffset
        self.animationDuration = animationDuration
        self.isPieInteractionEnabled = isPieInteractionEnabled
    }
    
    func set(items: [PieChartItem]) {
        self.items = items
        reloadData(animated: true)
    }
    
    private func initialSetup() {
        contentView = UIView(frame: self.bounds)
        addSubview(contentView)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let anyTouch: UITouch = touches.first as? UITouch, isPieInteractionEnabled {
            let selectedIndex = getSelectedLayerIndexOn(touch: anyTouch)
            handleLayerSelection(toIndex: selectedIndex)
        }
    }
}

// MARK: - Layers Math
extension PieChartView {

    private func reloadData(animated: Bool) {
        let baseLayer: CALayer = contentView.layer
        selectedItemIndex = nil
        
        contentView.isUserInteractionEnabled = false
        CATransaction.begin()
        CATransaction.setAnimationDuration(animated ? animationDuration : 0.0)
        CATransaction.setCompletionBlock { [weak self] in
            self?.contentView.isUserInteractionEnabled = true
        }
        
        baseLayer.sublayers.map{ sublayers in sublayers.map{ $0.removeFromSuperlayer() }}
        
        var strokeStart: CGFloat = 0.0
        var strokeEnd: CGFloat = 0.0
        var currentTotal: CGFloat = 0.0
        
        items.enumerated().forEach { (index, item) in
            let newLayer = createPieLayer()
            baseLayer.insertSublayer(newLayer, at: UInt32(index))

            strokeStart = currentTotal / total
            strokeEnd = (currentTotal + abs(item.value)) / total
            updateLayer(layer: newLayer, layerColor: item.color.cgColor, strokeStart: strokeStart, strokeEnd: strokeEnd)
            currentTotal += item.value
        }
        
        CATransaction.commit()
    }
    
    func updateLayer(layer: CAShapeLayer, layerColor: CGColor, strokeStart: CGFloat, strokeEnd: CGFloat) {
        let path = UIBezierPath(arcCenter: pieCenter, radius: strokeRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        createAnimationForLayer(layer: layer, key: "path", toValue: path.cgPath)
        
        layer.lineWidth = strokeWidth
        layer.strokeColor = layerColor
        
        createAnimationForLayer(layer: layer, key: "strokeStart", toValue: strokeStart)
        createAnimationForLayer(layer: layer, key: "strokeEnd", toValue: strokeEnd)
    }
    
    func createAnimationForLayer(layer: CAShapeLayer, key: String, toValue: Any) {
        
        let arcAnimation: CABasicAnimation = CABasicAnimation(keyPath: key)
        
        var fromValue: Any!
        if key == "strokeStart" || key == "strokeEnd" {
            fromValue = 0 as Any
        }
        
        layer.presentation().map{ fromValue = $0.value(forKey: key) as Any }
        
        arcAnimation.fromValue = fromValue
        arcAnimation.toValue = toValue
        arcAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        layer.add(arcAnimation, forKey: key)
        layer.setValue(toValue, forKey: key)
    }
    
    private func createPieLayer() -> CAShapeLayer {
        let pieLayer = CAShapeLayer()
        
        pieLayer.fillColor = UIColor.clear.cgColor
        pieLayer.borderColor = UIColor.clear.cgColor
        pieLayer.strokeStart = 0
        pieLayer.strokeEnd = 0

        return pieLayer
    }
}

// MARK: - Selection/Deselection
extension PieChartView {
    
    func handleLayerSelection(toIndex: Int?) {
        
        switch (selectedItemIndex, toIndex) {
        case (.some(let selected), .some(let toSelect)):
            deselectItemAtIndex(index: selected)
            
            if selected != toSelect {
                selectItemAtIndex(index: toSelect)
                selectedItemIndex = toSelect
            } else {
                selectedItemIndex = nil
            }
            
        case (.some(let selected), .none):
            deselectItemAtIndex(index: selected)
            selectedItemIndex = nil
            
        case (.none, .some(let toSelect)):
            selectItemAtIndex(index: toSelect)
            selectedItemIndex = toSelect
            
        case (.none, .none): return
        }
    }
    
    private func selectItemAtIndex(index: Int) {
        contentView.layer.sublayers.map {
            guard let layerToSelect = $0[safe: index] as? CAShapeLayer else { return }
            
            let currentPosition = layerToSelect.position
            let midAngle = (layerToSelect.strokeEnd + layerToSelect.strokeStart) * CGFloat(Double.pi) + startAngle
            let newPosition = CGPoint(x: currentPosition.x + selectedPieOffset * cos(midAngle),
                                      y: currentPosition.y + selectedPieOffset * sin(midAngle))
            layerToSelect.position = newPosition
        }
        
        delegate?.itemSelected(index: index)
    }
    
    private func deselectItemAtIndex(index: Int) {
        contentView.layer.sublayers.map {
            guard let layerToSelect = $0[safe: index] as? CAShapeLayer else { return }
            
            layerToSelect.position = CGPoint(x: 0, y: 0)
            layerToSelect.zPosition = 0
        }
        
        delegate?.itemDeselected(index: index)
    }
    
    private func getSelectedLayerIndexOn(touch: UITouch) -> Int? {
        guard let currentLayers = contentView.layer.sublayers else { return nil }
        
        var selectedIndex: Int?
        let point = touch.location(in: contentView)
        
        currentLayers.enumerated().forEach { index, layer in
            guard let layer = layer as? CAShapeLayer else { return }
            
            let pieStartAngle = layer.strokeStart * CGFloat(Double.pi * 2)
            let pieEndAngle = layer.strokeEnd * CGFloat(Double.pi * 2)
            
            var angle = atan2(point.y - pieCenter.y, point.x - pieCenter.x) - startAngle
            angle < 0 ? angle += CGFloat(Double.pi * 2) : ()
            
            let distance = sqrt(pow(point.x - pieCenter.x, 2) + pow(point.y - pieCenter.y, 2))
            if angle > pieStartAngle && angle < pieEndAngle && distance < outerRadius && distance > innerRadius
            {
                selectedIndex = index
            }
        }
        
        return selectedIndex
    }
}

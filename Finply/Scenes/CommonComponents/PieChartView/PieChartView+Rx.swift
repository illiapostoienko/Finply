//
//  PieChartView+Rx.swift
//  Finply
//
//  Created by Illia Postoienko on 09.11.2020.
//

import RxSwift
import RxCocoa

extension PieChartView: HasDelegate {
    public typealias Delegate = PieChartViewDelegateType
}

final class RxPieChartViewDelegateProxy: DelegateProxy<PieChartView, PieChartViewDelegateType>,
                                         DelegateProxyType,
                                         PieChartViewDelegateType
{
    weak private(set) var pieChartView: PieChartView?
    
    internal lazy var itemSelectedPublishSubject: PublishSubject<Int> = {
        let localSubject = PublishSubject<Int>()
        return localSubject
    }()
    internal lazy var itemDeselectedPublishSubject: PublishSubject<Int> = {
        let localSubject = PublishSubject<Int>()
        return localSubject
    }()
    
    public init(pieChartView: ParentObject) {
        self.pieChartView = pieChartView
        super.init(parentObject: pieChartView, delegateProxy: RxPieChartViewDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxPieChartViewDelegateProxy(pieChartView: $0) }
    }
    
    public static func currentDelegate(for object: PieChartView) -> PieChartViewDelegateType? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: PieChartViewDelegateType?, to object: PieChartView) {
        object.delegate = delegate
    }
    
    func itemSelected(index: Int) {
        itemSelectedPublishSubject.onNext(index)
        self._forwardToDelegate?.itemSelected(index: index)
    }
    
    func itemDeselected(index: Int) {
        itemDeselectedPublishSubject.onNext(index)
        self._forwardToDelegate?.itemDeselected(index: index)
    }
    
    deinit {
        itemSelectedPublishSubject.onCompleted()
        itemDeselectedPublishSubject.onCompleted()
    }
}

extension Reactive where Base: PieChartView {
    
    var items: Binder<[PieChartItem]> {
        Binder(self.base) { pieChart, items in
            pieChart.set(items: items)
        }
    }
    
    var didSelectItemAt: ControlEvent<Int> {
        let source = RxPieChartViewDelegateProxy.proxy(for: base).itemSelectedPublishSubject
        return ControlEvent(events: source)
    }
    
    var didDeselectItemAt: ControlEvent<Int> {
        let source = RxPieChartViewDelegateProxy.proxy(for: base).itemDeselectedPublishSubject
        return ControlEvent(events: source)
    }
}

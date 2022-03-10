//
//  CollectionViewDataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import UIKit

open class CollectionViewDataSource<SectionType: Hashable, ItemType: Hashable>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    ///UICollectionView的Header/Footer类型
    public enum ReusableViewKindType {
        case sectionHeader
        case sectionFooter
    }
    ///设置Cell闭包
    public typealias CellHandle  = ( UICollectionView, IndexPath, ItemType) -> UICollectionViewCell
    private let setCell : CellHandle
    ///设置Header/Footer闭包
    public typealias ReusableViewHandle = (UICollectionView, ReusableViewKindType, IndexPath, SectionType) -> UICollectionReusableView?
    private var setReusableView: ReusableViewHandle?
    
    ///点击事件
    public typealias DidSelectItemHandle = (UICollectionView, IndexPath, ItemType) -> Void
    private var didSelectItem : DidSelectItemHandle?
    public typealias DeselectItemHandle = (UICollectionView, IndexPath, ItemType) -> Void
    private var deSelectItem : DeselectItemHandle?
    public typealias ShouldSelectItemHandle = (UICollectionView, IndexPath, ItemType) -> Bool
    private var shouldSelectItem : ShouldSelectItemHandle?
    public typealias ShouldDeselectItemHandle = (UICollectionView, IndexPath, ItemType) -> Bool
    private var shouldDeselectItem : ShouldDeselectItemHandle?
    
    ///即将展示
    public typealias WillDisplayCellForItemAtHandle = (UICollectionView, UICollectionViewCell, IndexPath, ItemType) -> Void
    private var willDisplayCell: WillDisplayCellForItemAtHandle?
    ///cell大小
    public typealias SetSizeForItemHandle = (UICollectionView, UICollectionViewLayout, IndexPath, ItemType) -> CGSize
    private var setSizeForItem: SetSizeForItemHandle?
    ///header/footer大小
    public typealias SetSizeForHeaderFooterHandle = (UICollectionView, UICollectionViewLayout, Int, SectionType) -> CGSize
    private var setSizeForHeader: SetSizeForHeaderFooterHandle?
    private var setSizeForFooter: SetSizeForHeaderFooterHandle?
    ///Section缩进
    public typealias SetEdgeInsetForSectionHandle = (UICollectionView, UICollectionViewLayout, Int, SectionType) -> UIEdgeInsets
    private var setEdgeInsetForSection: SetEdgeInsetForSectionHandle?
    ///行列间距
    public typealias SetMinimumSpacingForSectionHandle = (UICollectionView, UICollectionViewLayout, Int, SectionType) -> CGFloat
    private var setMinimumLineSpacingForSection: SetMinimumSpacingForSectionHandle?
    private var setMinimumInteritemSpacingForSection: SetMinimumSpacingForSectionHandle?
    
    
    private weak var collectionView: UICollectionView?
    private let dataSource = DataSource<SectionType, ItemType>()
    
    /// 初始化CollectionViewDataSource,默认配置数据源代理
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - needDelegate: 是否需要代理方法
    ///   - cellGetter: 配置cell
    public required init(_ collectionView: UICollectionView, needDelegate: Bool = false, cellGetter: @escaping CellHandle ) {
        self.setCell  = cellGetter
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        if needDelegate{
            collectionView.delegate = self
        }
    }

    //MARK: 数据源代理 UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
 
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        let cell = setCell (collectionView, indexPath, item)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var type: ReusableViewKindType = .sectionHeader
        if kind == UICollectionView.elementKindSectionFooter{
            type = .sectionFooter
        }
        
        guard let sectionID = dataSource.sectionID(for: indexPath.section),
              let view = setReusableView?(collectionView, type, indexPath, sectionID) else {
            return UICollectionReusableView()
        }
        return view
    }
    
    //MARK: FlowLayout代理 UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{

        guard let item = dataSource.itemID(for: indexPath),
              let size = setSizeForItem?(collectionView, collectionViewLayout, indexPath, item) else {
            return CGSize(width: UIScreen.main.bounds.width, height: 60)
        }
        return size
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{

        guard let sectionID = dataSource.sectionID(for: section),
              let edge = setEdgeInsetForSection?(collectionView, collectionViewLayout, section, sectionID) else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return edge
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{

        guard let sectionID = dataSource.sectionID(for: section),
              let space = setMinimumLineSpacingForSection?(collectionView, collectionViewLayout, section, sectionID) else {
            return 0
        }
        return space
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{

        guard let sectionID = dataSource.sectionID(for: section),
              let space = setMinimumInteritemSpacingForSection?(collectionView, collectionViewLayout, section, sectionID) else {
            return 0
        }
        return space
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{

        guard let sectionID = dataSource.sectionID(for: section),
              let size = setSizeForHeader?(collectionView, collectionViewLayout, section, sectionID) else {
            return CGSize.zero
        }
        return size
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{

        guard let sectionID = dataSource.sectionID(for: section),
              let size = setSizeForFooter?(collectionView, collectionViewLayout, section, sectionID) else {
            return CGSize.zero
        }
        return size
    }
    
    //MARK:  代理 UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        didSelectItem?(collectionView, indexPath, item)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        deSelectItem?(collectionView, indexPath, item)
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        return shouldSelectItem?(collectionView, indexPath, item) ?? true
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        return shouldDeselectItem?(collectionView, indexPath, item) ?? true
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        willDisplayCell?(collectionView, cell, indexPath, item)
    }
}

extension CollectionViewDataSource{
    
    ///设置Header/Footer闭包
    @discardableResult
    public func setReusableView(_ callback:@escaping ReusableViewHandle) -> Self{
        setReusableView = callback
        return self
    }
    
    ///点击事件
    @discardableResult
    public func didSelectItem(_ callback:@escaping DidSelectItemHandle) -> Self{
        didSelectItem = callback
        return self
    }
    
    @discardableResult
    public func deSelectItem(_ callback:@escaping DeselectItemHandle) -> Self{
        deSelectItem = callback
        return self
    }
    
    @discardableResult
    public func shouldSelectItem(_ callback:@escaping ShouldSelectItemHandle) -> Self{
        shouldSelectItem = callback
        return self
    }
    
    @discardableResult
    public func shouldDeselectItem(_ callback:@escaping ShouldDeselectItemHandle) -> Self{
        shouldDeselectItem = callback
        return self
    }
    
    ///即将展示
    @discardableResult
    public func willDisplayCell(_ callback:@escaping WillDisplayCellForItemAtHandle) -> Self{
        willDisplayCell = callback
        return self
    }
    
    ///cell大小
    @discardableResult
    public func setSizeForItem(_ callback:@escaping SetSizeForItemHandle) -> Self{
        setSizeForItem = callback
        return self
    }
    
    ///header/footer大小
    @discardableResult
    public func setSizeForHeader(_ callback:@escaping SetSizeForHeaderFooterHandle) -> Self{
        setSizeForHeader = callback
        return self
    }
    
    @discardableResult
    public func setSizeForFooter(_ callback:@escaping SetSizeForHeaderFooterHandle) -> Self{
        setSizeForFooter = callback
        return self
    }
    
    ///Section缩进
    @discardableResult
    public func setEdgeInsetForSection(_ callback:@escaping SetEdgeInsetForSectionHandle) -> Self{
        setEdgeInsetForSection = callback
        return self
    }
    
    ///行列间距
    @discardableResult
    public func setMinimumLineSpacingForSection(_ callback:@escaping SetMinimumSpacingForSectionHandle) -> Self{
        setMinimumLineSpacingForSection = callback
        return self
    }
    
    @discardableResult
    public func setMinimumInteritemSpacingForSection(_ callback:@escaping SetMinimumSpacingForSectionHandle) -> Self{
        setMinimumInteritemSpacingForSection = callback
        return self
    }
    
    ///根据索引获取Item对象
    public func itemId(for indexPath: IndexPath) -> ItemType? {
        return dataSource.itemID(for: indexPath)
    }
    
    public func sectionId(for indexPath: IndexPath) -> SectionType? {
        return dataSource.sectionID(for: indexPath.section)
    }
    
    ///根据Item对象获取所在位置索引
    public func indexPath(for itemId: ItemType) -> IndexPath? {
        return dataSource.indexPath(for: itemId)
    }
    
    ///变更数据---相当于reload
    public func apply(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                      animation: Bool = false,
                      completion: (() -> Void)? = nil) {
        dataSource.apply(snapshot,
                         view: collectionView,
                         animatingDifferences: animation,
                         performUpdates: { collectionView, changeset, setSections in
            collectionView.reload(using: changeset, setData: setSections)
        }, completion: completion)
    }
    
    ///获取当前view快照
    public func snapshot() -> DataSourceSnapshot<SectionType, ItemType> {
        return dataSource.snapshot()
    }
    
///无数据比对方式情况下的数据操作
//    public func apply(_ snapshot: DataSourceSnapshot<SectionType, ItemType>) {
//        dataSource.sections = snapshot.structer.sections
//        collectionView?.reloadData()
//    }
//    
//    public func applyRows(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
//                          itemIndexPaths: [IndexPath]) {
//        dataSource.sections = snapshot.structer.sections
//        collectionView?.reloadItems(at: itemIndexPaths)
//    }
//    
//    public func applyRows(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
//                          itemIDs: [ItemType]) {
//        dataSource.sections = snapshot.structer.sections
//        var itemIndesPaths = [IndexPath]()
//        itemIDs.forEach { item in
//            guard let index = indexPath(for: item) else{return}
//            itemIndesPaths.append(index)
//        }
//        collectionView?.reloadItems(at: itemIndesPaths)
//    }
//    
//    public func applySections(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
//                              sectionIndex : Int) {
//        dataSource.sections = snapshot.structer.sections
//        collectionView?.reloadSections(IndexSet(integer: sectionIndex))
//    }
}

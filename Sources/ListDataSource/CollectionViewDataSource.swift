//
//  CollectionViewDataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import UIKit

public class CollectionViewDataSource<SectionType: Hashable, ItemType: Hashable>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    public enum ReusableViewKindType {
        case sectionHeader
        case sectionFooter
    }
    
    public typealias CellHandle  = ( UICollectionView, IndexPath, ItemType) -> UICollectionViewCell
    public typealias ReusableViewHandle = (UICollectionView, ReusableViewKindType, IndexPath, SectionType) -> UICollectionReusableView?
    public typealias DidSelectItemHandle = (UICollectionView, IndexPath, ItemType) -> Void
    public typealias WillDisplayCellForItemAtHandle = (UICollectionView, UICollectionViewCell, IndexPath, ItemType) -> Void
    
    public typealias SetSizeForItemHandle = (UICollectionView, UICollectionViewLayout, IndexPath, ItemType) -> CGSize
    public typealias SetSizeForHeaderFooterHandle = (UICollectionView, UICollectionViewLayout, Int, SectionType) -> CGSize
    
    public typealias SetEdgeInsetForSectionHandle = (UICollectionView, UICollectionViewLayout, Int, SectionType) -> UIEdgeInsets
    public typealias SetMinimumSpacingForSectionHandle = (UICollectionView, UICollectionViewLayout, Int, SectionType) -> CGFloat
    
    public let setCell : CellHandle
    public var didSelectItem : DidSelectItemHandle?
    public var setReusableView: ReusableViewHandle?
    public var willDisplayCell: WillDisplayCellForItemAtHandle?
    
    public var setSizeForItem: SetSizeForItemHandle?
    public var setSizeForHeader: SetSizeForHeaderFooterHandle?
    public var setSizeForFooter: SetSizeForHeaderFooterHandle?
    
    public var setEdgeInsetForSection: SetEdgeInsetForSectionHandle?
    public var setMinimumLineSpacingForSection: SetMinimumSpacingForSectionHandle?
    public var setMinimumInteritemSpacingForSection: SetMinimumSpacingForSectionHandle?
    
    private weak var collectionView: UICollectionView?
    private let dataSource = DataSource<SectionType, ItemType>()
    
    public required init(_ collectionView: UICollectionView, needDelegate: Bool = false, cellGetter: @escaping CellHandle ) {
        self.setCell  = cellGetter
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        if needDelegate{
            collectionView.delegate = self
        }
    }
 
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
 
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        let cell = setCell (collectionView, indexPath, item)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
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
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{

        guard let item = dataSource.itemID(for: indexPath),
              let size = setSizeForItem?(collectionView, collectionViewLayout, indexPath, item) else {
            return CGSize(width: UIScreen.main.bounds.width, height: 60)
        }
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{

        guard let sectionID = dataSource.sectionID(for: section),
              let edge = setEdgeInsetForSection?(collectionView, collectionViewLayout, section, sectionID) else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return edge
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{

        guard let sectionID = dataSource.sectionID(for: section),
              let space = setMinimumLineSpacingForSection?(collectionView, collectionViewLayout, section, sectionID) else {
            return 0
        }
        return space
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{

        guard let sectionID = dataSource.sectionID(for: section),
              let space = setMinimumInteritemSpacingForSection?(collectionView, collectionViewLayout, section, sectionID) else {
            return 0
        }
        return space
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{

        guard let sectionID = dataSource.sectionID(for: section),
              let size = setSizeForHeader?(collectionView, collectionViewLayout, section, sectionID) else {
            return CGSize.zero
        }
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{

        guard let sectionID = dataSource.sectionID(for: section),
              let size = setSizeForFooter?(collectionView, collectionViewLayout, section, sectionID) else {
            return CGSize.zero
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        didSelectItem?(collectionView, indexPath, item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("当前位置下的ItemType数据不存在")
        }
        willDisplayCell?(collectionView, cell, indexPath, item)
    }
}

extension CollectionViewDataSource{
    
    public func setReusableView(_ callback:@escaping ReusableViewHandle) {
        setReusableView = callback
    }
    
    public func didSelectItem(_ callback:@escaping DidSelectItemHandle) {
        didSelectItem = callback
    }
    
    public func willDisplayCell(_ callback:@escaping WillDisplayCellForItemAtHandle) {
        willDisplayCell = callback
    }
    
    public func setSizeForItem(_ callback:@escaping SetSizeForItemHandle) {
        setSizeForItem = callback
    }
    
    public func setSizeForHeader(_ callback:@escaping SetSizeForHeaderFooterHandle) {
        setSizeForHeader = callback
    }
    
    public func setSizeForFooter(_ callback:@escaping SetSizeForHeaderFooterHandle) {
        setSizeForFooter = callback
    }
    
    public func setEdgeInsetForSection(_ callback:@escaping SetEdgeInsetForSectionHandle) {
        setEdgeInsetForSection = callback
    }
    
    public func setMinimumLineSpacingForSection(_ callback:@escaping SetMinimumSpacingForSectionHandle) {
        setMinimumLineSpacingForSection = callback
    }
    
    public func setMinimumInteritemSpacingForSection(_ callback:@escaping SetMinimumSpacingForSectionHandle) {
        setMinimumInteritemSpacingForSection = callback
    }
    
    public func itemId(for indexPath: IndexPath) -> ItemType? {
        return dataSource.itemID(for: indexPath)
    }
    
    public func indexPath(for itemId: ItemType) -> IndexPath? {
        return dataSource.indexPath(for: itemId)
    }
    
    public func apply(_ snapshot: DataSourceSnapshot<SectionType, ItemType>) {
        dataSource.sections = snapshot.structer.sections
        collectionView?.reloadData()
    }
    
    public func applyRows(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                          itemIndexPaths: [IndexPath]) {
        dataSource.sections = snapshot.structer.sections
        collectionView?.reloadItems(at: itemIndexPaths)
    }
    
    public func applyRows(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                          itemIDs: [ItemType]) {
        dataSource.sections = snapshot.structer.sections
        var itemIndesPaths = [IndexPath]()
        itemIDs.forEach { item in
            guard let index = indexPath(for: item) else{return}
            itemIndesPaths.append(index)
        }
        collectionView?.reloadItems(at: itemIndesPaths)
    }
    
    public func applySections(_ snapshot: DataSourceSnapshot<SectionType, ItemType>,
                              sectionIndex : Int) {
        dataSource.sections = snapshot.structer.sections
        collectionView?.reloadSections(IndexSet(integer: sectionIndex))
    }
}

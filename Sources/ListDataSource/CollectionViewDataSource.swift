//
//  CollectionViewDataSource.swift
//  SwiftBrick
//
//  Created by iOS on 2021/7/16.
//  Copyright © 2021 狄烨 . All rights reserved.
//

import UIKit

public class CollectionViewDataSource<SectionType: Hashable, ItemType: Hashable>: NSObject, UICollectionViewDataSource{
 
    public typealias CellHandle  = (UICollectionView, IndexPath, ItemType) -> UICollectionViewCell
    public typealias ReusableViewHandle = (UICollectionView, String, IndexPath) -> UICollectionReusableView?
    public let setCell : CellHandle
    public var setReusableView: ReusableViewHandle?
    private weak var collectionView: UICollectionView?
    private let dataSource = DataSource<SectionType, ItemType>()
    
    public required init(_ collectionView: UICollectionView, cellGetter: @escaping CellHandle ) {
        self.setCell  = cellGetter
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
    }
 
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections()
    }
 
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
 
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = dataSource.itemID(for: indexPath) else {
            fatalError("cell nil")
        }
        let cell = setCell (collectionView, indexPath, item)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = setReusableView?(collectionView, kind, indexPath) else {
            return UICollectionReusableView()
        }

        return view
    }

}

extension CollectionViewDataSource{
    
    public func setReusableView(_ callback:@escaping ReusableViewHandle) {
        setReusableView = callback
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

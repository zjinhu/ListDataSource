//
//  Diff.swift
//  ListDataSource
//
//  Created by iOS on 2021/9/3.
//

import Foundation

protocol Diffable {
    var identifier: Int { get }
}

extension Diffable where Self: Hashable {
    var identifier: Int {
        return hashValue
    }
}

enum Diff {
    case insert(Int)
    case delete(Int)
    case move(from: Int, to: Int)
    case update(Int)
}

struct Differ{
    
    static func diff(old: [Diffable], new: [Diffable], isCollectionView: Bool = true) -> [Diff] {
        let deletes = old.enumerated().compactMap({ map -> (offset: Int, element: Diffable)? in
            if new.firstIndex(where: { item in item.identifier == map.element.identifier }) == nil {
                return map
            }
            return nil
        })
        
        let inserts = new.enumerated().compactMap({ map -> (offset: Int, element: Diffable)? in
            if old.firstIndex(where: { item in item.identifier == map.element.identifier }) == nil {
                return map
            }
            return nil
        })
        
        var oldInsertAndDelete = old
        
        if !isCollectionView {
            var removed = 0
            deletes.forEach { item in
                oldInsertAndDelete.remove(at: item.offset - removed)
                removed += 1
            }
            
            inserts.forEach { item in
                oldInsertAndDelete.insert(item.element, at: item.offset)
            }
        }
        
        
        let moves: [(from: (offset: Int, element: Diffable), to: (offset: Int, element: Diffable))]
            = new.enumerated().compactMap({ map in
                if let oldIndex = oldInsertAndDelete.enumerated().first(where: { item in item.element.identifier == map.element.identifier }),
                   map.offset != oldIndex.offset {
                    return (oldIndex, map)
                }
                return nil
            })
        
        
        return [
            deletes.map({ m in
                .delete(m.offset)
            }),
            inserts.map({ m in
                .insert(m.offset)
            }),
            moves.map({ m in
                .move(from: m.from.offset, to: m.to.offset)
            })
        ].flatMap { $0 }
    }
    
    static func diff<T>(old: [T], new: [T], skipUpdates: Bool, isCollectionView: Bool) -> [Diff] where T: Diffable, T: Equatable {
        let diffWithoutUpdates = diff(old: old, new: new, isCollectionView: isCollectionView)
        
        let updates: [Int]
        
        if skipUpdates {
            updates = []
        } else {
            updates = new.enumerated().compactMap({ index, element -> Int? in
                if index < old.count, element.identifier == old[index].identifier, element != old[index],
                   !diffWithoutUpdates.moves.contains(where: { item in item.to == index}){
                    return index
                }
                return nil
            })
        }
        
        return [
            diffWithoutUpdates,
            updates.map { m in
                .update(m)
            },
        ].flatMap { $0 }
    }
}


extension Collection where Element == Diff {
    var deletions: [Int] {
        return compactMap { map in
            switch map {
            case .delete(let index):
                return index
            default:
                return nil
            }
        }
    }
    
    
    var insertions: [Int] {
        return compactMap { map in
            switch map {
            case .insert(let index):
                return index
            default:
                return nil
            }
        }
    }
    
    var moves: [(from: Int, to: Int)] {
        return compactMap { map in
            switch map {
            case .move(let from, let to):
                return (from, to)
            default:
                return nil
            }
        }
    }
    
    var updates: [Int] {
        return compactMap { map in
            switch map {
            case .update(let index):
                return index
            default:
                return nil
            }
        }
    }
}

//
//  CollectionViewController.swift
//  ListDataSource
//
//  Created by iOS on 2021/7/23.
//

import UIKit
import SwiftBrick
import SwiftMediator
//1.首先确定数据源格式--即model
struct Item2: Hashable {
    var title : String?
    var colorTwo : UIColor?
}

struct Item1: Hashable {
    var name : String
    var color : UIColor?
}

enum MoreItem: Hashable {
  case one(Item1)
  case two(Item2)
}

class CollectionViewController: JHCollectionViewController {
    ///2.快照
    lazy var shot = DataSourceSnapshot<Section,MoreItem>()
    ///3.数据源
    lazy var secion1 = Section(title: "1", color: .red)
    lazy var secion2 = Section(title: "2", color: .cyan)
    
    lazy var dataSource = CollectionViewDataSource<Section, MoreItem>.init(collectionView!, needDelegate: true) { collectionView, indexPath, model in
        
        switch model {
        case .one(let one):
            let cell = collectionView.dequeueReusableCell(JHCollectionViewCell.self, indexPath: indexPath)

            cell.backgroundColor = one.color
            cell.subviews.forEach{ $0.removeFromSuperview(); }

            let label = UILabel.init(frame: cell.bounds)
            label.text = one.name
            label.textAlignment = .center
            cell.addSubview(label)
            
            return cell
        case .two(let two):
            let cell = collectionView.dequeueReusableCell(JHCollectionViewCell.self, indexPath: indexPath)

            cell.backgroundColor = two.colorTwo
            cell.subviews.forEach{ $0.removeFromSuperview(); }

            let label = UILabel.init(frame: cell.bounds)
            label.text = two.title
            label.textAlignment = .center
            cell.addSubview(label)
            
            return cell
        }

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionHeader)
        collectionView?.registerHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionFooter)
        collectionView?.alwaysBounceVertical = true
        
        addButtons()
        
        collectionViewConfig()
    }
    
    
    func collectionViewConfig(){
        shot.appendSections([secion1, secion2])
        
        shot.appendItems([.one(Item1(name: "11", color: .cyan)),
                          .one(Item1(name: "22", color: .cyan)),
                          .one(Item1(name: "33", color: .cyan))], toSection: secion1)
        shot.appendItems([.two(Item2(title: "11", colorTwo: .red)),
                          .two(Item2(title: "22", colorTwo: .red)),
                          .two(Item2(title: "33", colorTwo: .red))], toSection: secion2)

        dataSource.apply(shot)
        
        dataSource.didSelectItem { collectionView, indexPath, model in
            print("index,\(indexPath)")
        }
        
        dataSource.setEdgeInsetForSection { collectionView, layout, index, sectionModel in
            switch index {
            case 0:
                return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            default:
                return UIEdgeInsets.zero
            }
            
        }
        
        dataSource.setSizeForItem { collectionView, layout, indexPath, model in
            switch model {
            case .one( _):
                return CGSize(width: 50, height: 50)
            case .two( _):
                return CGSize(width: ScreenWidth, height: 60)
            }
        }
        
        dataSource.setMinimumLineSpacingForSection { collectionView, layout, index, sectionModel in
            switch index {
            case 0:
                return 1
            default:
                return 1
            }
        }
        
        dataSource.setMinimumInteritemSpacingForSection { collectionView, layout, index, sectionModel in
            switch index {
            case 0:
                return 1
            default:
                return 1
            }
        }

        dataSource.setReusableView { collectionView, type, indexPath, sectionModel in
            if type == .sectionHeader{
                let header = collectionView.dequeueReusableHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionHeader, indexPath: indexPath)
                header.subviews.forEach{ $0.removeFromSuperview(); }
                header.backgroundColor = sectionModel.color
                let label = UILabel.init(frame: header.bounds)
                label.text = "----\(sectionModel.title)---- 头部 ---------"
                label.textAlignment = .center
                header.addSubview(label)
                return header
            }else{
                let footer = collectionView.dequeueReusableHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionFooter, indexPath: indexPath)
                footer.subviews.forEach{ $0.removeFromSuperview(); }
                footer.backgroundColor = sectionModel.color
                let label = UILabel.init(frame: footer.bounds)
                label.text = "-----\(sectionModel.title)--- 尾部 ---------"
                label.textAlignment = .center
                footer.addSubview(label)
                return footer
            }
        }

        dataSource.setSizeForHeader { collectionView, layout, section, sectionModel in
            return CGSize(width: UIScreen.main.bounds.width, height: 40)
        }
        
        dataSource.setSizeForFooter { collectionView, layout, section, sectionModel in
            return CGSize(width: UIScreen.main.bounds.width, height: 40)
        }
    }
    
    func addButtons(){

        addRightBarButton(text: "清空", normalColor: .darkGray, highlightColor: .lightGray, touchUp: { [weak self] _ in
            guard let `self` = self else{return}
            self.shot.deleteAll()
            self.dataSource.apply(self.shot)
        })
        
    }
    
}

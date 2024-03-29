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
///此处可以根据cell显示不同Model不同进行多样化枚举
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
        ///根据不同的数据源类型配置不同的Cell
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
        ///注册cell 和 Header/Footer
        collectionView?.registerHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionHeader)
        collectionView?.registerHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionFooter)
        collectionView?.alwaysBounceVertical = true
        
        addButtons()
        
        collectionViewConfig()
    }
    
    override func setupFlowLayout() -> UICollectionViewFlowLayout{
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.sectionHeadersPinToVisibleBounds = true
        return flowLayout
    }
    
    func collectionViewConfig(){
        ///针对数据的配置
        shot.appendSections([secion1, secion2])
        
        shot.appendItems([.one(Item1(name: "1", color: .cyan)),
                          .one(Item1(name: "2", color: .cyan)),
                          .one(Item1(name: "3", color: .cyan)),
                          .one(Item1(name: "4", color: .cyan)),
                          .one(Item1(name: "5", color: .cyan)),
                          .one(Item1(name: "6", color: .cyan)),
                          .one(Item1(name: "7", color: .cyan)),
                          .one(Item1(name: "8", color: .cyan)),
                          .one(Item1(name: "9", color: .cyan)),
                          .one(Item1(name: "10", color: .cyan)),
                          .one(Item1(name: "11", color: .cyan)),
                          .one(Item1(name: "12", color: .cyan)),
                          .one(Item1(name: "13", color: .cyan)),
                          .one(Item1(name: "14", color: .cyan)),
                          .one(Item1(name: "15", color: .cyan)),
                          .one(Item1(name: "16", color: .cyan)),
                          .one(Item1(name: "17", color: .cyan))], toSection: secion1)
        shot.appendItems([.two(Item2(title: "1", colorTwo: .random)),
                          .two(Item2(title: "2", colorTwo: .random)),
                          .two(Item2(title: "3", colorTwo: .random)),
                          .two(Item2(title: "4", colorTwo: .random)),
                          .two(Item2(title: "5", colorTwo: .random)),
                          .two(Item2(title: "6", colorTwo: .random)),
                          .two(Item2(title: "7", colorTwo: .random)),
                          .two(Item2(title: "8", colorTwo: .random)),
                          .two(Item2(title: "9", colorTwo: .random))], toSection: secion2)

        dataSource.apply(shot)
        
        ///针对样式的配置
        dataSource.didSelectItem { collectionView, indexPath, model in
            print("index,\(indexPath)")
        }
        .setEdgeInsetForSection { collectionView, layout, index, sectionModel in
            switch index {
            case 0:
                return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            default:
                return UIEdgeInsets.zero
            }
            
        }
        .setSizeForItem { collectionView, layout, indexPath, model in
            switch model {
            case .one( _):
                return CGSize(width: 50, height: 50)
            case .two( _):
                return CGSize(width: ScreenWidth, height: 60)
            }
        }
        .setMinimumLineSpacingForSection { collectionView, layout, index, sectionModel in
            switch index {
            case 0:
                return 1
            default:
                return 1
            }
        }
        .setMinimumInteritemSpacingForSection { collectionView, layout, index, sectionModel in
            switch index {
            case 0:
                return 1
            default:
                return 1
            }
        }
        .setReusableView { collectionView, type, indexPath, sectionModel in
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
        .setSizeForHeader { collectionView, layout, section, sectionModel in
            return CGSize(width: UIScreen.main.bounds.width, height: 40)
        }
        .setSizeForFooter { collectionView, layout, section, sectionModel in
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

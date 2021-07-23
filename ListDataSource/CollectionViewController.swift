//
//  CollectionViewController.swift
//  ListDataSource
//
//  Created by iOS on 2021/7/23.
//

import UIKit
import SwiftBrick
import SwiftMediator

class CollectionViewController: JHCollectionViewController {
    lazy var dataSource = CollectionViewDataSource<Section, Item>.init(collectionView!, needDelegate: true) { collectionView, indexPath, model in
        let cell = collectionView.dequeueReusableCell(JHCollectionViewCell.self, indexPath: indexPath)

        cell.backgroundColor = model.color
        cell.subviews.forEach{ $0.removeFromSuperview(); }

        let label = UILabel.init(frame: cell.bounds)
        label.text = model.name
        label.textAlignment = .center
        cell.addSubview(label)
        
        return cell
    }
    
    var shot = DataSourceSnapshot<Section,Item>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionHeader)
        collectionView?.registerHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionFooter)
        collectionView?.alwaysBounceVertical = true
        
        addButtons()
        
        collectionViewConfig()
    }
    
    func collectionViewConfig(){
        shot.appendSections([Section(title: "1", color: .red)])
        shot.appendItems([Item(name: "1", color: .yellow),Item(name: "11", color: .cyan),Item(name: "111", color: .green),Item(name: "1111", color: .purple)])
        dataSource.apply(shot)
        
        dataSource.didSelectItem { collectionView, indexPath, model in
            print("index,\(indexPath)")
        }
        
        dataSource.setSizeForItem { collectionView, layout, indexPath, model in
            return CGSize(width: 100, height: 100)
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
                let footer = collectionView.dequeueReusableHeaderFooterView(JHCollectionReusableView.self, kindType: .sectionHeader, indexPath: indexPath)
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
        
        UIButton.snpButton(supView: view, backColor: .orange, title: "添加section", touchUp: { (_) in
            let sec = Section(title: "2", color: .yellow)
            self.shot.appendSections([sec])
//            self.shot.insertSections([sec], beforeSection: Section(title: "1"))
            self.shot.appendItems([Item(name: "2", color: .systemBlue),Item(name: "3", color: .systemBlue),Item(name: "4", color: .systemBlue),Item(name: "5", color: .systemBlue)], toSection: sec)
            self.dataSource.apply(self.shot)
            
        }) { (m) in
            m.left.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        
        UIButton.snpButton(supView: view, backColor: .orange, title: "s1添加元素", touchUp: { (_) in
            self.shot.appendItems([Item(name: "6", color: .systemTeal),Item(name: "7", color: .systemTeal),Item(name: "8", color: .systemTeal),Item(name: "9", color: .systemTeal)], toSection: Section(title: "1", color: .red))
//            self.shot.insertItems([Item(name: "6"),Item(name: "7"),Item(name: "8"),Item(name: "9")], beforeItem: Item(name: "11"))
            self.dataSource.apply(self.shot)
        }) { (m) in
            m.right.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        
        UIButton.snpButton(supView: view, backColor: .orange, title: "删s1中的1111", touchUp: { (_) in
            self.shot.deleteItems([Item(name: "1111", color: .purple)])
            self.dataSource.apply(self.shot)
        }) { (m) in
            m.centerX.bottom.equalToSuperview()
            m.bottom.equalToSuperview().offset(-60)
            m.width.equalTo(100)
            m.height.equalTo(40)
        }
        
    }
}

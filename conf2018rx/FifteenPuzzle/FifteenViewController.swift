//
//  FifteenViewController.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class FifteenViewController: UIViewController {

    struct ViewModel {
        struct Item: IdentifiableType, Equatable {
            let value: Int
            let text: String
            let selected: Bool

            var identity: Int { return value }

            static func ==(lhs: Item, rhs: Item) -> Bool {
                return lhs.value == rhs.value
                    && lhs.text == rhs.text
                    && lhs.selected == rhs.selected
            }
        }

        var rows: [AnimatableSectionModel<String, Item>] = []
        var cheer: String = ""
        var turns: String = ""

        var timestamp = Date()
    }

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var turnsLabel: UILabel!
    @IBOutlet weak var collectionVIew: UICollectionView!

    let disposeBag = DisposeBag()

    var viewModelRelay = ReplaySubject<ViewModel>.create(bufferSize: 1)

    var _viewModel: Binder<ViewModel> {
        return Binder(self) { this, viewModel in
            this.viewModelRelay.onNext(viewModel)
        }
    }

    func events() -> Observable<Event> {
        return collectionVIew.rx.itemSelected
            .map { Event.tappedAt($0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModelRelay
            .map {
                $0.cheer
            }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)

        viewModelRelay
            .map {
                $0.turns
            }
            .bind(to: turnsLabel.rx.text)
            .disposed(by: disposeBag)

        viewModelRelay
            .map {
                $0.rows
            }
            .bind(to: collectionVIew.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let size = view.bounds.size.width / 4
        let flowLayout = collectionVIew.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: size, height: size)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, ViewModel.Item>>(configureCell: { ds, collectionView, index, model in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(UIFifteenCollectionViewCell.self)", for: index) as! UIFifteenCollectionViewCell
        cell.setup(model: model)        
        return cell
    }, configureSupplementaryView: { _,_,_,_ in
        fatalError()
    })
}

extension FifteenViewController.ViewModel {
    static let solved: FifteenViewController.ViewModel = {
        var vm = FifteenViewController.ViewModel()
        vm.cheer = "Победа!"

        vm.rows = (0...3).map { row -> AnimatableSectionModel<String, Item> in
            let startItemIndex = row * 4
            let endItemIndex = startItemIndex + 3
            return AnimatableSectionModel<String, Item>(
                model: "",
                items: (startItemIndex...endItemIndex).map { item in
                    Item(value: item + 1, text: "\(item + 1)", selected: item == 0)
                }
            )
        }

        return vm
    }()
}

//
//  UIFifteenCollectionViewCell.swift
//  conf2018rx
//
//  Created by Evgeniy Gubin on 11.06.2018.
//  Copyright © 2018 SimbirSoft. All rights reserved.
//

import UIKit

class UIFifteenCollectionViewCell: UICollectionViewCell {

    @IBOutlet var numberLabel: UILabel!

    func setup(model: FifteenViewController.ViewModel.Item) {
        numberLabel.text = model.text
        contentView.backgroundColor = model.selected ? UIColor(white: 0.8, alpha: 1) : nil
    }
}

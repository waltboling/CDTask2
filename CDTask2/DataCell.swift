//
//  DataCell.swift
//  CDTask2
//
//  Created by Jon Boling on 5/3/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit

class DataCell: UICollectionViewCell {
    
    
    @IBOutlet weak var personLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = 3.0
            self.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        }
    }
}

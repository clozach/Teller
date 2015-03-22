//
//  SimpleTextCell.swift
//  Teller
//
//  Created by Chris Lozac'h on 3/21/15.
//  Copyright (c) 2015 Chris Lozac'h. All rights reserved.
//

import UIKit

class SimpleTextCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    func setText(text: String) {
        label?.text = text
    }
}

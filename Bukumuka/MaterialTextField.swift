//
//  MaterialTextField.swift
//  Bukumuka
//
//  Created by Nicole on 05/09/2016.
//  Copyright © 2016 Loong. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
        layer.borderWidth = 1.0
        
    }
    
    //for placeholder
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        //move text 10 pixels to the right
        return CGRectInset(bounds, 10, 0)
    }
    
    //for editable text
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }

}

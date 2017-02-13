//
//  Model.swift
//  Flicks
//
//  Created by Ryuji Mano on 2/13/17.
//  Copyright © 2017 Ryuji Mano. All rights reserved.
//

import Foundation
import UIKit

class Model {
    
    static func getStars(of rating:Double, with star1:UIImageView, _ star2:UIImageView, _ star3:UIImageView, _ star4:UIImageView, _ star5:UIImageView) {
        if rating < 1.6 {
            star1.alpha = 1
            star2.alpha = 0
            star3.alpha = 0
            star4.alpha = 0
            star5.alpha = 0
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-4-240")
        }
        else if rating < 2.5 {
            star1.alpha = 1
            star2.alpha = 0
            star3.alpha = 0
            star4.alpha = 0
            star5.alpha = 0
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
        }
        else if rating < 3.6 {
            star1.alpha = 1
            star2.alpha = 1
            star3.alpha = 0
            star4.alpha = 0
            star5.alpha = 0
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star2.image = #imageLiteral(resourceName: "iconmonstr-star-4-240")
        }
        else if rating < 4.5 {
            star1.alpha = 1
            star2.alpha = 1
            star3.alpha = 0
            star4.alpha = 0
            star5.alpha = 0
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star2.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
        }
        else if rating < 5.6 {
            star1.alpha = 1
            star2.alpha = 1
            star3.alpha = 1
            star4.alpha = 0
            star5.alpha = 0
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star2.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star3.image = #imageLiteral(resourceName: "iconmonstr-star-4-240")
        }
        else if rating < 6.5 {
            star1.alpha = 1
            star2.alpha = 1
            star3.alpha = 1
            star4.alpha = 0
            star5.alpha = 0
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star2.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star3.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
        }
        else if rating < 7.6 {
            star1.alpha = 1
            star2.alpha = 1
            star3.alpha = 1
            star4.alpha = 1
            star5.alpha = 0
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star2.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star3.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star4.image = #imageLiteral(resourceName: "iconmonstr-star-4-240")
        }
        else if rating < 8.5 {
            star1.alpha = 1
            star2.alpha = 1
            star3.alpha = 1
            star4.alpha = 1
            star5.alpha = 0
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star2.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star3.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star4.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            
        }
        else if rating < 9.6 {
            star1.alpha = 1
            star2.alpha = 1
            star3.alpha = 1
            star4.alpha = 1
            star5.alpha = 1
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star2.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star3.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star4.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star5.image = #imageLiteral(resourceName: "iconmonstr-star-4-240")
        }
        else {
            star1.alpha = 1
            star2.alpha = 1
            star3.alpha = 1
            star4.alpha = 1
            star5.alpha = 1
            star1.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star2.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star3.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star4.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
            star5.image = #imageLiteral(resourceName: "iconmonstr-star-3-240")
        }
    }
    
}

//
//  Message.swift
//  YARN_ZANKOAV
//
//  Created by Alexandr Zanko on 8/25/17.
//  Copyright © 2017 Alexandr Zanko. All rights reserved.
//

import Foundation
import SwiftyJSON

class Message {
    
    private var _message:String?
    private var _author:String?
    
    var message:String?{
        return _message
    }
    
    var author:String?{
        return _author
    }
    
    init(json: JSON){
        self._message = json["message"].description
        self._author = json["author"].description
    }
}

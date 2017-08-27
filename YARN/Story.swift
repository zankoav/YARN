//
//  History.swift
//  YARN_ZANKOAV
//
//  Created by Alexandr Zanko on 8/25/17.
//  Copyright © 2017 Alexandr Zanko. All rights reserved.
//

import AlamofireImage
import SwiftyJSON

class Story {
    
    private var _storyName:String?
    private var _storyAuthorName:String?
    private var _shortDescription:String?
    private var _coverImageUrl:String?
    private var _date:String?
    private var _url:String?
    private var _messagesCount:Int
    private var _totalMessagesCount:Int?
    
    private var _image:Image?

    
    var storyName:String?{
        return _storyName
    }
    
    var storyAuthorName:String?{
        return _storyAuthorName
    }
    
    var shortDescription:String?{
        return _shortDescription
    }
    
    var coverImageUrl:String?{
        return self._coverImageUrl
    }
    
    var time:Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from:self._date!)!
    }
    
    var url:String?{
        return self._url
    }
    
    var messagesCount:Int{
        return self._messagesCount
    }
    
    var totalMessagesCount:Int?{
        return self._totalMessagesCount
    }
    
    var image: Image?{
        return self._image
    }
    
    init(json: JSON) {
        
        self._storyName = json["storyName"].description
        self._storyAuthorName = json["storyAuthorName"].description
        self._shortDescription = json["shortDescription"].description
        self._coverImageUrl = json["coverImageUrl"].description
        self._date = json["date"].description
        self._url = json["url"].description
        self._messagesCount = 0
        
    }
    
    func addMessage(){
        if self._messagesCount < self.totalMessagesCount!{
            self._messagesCount += 1
        }
    }
    
    func setTotalMessagesCount(totalCount: Int){
        self._totalMessagesCount = totalCount
    }
    
    func setImage(img: Image){
        self._image = img
    }

    
}

//
//  ViewController.swift
//  YARN_ZANKOAV
//
//  Created by Alexandr Zanko on 8/24/17.
//  Copyright © 2017 Alexandr Zanko. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EpisodeViewController: UIViewController {

    private var story: Story!
    private var messages = Array<Message>()
    
    @IBOutlet weak var layerView: UIView!
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    @IBOutlet weak var autorTemp: UILabel!
    @IBOutlet weak var topMenu: UIView!
    @IBOutlet weak var messageTemp: UILabel!
    
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var position:CGFloat = 60
    var autors = Dictionary<String,UIColor>()
    var colors:[UIColor] = [.blue, .red, .green, .orange]
    private var screenWidthNoMarging:CGFloat!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator("Loading...")
        if let url = story.url{
            Alamofire.request(url).responseJSON { response in
                response.result.ifSuccess {
                    if let data = response.data {
                        let storyJson = JSON(data: data)
                        self.story.setTotalMessagesCount(totalCount: storyJson["messages"].count)
                        for messageJson in storyJson["messages"] {
                            let autor = messageJson.1["author"].description
                            if self.autors.index(forKey: autor) == nil {
                                if self.autors.count <= self.colors.count {
                                    self.autors[autor] = self.colors[self.autors.count]
                                }else{
                                    self.autors[autor] = .brown
                                }
                            }
                            self.messages.append(Message(json: messageJson.1))
                        }
                        self.loadComplate()
                    }
                }
                response.result.ifFailure {
                    print("Error loading")
                }
            }
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenWidthNoMarging = UIScreen.main.bounds.width - 24
        storyTitle.text = story.storyName
        
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.topMenu.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.topMenu.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 0.9
            self.topMenu.insertSubview(blurEffectView, at: 0)
        } else {
            self.topMenu.backgroundColor = UIColor.black
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setStory(story: Story){
        self.story = story
    }

    @IBAction func showEpisodes(_ sender: Any) {
        let alert = UIAlertController(title: "Show episodes", message: "only one episode", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closeStoryAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showNewMessageAction(_ sender: Any) {
        if self.story.totalMessagesCount! > self.story.messagesCount{
            self.showMessage(message: messages[self.story.messagesCount])
            self.story.addMessage()
        }
    }
    
    private func loadComplate(){
        let count = self.story.messagesCount
        sleep(1)
        effectView.removeFromSuperview()
        if count > 0 {
            for index in 0..<self.story.messagesCount {
                self.showMessage(message: self.messages[index])
            }
        }else{
            self.showMessage(message: self.messages.first!)
            self.story.addMessage()
        }
    }
    
    private func showMessage(message: Message){
        let messageView = MessageView()
        messageView.alpha = 0.0
        autorTemp.text = message.author
        messageTemp.text = message.message
        view.layoutIfNeeded()

        let width = max(autorTemp.bounds.width, messageTemp.bounds.width) + 16        
        let height = messageTemp.bounds.height + 36

        messageView.frame = CGRect(x: 12, y: position, width: width, height: height)
        messageView.desc.text = message.message
        messageView.name.text = message.author
        messageView.name.textColor = autors[message.author!]
        if self.story.messagesCount == 0 {
            layerView.addSubview(messageView)
        }else{
            layerView.addSubview(messageView)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseOut, animations: {
            messageView.alpha = 1.0
        }, completion: nil)
        
        position += messageView.bounds.height + 16
        scrollView.contentSize.height = position + scrollView.bounds.size.height/2
        let point = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(point, animated: true)
    }
    
    private func activityIndicator(_ title: String) {
        
        var activityIndicator = UIActivityIndicatorView()
        var strLabel = UILabel()
        
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.addSubview(activityIndicator)
        effectView.addSubview(strLabel)
        view.addSubview(effectView)
    }

}


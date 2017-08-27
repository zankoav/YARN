//
//  MainViewController.swift
//  YARN_ZANKOAV
//
//  Created by Alexandr Zanko on 8/26/17.
//  Copyright © 2017 Alexandr Zanko. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    private var stories = Array<Story>()
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private var imageCache: ImageRequestCache!
    private var imageDownloader:ImageDownloader!
    private let URL_STORIES = "http://spookytalks.com/files/stories.json"
    
    private var storyBgWidth:CGFloat!
    private var storyBgHeight:CGFloat!
    
    private var loadCounts = 3
    
    private var storiesJson:JSON?


    @IBOutlet weak var labelApp: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storyBgWidth = UIScreen.main.bounds.width
        self.storyBgHeight = storyBgWidth*2/3
        sleep(1)
        activityIndicator("Loading ...")
        Alamofire.request(URL_STORIES).responseJSON { response in
            response.result.ifSuccess {
                if let data = response.data {
                    self.storiesJson = JSON(data: data)
                    self.imageDownloader = ImageDownloader()
                    for storyJson in self.storiesJson! {
                        self.startLoading(jsonStory: storyJson.1)
                    }
                }
                
            }
            response.result.ifFailure {
                print("Error loading")
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.storyBgHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellStory", for: indexPath) as! StoryTableViewCell
        
        cell.titleStory.text = stories[indexPath.row].storyName
        cell.subTitleStory.text = stories[indexPath.row].shortDescription
        
        if let img = stories[indexPath.row].image {
             cell.bgImageStory.image = img
        }else{
            cell.bgImageStory.af_setImage(withURL: URL(string: stories[indexPath.row].coverImageUrl!)!)
        }
        
        if let totalCount = stories[indexPath.row].totalMessagesCount{
            if totalCount != 0 {
                cell.progressBar.progress = Float(stories[indexPath.row].messagesCount)/Float(totalCount)
            }else{
                cell.progressBar.progress = 0
            }
        }else{
            cell.progressBar.progress = 0
        }
        return cell
    }
    
    
    private func startLoading(jsonStory: JSON){
        let url = jsonStory["coverImageUrl"].description
        let urlRequest = URLRequest(url: URL(string: url)!)
        self.imageDownloader?.download(urlRequest) { response in
            if let image = response.result.value {
                let size = CGSize(width: self.storyBgWidth, height: self.storyBgHeight)
                let avatarImage = image.af_imageAspectScaled(toFill: size)
                let story = Story(json: jsonStory)
                story.setImage(img: avatarImage)
                self.stories.append(story)
                self.stories.sort { $0.time < $1.time }
                if self.stories.count == self.loadCounts {
                    self.loadComplate()
                }else if self.stories.count > self.loadCounts{
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func loadComplate(){
        effectView.removeFromSuperview()
        labelApp.isHidden = false
        self.tableView.reloadData()
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


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let episodeVC = segue.destination as! EpisodeViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            episodeVC.setStory(story: self.stories[(indexPath?.row)!])
        }
    }


}

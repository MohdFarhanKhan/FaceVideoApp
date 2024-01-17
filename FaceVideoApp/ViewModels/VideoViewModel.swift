//
//  VideoViewModel.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 28/06/1445 AH.
//

import Foundation
import SwiftUI
import Combine
class VideoViewModel: ObservableObject {
    @Published var moustacheOptions = ["m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10"]
    @Published var selectedMustachIndex = 0
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var videoSaveStatus = ""
    @Published var videoURL: URL? = nil
  
   
    func changeSelectedMoustachOptions(){
        if selectedMustachIndex < (moustacheOptions.count-1){
            DispatchQueue.main.async {
                self.selectedMustachIndex += 1
            }
        }
        else{
            DispatchQueue.main.async {
                self.selectedMustachIndex = 0
            }
        }
       
    }
    func getSelectedMoustachOptions()->[String]{
        var array = [String]()
       
        array.append(moustacheOptions[selectedMustachIndex])
        for i in 0...9{
            if i != selectedMustachIndex{
                array.append(moustacheOptions[i])
            }
        }
        
        return array
    }
    func selectMoustache(index:Int){
        DispatchQueue.main.async {
            self.selectedMustachIndex = index
        }
    }
    func updateVideo(video:Video){
        if video.tag! != ""{
           
            VideoRepository.shared.updateVideo(video: video) { result in
                print(result)
            }
        }
       
    }
    func getAllVideos(){
        
        isLoading = true
        var numbers = [String]()
        VideoRepository.shared.getAllVideos { result in
            if result != nil,  !result!.isEmpty {
                if result != nil, !result!.isEmpty{
                    for v in result!{
                        numbers.append(v.frontImage!)
                        
                    }
                    FileSystemServices.deleteUnwantedVideos(ids: numbers)
                }
                DispatchQueue.main.async {
                    self.videos = result!
                   
                }
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func deleteAllVideos(){
        isLoading = true
        VideoRepository.shared.deleteAllVideos { result in
            self.isLoading = false
            DispatchQueue.main.async {
                self.videos.removeAll()
            }
        }
       
    }
    func deleteVideo(video: Video,completionHandler:@escaping (_ result: Bool) -> () ){
        FileSystemServices.deleteResource(imageIndex: Int(video.frontImage!)!, videoIndex: Int(video.video!)!)
        VideoRepository.shared.deleteVideo(video: video) { result in
           
           completionHandler(result)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getAllVideos()
        }
           
        }
    }
    func saveVideo(video: Video){
        DispatchQueue.main.async {
            self.videoSaveStatus = ""
        }
        VideoRepository.shared.saveMovie(video: video) { result in
            DispatchQueue.main.async {
                self.videoSaveStatus = result
                self.videos.append(video)
            }
        }
    }
   
}

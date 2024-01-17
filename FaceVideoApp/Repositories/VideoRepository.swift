//
//  VideoRepository.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 28/06/1445 AH.
//

import Foundation
import CoreData

final class VideoRepository
{

    private init(){}
    static let shared = VideoRepository()
    
private func isVideoPresent(id: UUID, completionHandler:@escaping(_ result: Bool)-> Void){
    let fetchRequest: NSFetchRequest<VideoTable>
    fetchRequest = VideoTable.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@ ",
                                         id as UUID as CVarArg)
    let context = PersistentStorage.shared.context
    do{
        let result = try context.fetch(fetchRequest)
        if result.count >= 1{
            completionHandler(true)
        }
        else{
            completionHandler(false)
        }
       
    }
    catch{
        completionHandler(false)
    }
   
}
    
     func updateVideo(video: Video, completionHandler:@escaping(_ result: Bool)-> Void){
        let fetchRequest: NSFetchRequest<VideoTable>
        fetchRequest = VideoTable.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ ",
                                             video.id as UUID as CVarArg)
        let context = PersistentStorage.shared.context
        do{
            let result = try context.fetch(fetchRequest)
            if result.count >= 1{
                
                result[0].duration = video.duration
                result[0].tag = video.tag
                result[0].video = video.video
                result[0].frontImage = video.frontImage
                try context.save()
                completionHandler(true)
            }
            else{
                completionHandler(false)
            }
           
        }
        catch{
            completionHandler(false)
        }
       
    }
    
    func saveMovie(video: Video,completionHandler:@escaping (_ result: String) -> ()){
       
       isVideoPresent(id: video.id) { [self] result in
            if result == true{
                updateVideo(video: video) { result in
                    completionHandler("Video updated successfully ...")
                }
               
            }
            else{
                let videoCoreData = VideoTable(context: PersistentStorage.shared.context)
                videoCoreData.id = video.id
                videoCoreData.duration = video.duration
                videoCoreData.tag = video.tag
                videoCoreData.video = video.video
                videoCoreData.frontImage = video.frontImage
                
                do{
                    try PersistentStorage.shared.context.save()
                    
                    completionHandler("Successfully Saved")
                }
                catch{
                    completionHandler("Unable to save")
                }
                
            }
        }
    }
   
   
    func getAllVideos(completionHandler:@escaping (_ result: [Video]?) -> ()){
        let fetchRequest = NSFetchRequest<VideoTable>(entityName: "VideoTable")

        let result = try! PersistentStorage.shared.context.fetch(fetchRequest)
        if result.count == 0 { completionHandler(nil)}
        var videos = [Video]()
        for video in result{
            videos.append(Video(id: video.id!, duration: video.duration, tag: video.tag,video: video.video, frontImage: video.frontImage))
        }
        completionHandler(videos)
       
    }
   
    func deleteAllVideos(completionHandler:@escaping (_ result: Bool) -> ()){
        let fetchRequest = NSFetchRequest<VideoTable>(entityName: "VideoTable")
       
        let result = try! PersistentStorage.shared.context.fetch(fetchRequest)
        do{
            for watchMovie in result{
                try PersistentStorage.shared.context.delete(watchMovie)
            }
            try PersistentStorage.shared.context.save()
            completionHandler(true)
        }
        
        catch{
            completionHandler(false)
        }
      
    }
    func deleteVideo(video: Video,completionHandler:@escaping (_ result: Bool) -> ()){
        isVideoPresent(id: video.id) { [self] result in
            if result == true{
                let fetchRequest: NSFetchRequest<VideoTable>
                fetchRequest = VideoTable.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@ ",
                                                     video.id as UUID as CVarArg)
                let context = PersistentStorage.shared.context
                
                do{
                   
                    let result = try context.fetch(fetchRequest)
                    if result.count >= 1{
                        try PersistentStorage.shared.context.delete(result[0])
                       try PersistentStorage.shared.saveContext()
                        completionHandler(true)
                    }
                    else{
                        completionHandler(false)
                    }
                   
                    
                   
                }
                catch{
                    completionHandler(false)
                }
                completionHandler(false)
            }
            else{
               
                completionHandler(false)
                
            }
        }
    }
   
}


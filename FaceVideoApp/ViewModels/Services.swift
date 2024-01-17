//
//  Services.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 29/06/1445 AH.
//
import Foundation
import AVFoundation
import SwiftUI


class MediaServices{
    static func getUIImage(imageData: Data)->UIImage?{
    
        let   image =  UIImage(data: imageData)
             return image
      
    }
    static func getUIImageData(image: UIImage)->Data?{
    
        do {
         let   imageData = try image.pngData()
              return imageData
           
         } catch {
             print(error)
             return nil
         }
      
    }
    static func getVideoDuration(url:URL)->Float{
        let asset = AVAsset(url: url)

               let duration = asset.duration
               let durationTime = CMTimeGetSeconds(duration)
        return Float(durationTime)
    }
    static func getVideoData(url:URL)->Data?{
               do {
                   
                let   movieData = try Data(contentsOf: url, options: .mappedIfSafe)
                     return movieData
                  
                } catch {
                    print(error)
                    return nil
                }
       
    }
}
class FileSystemServices{
    static func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
   
    static func createImageFolderInDocumentDirectory(){
        
        do {
            try FileManager.default.createDirectory(atPath: "\(FileSystemServices.documentDirectory())/FrontImages", withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
    }
    static func createVideoFolderInDocumentDirectory(){
        do {
            try FileManager.default.createDirectory(atPath: "\(FileSystemServices.documentDirectory())/Videos", withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
    }
   
    static func removeVideoIfExist(forIndex: Int){
        let videoFolderUrl = URL(fileURLWithPath: FileSystemServices.documentDirectory() + "/Videos/\(forIndex).mp4")
        deleteItemAt(url: URL(filePath: videoFolderUrl.absoluteString))
        
    }
    static func isImageFolderExist()->Bool{
        do{
            let imageFolderUrl = URL(fileURLWithPath: FileSystemServices.documentDirectory() + "/FrontImages")
            let resourceValues = try imageFolderUrl.resourceValues(forKeys: [.isDirectoryKey])
            if let isDirectory = resourceValues.isDirectory{
                if isDirectory {
                    return true
                   } else {
                         return false
                    }
              }
            else{
                return false
            }
        }
        catch{
            return false
        }
    }
    static func isVideoFolderExist()->Bool{
        do{
            let imageFolderUrl = URL(fileURLWithPath: FileSystemServices.documentDirectory() + "/Videos")
            let resourceValues = try imageFolderUrl.resourceValues(forKeys: [.isDirectoryKey])
            if let isDirectory = resourceValues.isDirectory{
                if isDirectory {
                    return true
                   } else {
                         return false
                    }
              }
            else{
                return false
            }
        }
        catch{
            return false
        }
    }
    static func getNewFileIndexFor(url: URL)->Int{
        
        do {
            let path = url.path()
            let items = try FileManager.default.contentsOfDirectory(atPath: path)
            if items.count > 0{
                var fileIndecies: [String] = items.map{ fName in
                    let iString = fName.components(separatedBy: ".").dropLast().joined(separator: "")
                   return iString
                }
                fileIndecies.sort()
                var iNumber = 0
                for i in 0...(fileIndecies.count-1) {
                    if !fileIndecies.contains(String(i+1)){
                        iNumber = i + 1
                    }
                }
                if iNumber == 0{
                    iNumber = fileIndecies.count + 1
                }
                return iNumber
            }
            else{
                return 1
            }
           
        } catch {
            return 1
            // failed to read directory – bad permissions, perhaps?
        }
    }
    static func createURLForNewImage()->URL{
        if !FileSystemServices.isImageFolderExist(){
            FileSystemServices.createImageFolderInDocumentDirectory()
        }
        let videoPathUrl = URL(fileURLWithPath: FileSystemServices.documentDirectory() + "/FrontImages/")
        let newIndex = FileSystemServices.getNewFileIndexFor(url: videoPathUrl)
        let targetURL:URL = videoPathUrl.appendingPathComponent("\(newIndex).png")
        return targetURL
    }
    static func createURLForNewVideo()->URL{
        if !FileSystemServices.isVideoFolderExist(){
            FileSystemServices.createVideoFolderInDocumentDirectory()
        }
        let videoPathUrl = URL(fileURLWithPath: FileSystemServices.documentDirectory() + "/Videos/")
        let newIndex = FileSystemServices.getNewFileIndexFor(url: videoPathUrl)
        let targetURL:URL = videoPathUrl.appendingPathComponent("\(newIndex).mp4")
        return targetURL
    }
   
    static func deleteItemAt(url:URL){
        do {
            if FileManager.default.fileExists(atPath: url.path()){
                try FileManager.default.removeItem(at: url);
            }
           
            
        } catch let error {
            print("Unable to delete file, with error: \(error)")
        }
    }
    static func getIndexForVideo(url:URL)->String? {
        // Clear the location for the temporary file.
        let videoPath = url.absoluteString
        let fileNumber = (videoPath.components(separatedBy: "/").last!).components(separatedBy: ".").dropLast().joined(separator: "")
      
        // return the URL
        return fileNumber
    }
    static func createURLForImage(image:UIImage)->String? {
        // Clear the location for the temporary file.
        let targetURL:URL = FileSystemServices.createURLForNewImage()
        if let data = image.pngData() {
            do {
                try data.write(to: targetURL)
                let fileNumber = (targetURL.absoluteString.components(separatedBy: "/").last!).components(separatedBy: ".").dropLast().joined(separator: "")
                
                return fileNumber
            } catch {
                print("Unable to Write Image Data to Disk")
                return nil
                
            }
        }
        // return the URL
        return nil
    }
    static func getVideoURL(fromPath: String)->URL?{
        
           return URL(fileURLWithPath: FileSystemServices.documentDirectory() + "/Videos/" + "\(fromPath).mp4")
    }
    static func getImage(fromPath: String)->UIImage?{
        do {
            let imageDirectoryPath = FileSystemServices.documentDirectory() + "/FrontImages/" + "\(fromPath).png"
               let imageData = try Data(contentsOf: URL(fileURLWithPath: imageDirectoryPath))
               return UIImage(data: imageData)!
           } catch {
               print("Error loading image : \(error)")
               return nil
           }
          
    }
    static func createURLForVideo( )->URL?{
        
        let targetURL:URL = FileSystemServices.createURLForNewVideo()
     
     
        return targetURL
    }
    static func deleteResource(imageIndex:Int, videoIndex:Int){
        let videoURL = URL(fileURLWithPath: (FileSystemServices.documentDirectory() + "/Videos/\(videoIndex).mp4"))
        let imageURL = URL(fileURLWithPath:(FileSystemServices.documentDirectory() + "/FrontImages/\(imageIndex).png"))
        deleteItemAt(url: videoURL)
        deleteItemAt(url: imageURL)
        
    }
    static func deleteUnwantedVideos(ids:[String]){
        if !FileSystemServices.isVideoFolderExist(){
            return
        }
        let videoDirectoryPath = (FileSystemServices.documentDirectory() + "/Videos/")
        let imageDirectoryPath = FileSystemServices.documentDirectory() + "/FrontImages/"
        
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: videoDirectoryPath)
            let items1 = try FileManager.default.contentsOfDirectory(atPath: imageDirectoryPath)
            if items.count > 0{
                
                var fileIndecies: [String] = items.map{ fName in
                    let iString = fName.components(separatedBy: ".").dropLast().joined(separator: "")
                   return iString
                }
                fileIndecies.sort()
                for iItem in fileIndecies{
                    if !ids.contains(iItem){
                        deleteItemAt(url: URL(fileURLWithPath:  (videoDirectoryPath+"\(iItem).mp4")))
                    }
                   
                }
            }
            if items1.count > 0{
                
                var fileIndecies: [String] = items1.map{ fName in
                    let iString = fName.components(separatedBy: ".").dropLast().joined(separator: "")
                   return iString
                }
                fileIndecies.sort()
                for iItem in fileIndecies{
                    if !ids.contains(iItem){
                        deleteItemAt(url: URL(fileURLWithPath:  (imageDirectoryPath+"\(iItem).png")))
                    }
                   
                }
            }
           
        } catch {
           print(error)
            // failed to read directory – bad permissions, perhaps?
        }
    }
    static func deleteItemAt(path:String) {
        deleteItemAt(url: URL(filePath: path))
    }

}



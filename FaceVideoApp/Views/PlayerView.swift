//
//  PlayerView.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 01/07/1445 AH.
//

import SwiftUI
import AVKit
struct PlayerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
     
    @State var shouldShowVideoPlayer = true
     var videoTitle: String = "video tag"
    
    @State var animate = false
    @State var player: AVPlayer? = AVPlayer()

     @State var showFullscreen = false
    var url: URL
    // MARK: Lifecycle

    init(url: URL, videoTag: String) {
        self.url = url
          
        self.videoTitle = videoTag
       }

       // MARK: Internal

     
       var body: some View {
           VStack {
               videoView
                   .frame(height: UIScreen.main.bounds.height)
           }.fullScreenCover(isPresented: $showFullscreen) {
               videoView
           }
           .onAppear(){
               self.player = AVPlayer(url: url)
            self.player!.play()
           }
           .onDisappear(){
               if player != nil,player!.timeControlStatus == .playing{
                   player!.pause()
                   player!.replaceCurrentItem(with: nil)
                   player = nil
               }
           }
           
           .frame(height: UIScreen.main.bounds.height)
           .background(.white)

       }
        
       // MARK: Private

       @ViewBuilder
       private var videoView: some View {
           VStack{
               
               Text(videoTitle)
                   .bold()
                   .foregroundStyle(.blue)
                   .multilineTextAlignment(.center)
                   .frame(width: UIScreen.main.bounds.width-150)
               VideoPlayer(player: player) 
               /*
               {
                   if !showFullscreen {
                       ZStack {
                           if player != nil, player!.timeControlStatus != .playing{
                               Image(systemName: "play.circle")
                                   .resizable()
                                   .foregroundStyle(.white)
                                   .tint(.white)
                                   .frame(width: 50, height: 50)
                                   .hidden()
//                                   .onTapGesture {
//                                       player.play()
//                                       
//                                   }
                               
                               Spacer()
                           }
                           
                           Spacer()
                       }
                   }
               }
               */
               .onAppear(){
                   if self.player == nil{
                       self.player = AVPlayer(url: url)
                    self.player!.play()
                 
                   }
                      
               }
               .onDisappear(){
                   if player != nil,player!.timeControlStatus == .playing{
                       player!.pause()
                       player!.replaceCurrentItem(with: nil)
                       player = nil
                   }
               }
           }
       }
   }



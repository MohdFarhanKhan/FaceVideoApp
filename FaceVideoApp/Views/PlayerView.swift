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
       
    // MARK: Lifecycle

    init(url: URL, videoTag: String) {
           self.player = AVPlayer(url: url)
        self.player.play()
        self.videoTitle = videoTag
       }

       // MARK: Internal

       var player: AVPlayer

       @State var showFullscreen = false

       var body: some View {
           VStack {
               videoView
                   .frame(height: UIScreen.main.bounds.height)
           }.fullScreenCover(isPresented: $showFullscreen) {
               videoView
           }
           .onDisappear(){
               player.pause()
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
               VideoPlayer(player: player) {
                   if !showFullscreen {
                       ZStack {
                           if player.timeControlStatus != .playing{
                               Image(systemName: "play.circle")
                                   .resizable()
                                   .foregroundStyle(.white)
                                   .tint(.white)
                                   .frame(width: 50, height: 50)
                                   .hidden()
                                   .onTapGesture {
                                       player.play()
                                       
                                   }
                               
                               Spacer()
                           }
                           
                           Spacer()
                       }
                   }
               }
             
               
               .onDisappear(){
                   player.pause()
               }
           }
       }
   }



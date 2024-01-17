//
//  HomeView.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 04/07/1445 AH.
//

import SwiftUI
import CoreData
import AVKit
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
struct VideoCell:View{
    
    @ObservedObject var viewModel : VideoViewModel = VideoViewModel()
    @State var video: Video?
    @State var videoSize: CGSize = CGSize(width: 190, height: 190)
    @State var pushActive = false
    @Binding var playVideoId: UUID?
    @Binding var searchVideo: Video?
    @State var videoTag: String = ""
  
    func editTag(focused:Bool) {
        if  videoTag != "" , !focused {
            
           
                DispatchQueue.main.async {
                    let newVideo = Video(id: self.video!.id, duration: self.video!.duration, tag: videoTag, video: self.video!.video, frontImage: self.video!.frontImage)
                    self.video = newVideo
                    self.searchVideo = newVideo
                    self.viewModel.updateVideo(video: newVideo)
                   
                }
               
            
           
        }
          
       }
   
    var body: some View {
           ZStack{
            
            if let image = FileSystemServices.getImage(fromPath: video!.frontImage!){
                Image(uiImage: image)
                    .resizable()
                    .scenePadding()
                    .background(Color.green.opacity(0.4))
                    .frame(width: 190, height: 190)
                    .cornerRadius(15)
            }
          
            VStack{
                HStack(alignment: .top, spacing: 5){
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            playVideoId = video!.id
                        }
                }
                Spacer()
                VStack(alignment: .center){
                  
                    TextField("Enter tag", text: $videoTag, onEditingChanged: editTag)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.system(size: 13))
                        .bold()
                        .frame(width: 170)
                    
                       
                    Text(video!.getDuration())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .font(.system(size: 10))
                        .frame(width: 170)
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 40 , alignment: .bottom)
                
                .background(Color.pink.opacity(0.3))
                // .cornerRadius(5)
                .padding(.bottom, 5)
                
            }
        }
           
//        .onTapGesture {
//            videoTag = video!.tag!
//            UIApplication.shared.endEditing()
//                           
//                       
//        }
        .onAppear(){
            videoTag = video!.tag!
            playVideoId = nil
        }

        .frame(width:self.videoSize.width, height: self.videoSize.height)
        
        .background(Color.black.opacity(0.6))
          .cornerRadius(15)
        
    }
}

struct HomeView: View {
    
    @ObservedObject var viewModel: VideoViewModel = VideoViewModel()
    @State var isMoustacheAlert = false
    @State var columns: [GridItem] = []
    @State  var title = "Home"
    @State var isPushActive = false
    @State var isFromPlayerView = false
    @State var url: URL?
    @State  var videoTag = ""
   
    @State var isNavigationBarHidden: Bool = true
    @State var playVideoId: UUID?
    @State var searchVideo: Video?
    func changeVideo(video: Video){
        
    }
    
   
    var body: some View {
        NavigationView {
            VStack{
               
                if viewModel.isLoading{
                    ProgressView()
                }
            
                if isPushActive{

                    NavigationLink(destination: PlayerView(url: self.url!, videoTag: videoTag).navigationBarTitle("")
                        .navigationBarHidden(false),
                                   isActive: self.$isPushActive) {
                        
                         EmptyView()
                    }.hidden()
                }
                
               
               
                if  !self.viewModel.videos.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(self.viewModel.videos){video in
                                VideoCell( video: video, playVideoId: $playVideoId, searchVideo: $searchVideo)
                                    .contextMenu {
                                       
                                           Button {
                                               viewModel.deleteVideo(video: video) { status in
                                                                      }
                                           } label: {
                                               
                                               Label("Delete", systemImage: "xmark.bin.fill")
                                           }
                                    } preview: {
                                        VStack{
                                           
                                            if let image = FileSystemServices.getImage(fromPath: video.frontImage!) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFit()
                                                
                                                }
                                            Text(video.tag!)
                                                .foregroundStyle(.black)
                                                .font(.headline)
                                           
                                            Text(video.getDuration())
                                                .foregroundStyle(.white)
                                                .font(.system(size: 10))
                                           
                                        }
                                       
                                       
                                    }
                                    
                            }

                        }
                        .padding(.bottom,  215)
                    }
                   
                }
                Spacer()
               
                
                .background(Color.black.opacity(0.5))
                .cornerRadius(15)

                .onChange(of: playVideoId, { videoId1, videoId2 in
                    if videoId2 != nil{
                        for v in viewModel.videos{
                            if v.id == videoId2{
                                self.url = FileSystemServices.getVideoURL(fromPath: v.video!)
                                videoTag = v.tag!
                                isPushActive = true
                                isFromPlayerView = true
                                 break
                            }
                        }
                       }
                })
                .onChange(of: searchVideo, { video1, video2 in
                    if video2 != nil{
                        if let index = self.viewModel.videos.firstIndex(where: {$0 == video2}) {
                            print("found")
                            DispatchQueue.main.async {
                                self.viewModel.videos[index] = video2!
                            }
                        }
                        
                       }
                })
                
            }
            
            .background(.white)
            .navigationBarBackButtonHidden(self.isNavigationBarHidden)
           
            .onAppear(){
                if isFromPlayerView {
                    isFromPlayerView = false
                }
                else{
                    if self.viewModel.videos.count <= 0{
                        
                        self.columns.removeAll()
                        
                        let n = Int( UIScreen.main.bounds.width/200)
                        for _ in 1...n{
                            columns.append(GridItem(.flexible()))
                        }
                    }
                    self.viewModel.getAllVideos()
                    self.isNavigationBarHidden = false
                }

            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                
               
                Task { @MainActor in
                    try await Task.sleep(for: .seconds(0.1))
                    withAnimation {
                        _ =  UIScreen.main.bounds.height
                        let w =   UIScreen.main.bounds.width
                        
                        self.columns.removeAll()
                        print(w)
                        let n = Int( w / 200)
                        for _ in 1...n{
                            columns.append(GridItem(.flexible()))
                        }
                    }
                }
            }
            .onTapGesture(perform: {
               
                UIApplication.shared.endEditing()
            })
            .navigationTitle(title)
            .navigationBarHidden(self.isNavigationBarHidden)
            .toolbar {
               
                ToolbarItem(placement: .topBarLeading) {
                    VStack{
                        Image(viewModel.moustacheOptions[viewModel.selectedMustachIndex])
                            .resizable()
                            .frame(width: 60, height: 25, alignment: .center)
                      
                            .scaledToFit()
                            .onTapGesture {
                                viewModel.changeSelectedMoustachOptions()
                            }
                        Text("Tap to change")
                            .font(.system(size: 14))
                       
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                   
                    NavigationLink(destination: RecordView(mustachOptions: viewModel.getSelectedMoustachOptions())
                        .edgesIgnoringSafeArea([.top,.bottom])
                        ) {
                        VStack{
                            Image(systemName: "rectangle.inset.filled.badge.record")
                               // .resizable()
                               // .frame(width: 60, height: 25, alignment: .center)
                               // .scaledToFit()
                                .foregroundStyle(Color.black.opacity(0.8))
                              
                            Text("Recorder")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.black.opacity(0.8))
                              
                        }
                        }
                    
                }
            }
           
           
        }
    }
}

#Preview {
    HomeView()
}

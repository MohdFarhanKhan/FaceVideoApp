//
//  RecordView.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 29/06/1445 AH.
//

import SwiftUI

struct RecordView: UIViewControllerRepresentable {
   
    @State var mustachOptions:[String] = []
    typealias UIViewControllerType = VideoRecordViewController
    func makeUIViewController(context: Context) -> VideoRecordViewController {
        let vc = VideoRecordViewController()
        
        vc.moustachOptions = mustachOptions
       
        print(vc.moustachOptions)
        
                // Do some configurations here if needed.
                return vc
        }
        
        func updateUIViewController(_ uiViewController: VideoRecordViewController, context: Context) {
            // Updates the state of the specified view controller with new information from SwiftUI.
        }
}

#Preview {
    RecordView() as any View
}

//
//  Video.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 28/06/1445 AH.
//

import Foundation

struct Video: Codable {
    var id = UUID()
    var duration: Float
    var tag: String?
    var video: Data?
}

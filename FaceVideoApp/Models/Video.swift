//
//  Video.swift
//  FaceVideoApp
//
//  Created by Najran Emarah on 28/06/1445 AH.
//

import Foundation

struct Video: Codable, Equatable, Identifiable {
    var id = UUID()
    var duration: Float
    var tag: String?
    var video: String?
    var frontImage: String?
    init(id: UUID = UUID(), duration: Float, tag: String? = nil, video: String? = nil, frontImage: String? = nil) {
        self.id = id
        self.duration = duration
        self.tag = tag
        self.video = video
        self.frontImage = frontImage
    }
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id==rhs.id
    }
    func getDuration()->String{
        var unit = "seconds"
        var dur = duration
        if dur > 60{
            dur /= 60
            unit = "minuts"
        }
        if dur > 60{
            dur /= 60
            unit = "hours"
        }
        let roundedValue = String(format: "%.3f \(unit)", dur)
        return roundedValue
    }
}

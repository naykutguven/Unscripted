//
//  Mood.swift
//  Unscripted
//
//  Created by Aykut Güven on 15.08.26.
//

import Foundation

enum Mood: String, CaseIterable, Sendable {
    case reflective
    case content
    case pensive
    case curious
    case anxious
    case grateful
    case joyful
    case calm
    case excited
    case melancholy
    case angry
    case hopeful
    case nostalgic
    case overwhelmed
    case lonely
    case proud

    var localizedLabel: LocalizedStringResource {
        switch self {
        case .reflective:
            "Reflective"
        case .content:
            "Content"
        case .pensive:
            "Pensive"
        case .curious:
            "Curious"
        case .anxious:
            "Anxious"
        case .grateful:
            "Grateful"
        case .joyful:
            "Joyful"
        case .calm:
            "Calm"
        case .excited:
            "Excited"
        case .melancholy:
            "Melancholy"
        case .angry:
            "Angry"
        case .hopeful:
            "Hopeful"
        case .nostalgic:
            "Nostalgic"
        case .overwhelmed:
            "Overwhelmed"
        case .lonely:
            "Lonely"
        case .proud:
            "Proud"
        }
    }
}

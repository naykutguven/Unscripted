//
//  MoodPillPalette.swift
//  Unscripted
//
//  Created by Aykut Güven on 15.08.26.
//

import Foundation
import SwiftUI

struct MoodPillPalette {
    let text: Color
    let background: Color
    let border: Color

    init(mood: Mood) {
        switch mood {
        case .reflective:
            text = .reflective
            background = .reflectivePillFill
            border = .reflectivePillBorder
        case .content:
            text = .content
            background = .contentPillFill
            border = .contentPillBorder
        case .pensive:
            text = .pensive
            background = .pensivePillFill
            border = .pensivePillBorder
        case .curious:
            text = .curious
            background = .curiousPillFill
            border = .curiousPillBorder
        case .anxious:
            text = .anxious
            background = .anxiousPillFill
            border = .anxiousPillBorder
        case .grateful:
            text = .grateful
            background = .gratefulPillFill
            border = .gratefulPillBorder
        case .joyful:
            text = .joyful
            background = .joyfulPillFill
            border = .joyfulPillBorder
        case .calm:
            text = .calm
            background = .calmPillFill
            border = .calmPillBorder
        case .excited:
            text = .excited
            background = .excitedPillFill
            border = .excitedPillBorder
        case .melancholy:
            text = .melancholy
            background = .melancholyPillFill
            border = .melancholyPillBorder
        case .angry:
            text = .angry
            background = .angryPillFill
            border = .angryPillBorder
        case .hopeful:
            text = .hopeful
            background = .hopefulPillFill
            border = .hopefulPillBorder
        case .nostalgic:
            text = .nostalgic
            background = .nostalgicPillFill
            border = .nostalgicPillBorder
        case .overwhelmed:
            text = .overwhelmed
            background = .overwhelmedPillFill
            border = .overwhelmedPillBorder
        case .lonely:
            text = .lonely
            background = .lonelyPillFill
            border = .lonelyPillBorder
        case .proud:
            text = .proud
            background = .proudPillFill
            border = .proudPillBorder
        }
    }
}

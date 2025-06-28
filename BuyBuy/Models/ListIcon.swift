//
//  ListIcon.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

enum ListIcon: String, CaseIterable {
    case list = "list.bullet.circle.fill"
    case star = "star.circle.fill"
    case heart = "heart.circle.fill"
    case gift = "gift.circle.fill"
    case lock = "lock.circle.fill"
    case cart = "cart.circle.fill"
    case house = "house.circle.fill"
    case office = "building.2.crop.circle.fill"
    case paperclip = "paperclip.circle.fill"
    case medic = "cross.circle.fill"
    case animal = "pawprint.circle.fill"
    case fish = "fish.circle.fill"
    case flora = "camera.macro.circle.fill"
    case clock = "clock.circle.fill"
    case time = "hourglass.circle.fill"
    case thumbsdown = "hand.thumbsdown.circle.fill"
    case thumbsup = "hand.thumbsup.circle.fill"
    case bookmark = "bookmark.circle.fill"
    case questionmark = "questionmark.circle.fill"
    case exclamationmark = "exclamationmark.circle.fill"
    case person = "person.crop.circle.fill"
    case people = "person.2.circle.fill"
    case sport = "figure.run.circle.fill"
    case school = "graduationcap.circle.fill"
    case sun = "sun.max.circle.fill"
    case car = "car.circle.fill"
    case bicycle = "bicycle.circle.fill"
    case tool = "hammer.circle.fill"
    case book = "book.circle.fill"
    case restaurant = "fork.knife.circle.fill"
    static var `default`: ListIcon { .list }
    
    var image: Image {
        Image(systemName: rawValue)
    }
}

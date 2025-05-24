//
//  ListIcon.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

import SwiftUI

enum ListIcon: String, CaseIterable {
    case list = "list.bullet.circle.fill"
    case cart = "cart.circle.fill"
    case car = "car.circle.fill"
    case bicycle = "bicycle.circle.fill"
    case heart = "heart.circle.fill"
    case star = "star.circle.fill"
    case book = "book.circle.fill"
    case house = "house.circle.fill"
    case office = "building.2.crop.circle.fill"
    case gift = "gift.circle.fill"
    case tool = "hammer.circle.fill"
    case fuel = "fuelpump.circle.fill"
    case game = "gamecontroller.circle.fill"
    case cat = "cat.circle.fill"
    case dog = "dog.circle.fill"
    case fish = "fish.circle.fill"
    case flora = "camera.macro.circle.fill"
    case time = "hourglass.circle.fill"
    case medic = "cross.circle.fill"
    case school = "graduationcap.circle.fill"
    case sun = "sun.max.circle.fill"
    case lock = "lock.circle.fill"
    case person = "accessibility.fill"
    case people = "figure.2.circle.fill"
    case sport = "figure.run.circle.fill"
    case restaurant = "fork.knife.circle.fill"
    case paperclip = "paperclip.circle.fill"
    case clothes = "tshirt.circle.fill"
    case questionmark = "questionmark.circle.fill"
    case exclamationmark = "exclamationmark.circle.fill"

    static var `default`: ListIcon { .list }
    
    var image: Image {
        Image(systemName: rawValue)
    }
}

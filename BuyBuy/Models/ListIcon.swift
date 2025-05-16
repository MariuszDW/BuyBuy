//
//  ListIcon.swift
//  BuyBuy
//
//  Created by MDW on 16/05/2025.
//

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
    case store = "storefront.circle.fill"
    case fuel = "fuelpump.circle.fill"
    case game = "gamecontroller.circle.fill"
    case cat = "cat.circle.fill"
    case dog = "dog.circle.fill"
    case fish = "fish.circle.fill"
    case leaf = "leaf.circle.fill"
    case time = "hourglass.circle.fill"
    case medic = "cross.circle.fill"
    case questionmark = "questionmark.circle.fill"
    case sun = "sun.max.circle.fill"
    case lock = "lock.circle.fill"
    case person = "person.crop.circle.fill"
    case people = "figure.2.circle.fill"
    case run = "figure.run.circle.fill"
    case restaurant = "fork.knife.circle.fill"
    case paperclip = "paperclip.circle.fill"
    case clothes = "tshirt.circle.fill"

    static var `default`: ListIcon { .list }

//    static func from(rawValue: String) -> ListIcon {
//        return ListIcon(rawValue: rawValue) ?? .default
//    }
}

//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Mayuresh Rao on 10/23/22.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}

//
//  FeedLoader.swift
//  Feed
//
//  Created by Mayuresh Rao on 8/5/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedLoader])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}

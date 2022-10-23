//
//  FeedLoaderProtocol.swift
//  EssentialFeed
//
//  Created by Mayuresh Rao on 10/23/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}

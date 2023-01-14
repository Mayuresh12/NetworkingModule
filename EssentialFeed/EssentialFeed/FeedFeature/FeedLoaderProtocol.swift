//
//  FeedLoaderProtocol.swift
//  EssentialFeed
//
//  Created by Mayuresh Rao on 10/23/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}

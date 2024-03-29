//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Mayuresh Rao on 1/9/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public  protocol HTTPClient {
    func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void)
}

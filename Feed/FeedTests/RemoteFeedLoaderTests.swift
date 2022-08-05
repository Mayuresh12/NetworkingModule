//
//  RemoteFeedLoaderTests.swift
//  FeedTests
//
//  Created by Mayuresh Rao on 8/5/22.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let client = HTTPClient()
        let sut = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test(<#parameters#>) -> <#return type#> {
        <#function body#>
    }

}

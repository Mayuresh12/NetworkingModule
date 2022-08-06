//
//  RemoteFeedLoaderTests.swift
//  FeedTests
//
//  Created by Mayuresh Rao on 8/5/22.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "www.mayuresh.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL!)
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    func get(from url: URL!) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        //Given
        let client = HTTPClientSpy()
        
        //When
        _ = RemoteFeedLoader(client: client)
        
        //Then
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_requestDatafromURL() {
        //Given
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        //When
        sut.load()
        
        //Then
        XCTAssertNotNil(client.requestedURL)
        
    }
    
}

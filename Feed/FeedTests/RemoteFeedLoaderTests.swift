//
//  RemoteFeedLoaderTests.swift
//  FeedTests
//
//  Created by Mayuresh Rao on 8/5/22.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "www.mayuresh.com")!)
    }
}

class HTTPClient {
    static var shared =  HTTPClient()
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL!) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        //Given
        let client = HTTPClientSpy()
        
        //When
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        //Then
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_requestDatafromURL() {
        //Given
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader()
        HTTPClient.shared = client

        
        //When
        sut.load()
        
        //Then
        XCTAssertNotNil(client.requestedURL)
        
    }

}

//
//  RemoteFeedLoaderTests.swift
//  FeedTests
//
//  Created by Mayuresh Rao on 8/5/22.
//

import XCTest
@testable import Feed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        //Given
        let (_ ,client) = makeSUT()
    
        //Then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_requestDatafromURL() {
        //Given
        let url = URL(string: "www.test_requestDatafromURL.com")!
        let (sut, client) = makeSUT(url: url)
        
        //When
        sut.load()
        
        //Then
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(client.requestedURL, url)
    }
    
    //MARK: helpers
    
    private func makeSUT(url: URL = URL(string: "www.test_requestDatafromURL.com")!) -> (sut: RemoteFeedLoader,
                                                                                         client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL!) {
            requestedURL = url
        }
    }
}

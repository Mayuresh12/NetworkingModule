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
        XCTAssertTrue(client.requesetedURLs.isEmpty)
    }
    
    func test_requestsDatafromURL() {
        //Given
        let url = URL(string: "www.test_requestDatafromURL.com")!
        let (sut, client) = makeSUT(url: url)
        
        //When
        sut.load()
        
        //Then
        //XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(client.requesetedURLs, [url])
    }
    
    func test_loadTwice_requestsDatafromURL() {
        //Given
        let url = URL(string: "www.test_requestDatafromURL.com")!
        let (sut, client) = makeSUT(url: url)
        
        //When
        sut.load()
        sut.load()

        //Then
        XCTAssertFalse(client.requesetedURLs.isEmpty)
        XCTAssertEqual(client.requesetedURLs, [url, url])
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
        var requesetedURLs = [URL]()
        
        func get(from url: URL!) {
            requestedURL = url
            requesetedURLs.append(url)
        }
    }
}

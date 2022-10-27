//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Mayuresh Rao on 10/24/22.
//

import XCTest

class RemoteFeedLoader {
    
    let client : HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init() {
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_from_remoteURL() {
        let url = URL(string: "www.mayureshvrao.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    // Helpers
    
    private func makeSUT(url: URL = URL(string: "www.mayureshvrao.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?

        func get(from url: URL) {
            requestedURL = url
        }
    }
}

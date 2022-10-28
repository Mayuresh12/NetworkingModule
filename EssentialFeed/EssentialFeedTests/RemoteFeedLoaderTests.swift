//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Mayuresh Rao on 10/24/22.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    func test_init() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_from_remoteURL() {
        let url = URL(string: "www.mayureshvrao.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0)}
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    // Helpers
    
    private func makeSUT(url: URL = URL(string: "www.mayureshvrao.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(Error) -> Void]()
        
        func get(from url: URL,
                 completion: @escaping (Error) -> Void) {
            completions.append(completion)
            requestedURLs.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0){
            completions[index](error)
        }
    }
}

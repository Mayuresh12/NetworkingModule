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
        
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_from_remoteURL() {
        let url = URL(string: "www.mayureshvrao.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in }
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNonHTTPResponse200() {
        let (sut, client) = makeSUT()
        let samples: [Int] = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach {
            index, code in
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                client.complete(withStatus: code,at: index)
                
            })
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = Data(_: "invalid json".utf8)
            client.complete(withStatus: 200,data: invalidJSON )
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPsResponseWithEmptyJSONList(){
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyJSON = Data(_: "{\"items\": []}".utf8)
            client.complete(withStatus: 200, data: emptyJSON)
        })
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJsonItems() {
        let (sut, client) = makeSUT()

        let item1 = FeedItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "http://a-url.com")!)
        let item1JSON = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "http://b-url.com")!)
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJSON = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWithResult: .success([item1, item2]), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatus: 200, data: json)
        })
    }
    
    // Helpers
    
    private func makeSUT(url: URL = URL(string: "www.mayureshvrao.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithResult result: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0)}
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL,
                                 completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map{ $0.url }
        }
        
        func get(from url: URL,
                 completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatus code: Int,
                      data: Data = Data(),
                      at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}

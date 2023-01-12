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
                let json = makeItemJSON([])
                client.complete(withStatus: code, data: json,at: index)
                
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
            let emptyJSON = makeItemJSON([])
            client.complete(withStatus: 200, data: emptyJSON)
        })
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJsonItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "http://b-url.com")!)

        let items = [item1.model, item2.model]
        expect(sut, toCompleteWithResult: .success(items), when: {
            let json = makeItemJSON([item1.json, item2.json])
            client.complete(withStatus: 200, data: json)
        })
    }
    
    func test_load_doesnotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://anyurl.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load{capturedResults.append($0)}
        sut = nil
        client.complete(withStatus: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
        
    }
    
    // Helpers
    
    private func makeSUT(url: URL = URL(string: "www.mayureshvrao.com")!,
    file: StaticString = #filePath,
    line: UInt = #line) -> (sut: RemoteFeedLoader,
                            client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject,
                                     file: StaticString = #filePath,
                                     line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, " Instance should have been deallocated. Potential memory leak.",
                         file: file,
                         line: line)
        }
    }
    
    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL) -> (model: FeedItem,
                                             json: [String: Any]) {
        let item = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String : Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
        return (item, json)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
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
                      data: Data,
                      at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}

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
        sut.load{ _ in }
        
        //Then
        //XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(client.requesetedURLs, [url])
    }
    
    func test_loadTwice_requestsDatafromURL() {
        //Given
        let url = URL(string: "www.test_requestDatafromURL.com")!
        let (sut, client) = makeSUT(url: url)
        
        //When
        sut.load{ _ in }
        sut.load{ _ in }

        //Then
        XCTAssertFalse(client.requesetedURLs.isEmpty)
        XCTAssertEqual(client.requesetedURLs, [url, url])
    }
        
    func test_load_deliversErrorOnClientError(){
        let (sut, client) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        
        sut.load { capturedError.append( $0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOn200HTTPResponse(){
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach{ index, code in
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load { capturedError.append( $0) }
            
            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(capturedError, [.invalidData])
        }
    }
    
    func test_Load_deliverErrorOn200InvalidHTTPSResponse() {
        let (sut, client) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        
        sut.load { capturedError.append( $0) }
        let invalidJSON = Data.init(_: "invalidJSON".utf8)
        client.complete(withStatusCode: 200, data: invalidJSON)
        XCTAssertEqual(capturedError, [.invalidData])
    }
    
    //MARK: helpers
    
    private func makeSUT(url: URL = URL(string: "www.test_requestDatafromURL.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL,
                                 completion: (HTTPClientResult) -> Void)]()
        var requesetedURLs: [URL] {
            return messages.map{ $0.url }
        }
        
        func get(from url: URL!, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requesetedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}

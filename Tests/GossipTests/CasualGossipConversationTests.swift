import Foundation
import Combine
import XCTest

//

@testable import Gossip

///

final class CasualGossipConversationTests: XCTestCase {
    
    ///
    
    let arbitraryPacket = "see you on the dark side of the moon...".data(using: .utf8)!
    
    ///
    
    func testSending() {
        let expectHandledPacket =
            expectation(description: "packet should be handled by a send function")
        
        let packet = arbitraryPacket
        var sentPacket: Data? = nil

        let sendFunction = { (packet: Data) in
            DispatchQueue.main.async {
                sentPacket = packet
                expectHandledPacket.fulfill()
            }
        }
        
        let upstream = PassthroughSubject<Data, Never>()
        let conversation = CasualGossipConversation(from: upstream, sendingWith: sendFunction)

        conversation.send(packet)

        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertEqual(packet, sentPacket)
    }
    
    ///
    
    func testReading() {
        let expectReceivedPacket =
            expectation(description: "packet should arrive")
        
        let dontSend = { (packet: Data) in return }
        let upstream = PassthroughSubject<Data, Never>()
        let conversation = CasualGossipConversation(from: upstream, sendingWith: dontSend)

        var receivedPacket: Data? = nil
        let packets = conversation.sink { packet in
            receivedPacket = packet
            expectReceivedPacket.fulfill()
        }

        let packet = arbitraryPacket
        upstream.send(packet)

        waitForExpectations(timeout: 3) { maybeError in
            XCTAssertNil(maybeError)
            packets.cancel()
        }
        
        XCTAssertEqual(packet, receivedPacket)
    }
    
}

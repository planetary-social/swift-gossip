import Combine
import Logging
import NIO
import XCTest

@testable import Gossip

///

final class EchoExchangeTests: XCTestCase {

    /// A random port number for this test run.
    
    static let arbitraryPort = Int.random(in: 50000...55000)
    
    /// Test socket address, defaulting to localhost on an arbitrary port.
    
    static let endpoint = try! SocketAddress(ipAddress: "127.0.0.1", port: arbitraryPort)

    /// Tested connection are to operate on this NIO's event loop group.
    
    static let group: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)

    /// Shorthand to a background dispatch queue.
    
    let background = DispatchQueue.global(qos: .background)

    /// An arbitrary size of the sample packet.
    ///
    /// - Note: No bigger than 4KB.
    
    var arbitraryPacketSize: Int {
        return Int.random(in: 2...4096)
    }
    
    /// An arbitrary chunk of byte-encoded information.
    
    var arbitraryPacket: Data {
        return Data((1...arbitraryPacketSize).map { _ in
            return UInt8.random(in: 0...255)
        })
    }
    
    /// All packets together with phases in which they were handled:
    
    var transferredPackets: [Data: [Phase]] = [:]

    /// Services to clean up:
    
    var services: [Cancellable] = []

    /// The amount of packets to use in this test.
    ///
    /// From 100 to 300 (of max 4KB in size), which makes no more than 1.2MB in total.
    
    let samplePacketsCount = Int.random(in: 100...300)
    
    /// A stream of recorded packets.
    
    let samplePackets = PassthroughSubject<(Phase, Data), Never>()
    
    /// The test will terminate after this time.
    
    let maxTestTime: TimeInterval = 30
        
    /// A server to be listning on our local test endpoint.
    
    let blabber = Blabber(at: endpoint, in: group)
    
    /// A client to be connected and echoing via local test endpoint.
    
    let quidnunc = Quidnunc(asking: endpoint, in: group)
    
    /// Echo exchange phase indicator.
    ///
    /// Describes the stage at which the packet is being handled.
    
    enum Phase: CaseIterable {
        case sent, echoed, receivedBack
    }
    
    /// Enable tracing.
    
    override func setUp() {
        Blabber
        .logger.logLevel = .trace
        
        Quidnunc
        .logger.logLevel = .trace
        
        setUpBlabber()
        setUpEchoingQuidnunc()
    }
    
    /// Configure the listener.
    ///
    /// Greet each activated connection with a stream of sample packets.
    /// Wait for the packets echoed back.
    /// Record both sent and received packets for later verification.

    func setUpBlabber() {
        services.append(
            blabber
            .autoconnect()
            .receive(on: background)
            .assertNoFailure()
            .sink { [self] gossip in

                defer {
                    background.async {
                        for _ in 1...samplePacketsCount {
                            let packet = self.arbitraryPacket
                            gossip.send(packet)
                            samplePackets.send((.sent, packet))
                        }
                    }
                }

                _ = gossip
                    .receive(on: background)
                    .assertNoFailure()
                    .sink { [self] packet in samplePackets.send((.receivedBack, packet)) }
                
            }
        )
    }
    
    /// Receive all the sample packets and echo them back to the listener.
    ///
    /// Record handled packets for later verification.

    func setUpEchoingQuidnunc() {
        services.append(
            quidnunc
            .autoconnect()
            .receive(on: background)
            .assertNoFailure()
            .sink { [self] packet in
                quidnunc.send(packet)
                samplePackets.send((.echoed, packet))
            }
        )
    }
        
    /// Here we demonstrate correctness of a trivial echo echange.
    ///
    /// A `Quidnunc` connects to a `Blabber`, which starts sending a finite amount of arbitrary packets.
    /// Right after arrival of each of the packets, our `Quidnunc` sends that very same packet back to `Blabber`.
    /// The `Blabber` finally reads the echoed packet back.
    ///
    /// - Note: The test ensures that all the packets were exchanged, and none went missing.
    ///
    /// - Warning: The order in which the packets arrive is hardly relevant at this stage, therefiore not taken into account yet.
    ///
    
    func testAllSentPacketsEchoed() {

        let expectedCorrectFinish =
            expectation(description: "expected echo exchange to finish correctly")
    
        services.append(
            samplePackets
            .handleEvents(receiveCompletion: { _ in expectedCorrectFinish.fulfill() })
            .sink { [self] (phase, data) in

                if !transferredPackets.keys.contains(data) {
                    transferredPackets[data] = []
                }
                
                transferredPackets[data]?.append(phase)

            }
        )
        
        waitForExpectations(timeout: maxTestTime, handler: nil)

        XCTAssertEqual(transferredPackets.count, samplePacketsCount)
        XCTAssert(transferredPackets.values.allSatisfy { $0 == Phase.allCases })
 
    }

    /// Clean up.
    ///
    /// Clean test buffers.
    /// Cancel all the background services.
    /// Make sure to gracefully shut down NIO's event loop group.

    override func tearDownWithError() throws {
        services.forEach { $0.cancel() }
        transferredPackets = [:]
        try Self.group.syncShutdownGracefully()
    }

}

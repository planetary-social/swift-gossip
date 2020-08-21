import Foundation
import Combine
import Logging

///

public class CasualGossipConversation {
    
    /// The stream of packets received from a `Blabber`.
    
    internal let incoming: AnyPublisher<Data, Never>

    /// The stream of packets to be sent back.
    
    internal let outgoing = PassthroughSubject<Data, Never>()

    ///
    
    internal let services: [Cancellable]
    
    ///
    
    public var logger = Logger(label: "social.planetary.gossip.CasualGossipConversation")

    ///
    
    public typealias DeterministicSendFunction = (Data) -> Void
    
    ///
    
    public init<Incoming>(from incoming: Incoming,
                          sendingWith send: DeterministicSendFunction? = nil)
    where Incoming: Publisher, Incoming.Output == Output, Incoming.Failure == Never {
        self.incoming = incoming.eraseToAnyPublisher()
        self.services = [outgoing.sink { packet in send?(packet) }]
    }
    
}

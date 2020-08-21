import Foundation
import Combine

///

public class CasualGossipConversation {
    
    ///
    
    internal let incoming: AnyPublisher<Data, Never>

    ///
    
    internal let outgoing = PassthroughSubject<Data, Never>()

    ///
    
    internal let services: [Cancellable]

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

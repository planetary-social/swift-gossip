import Foundation
import Combine

///

extension CasualGossipConversation: Cancellable {

    /// Close all underlying services and complete the outgoing stream.
    
    public func cancel() {
        services.forEach { $0.cancel() }
        outgoing.send(completion: .finished)
    }
    
}

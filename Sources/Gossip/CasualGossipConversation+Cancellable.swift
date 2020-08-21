import Foundation
import Combine

///

extension CasualGossipConversation: Cancellable {

    /// Close all underlying services and complete the outgoing stream.
    
    public func cancel() {
        logger.trace("canceling exchange...")
        services.forEach { $0.cancel() }
        send(completion: .finished)
    }
    
}

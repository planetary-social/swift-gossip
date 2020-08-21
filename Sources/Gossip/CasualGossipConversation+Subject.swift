import Foundation
import Combine

///

extension CasualGossipConversation: Subject {

    ///
    
    public func send(_ value: Data) {
        logger.trace("sending a packet of \(value.count) bytes")
        outgoing.send(value)
    }
    
    ///
    
    public func send(completion: Subscribers.Completion<Never>) {
        logger.trace("gracefully finishing the convesation...")
        outgoing.send(completion: completion)
    }
    
    ///
    
    public func send(subscription: Subscription) {
        #warning("log")
        // XXX: What does this thing actually do?
        outgoing.send(subscription: subscription)
    }
    
}

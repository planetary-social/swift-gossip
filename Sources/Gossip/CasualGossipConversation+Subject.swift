import Foundation
import Combine

///

extension CasualGossipConversation: Subject {

    ///
    
    public func send(_ value: Data) {
        #warning("log")
        outgoing.send(value)
    }
    
    ///
    
    public func send(completion: Subscribers.Completion<Never>) {
        #warning("log")
        outgoing.send(completion: completion)
    }
    
    ///
    
    public func send(subscription: Subscription) {
        #warning("log")
        outgoing.send(subscription: subscription)
    }
    
}

import Foundation
import Combine

///

extension Blabber: ConnectablePublisher {
    
    ///
    
    public typealias Output = CasualGossipConversation

    ///
    
    public enum Failure: Error {
        #warning("todo")
    }
    
    ///
    
    public func receive<S>(subscriber: S)
    where S: Subscriber, Failure == S.Failure, Output == S.Input {
        #warning("todo")
    }
    
    ///
    
    public func connect() -> Cancellable {
        #warning("todo")
        return self
    }
    
}

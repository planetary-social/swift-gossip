import Foundation
import Combine

///

extension CasualGossipConversation: Publisher {
    
    ///

    public typealias Output = Data
    
    /// ...
    ///
    /// - Note: All of the connection and transmission errors are handled by the `Blabber`.
    ///
    /// - Warning: No failure doesn't mean that the transmission will always complete.
    ///   Line in real life gossip, the information may come distorted, cut half way, or sometimes not at all.
    ///   The only thing a subscriber can be sure of is the completion;
    ///   whether triggered by timeout, an explicit end of transmission, or otherwise, the subscriber will know when the connection ends.
    
    public typealias Failure = Never
    
    ///
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Failure == S.Failure, Output == S.Input {
        #warning("todo")
    }
    
}

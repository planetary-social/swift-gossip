import NIO

///

public class Blabber {

    ///
    
    public let endpoint: SocketAddress

    ///
    
    private let group: EventLoopGroup
    
    ///
    
    public init(at endpoint: SocketAddress, within group: EventLoopGroup) {
        self.endpoint = endpoint
        self.group = group
        
        #warning("todo: setup")
    }

}

import Foundation
import Combine
import Logging
import NIO

///

public extension Blabber {
    
    ///
    
    final class IncomingQuidnuncHandler: ChannelInboundHandler {
        
        ///
        
        public typealias InboundIn = ByteBuffer
        
        ///
        
        public typealias OutboundOut = ByteBuffer
        
        ///
        
        internal var incoming = PassthroughSubject<Data, Never>()
        
        ///
        internal var downstream = PassthroughSubject<CasualGossipConversation, Error>()
        
        ///
        
        public var logger = Logger(label: "social.planetary.gossip.Blabber.IncomingQuidnuncHandler")
        
        ///
        
        public func channelActive(context: ChannelHandlerContext) {
            let conversation =
                CasualGossipConversation(from: incoming, sendingWith: { [self] (packet: Data) in
                    guard context.channel.isActive else {
                        logger.error("detected an attempt of sending via inactive channel!")
                        #warning("update internal state?")
                        return
                    }
                    
                    let buffer = context.channel.allocator.buffer(bytes: packet)
    
                    _ = context.channel.writeAndFlush(wrapOutboundOut(buffer))
                        .map { logger.trace("sent a packet of \(packet.count) bytes!") }
                        .recover { error in logger.error("unable to send packet: \(error)") } // XXX!
                })
            
            downstream.send(conversation)
            logger.debug("activated a gossip conversation with \(String(describing: context.remoteAddress))")
        }
        
        ///
        
        public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            var buffer = self.unwrapInboundIn(data)

            guard let packet = buffer.readBytes(length: buffer.readableBytes) else {
                logger.warning("cannot decode the packet of allegedly \(buffer.readableBytes) bytes")
                #warning("handle this error better")
                return
            }
            
            incoming.send(Data(packet))
            
            logger.trace("received and successfully read a packet of \(packet.count) bytes")
        }

        ///
        
        public func channelInactive(context: ChannelHandlerContext) {
            logger.debug("convcersation with \(String(describing: context.remoteAddress)) have ended")
            downstream.send(completion: .finished)
            cleanup(context)
        }

        ///
        
        public func errorCaught(context: ChannelHandlerContext, error: Error) {
            logger.warning("connection problem: \(error)")
            downstream.send(completion: .failure(error))
            cleanup(context)
        }

        ///
        
        private func cleanup(_ context: ChannelHandlerContext) {
            incoming.send(completion: .finished)
            context.close(promise: nil)
        }
        
    }
    
}

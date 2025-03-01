//
//  WebSocketClient.swift
//  SwiftWebSocket
//
//  Created by Mehmet Ali Erbaş on 3/1/25.
//


import Starscream
import Foundation
import UIKit

protocol ClientDelegate {
    func client(receiveText: String, client: WebSocketClient)
    func client(receiveBinary: Data, client: WebSocketClient)
    func client(receiveError: Error?, client: WebSocketClient)
    func clientConnected(client: WebSocketClient)
    func peerClosed(client: WebSocketClient)
}

//make optional to some functions
extension ClientDelegate {
    func clientConnected(client: WebSocketClient) { }
    func client(receiveBinary: Data, client: WebSocketClient) { }
}

class WebSocketClient: WebSocketDelegate {
    //MARK: - Properties
    private var webSocket: WebSocket?
    var opened = false
    var isConnected = false
    var urlString: String = "https://echo.websocket.org/.ws" //"your can add your spesific websocket server url here."
    var delegate: ClientDelegate
    
    init(delegate: ClientDelegate) {
        self.delegate = delegate
        initializeWebSocket()
    }

    //MARK: - Functions
    private func initializeWebSocket() {
        if let url = URL(string: urlString) {
            //Session
            var request = URLRequest(url: url)
            request.timeoutInterval = 5
            
            //your headers here
            request.setValue(["wamp"].joined(separator: ","), forHTTPHeaderField: "Sec-WebSocket-Protocol")
            request.setValue("permessage-deflate", forHTTPHeaderField: "Sec-WebSocket-Extensions")
            //headers end
            
            webSocket = WebSocket(request: request)
            webSocket?.delegate = self
        } else {
            webSocket = nil
            let error: NSError = .init(domain: "web socket url is nil!", code: 1000)
            delegate.client(receiveError: error, client: self)
        }
    }
    
    func getSocket() -> WebSocket? {
        return webSocket
    }
    
    func send(model: String, completion: (() -> ())?) {
        let workItem = DispatchWorkItem {
            self.webSocket?.write(string: model, completion: completion)
        }
        DispatchQueue.global().asyncAfter(deadline: .now(), execute: workItem)
    }
    
    func connect() {
        openWebSocket()
        print("Socket Connected !!")
    }
    
    func disconnect() {
        print("Socket Disconnected !!")
        webSocket?.disconnect(closeCode: 0)
        webSocket?.forceDisconnect()
        self.webSocket = nil
        self.isConnected = false
        self.opened = false
    }
    
    private func openWebSocket() {
        webSocket?.connect()
    }
    
    private func handleEvent(_ event: Starscream.WebSocketEvent) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected. Connection headers: \(headers)")
            delegate.clientConnected(client: self)
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected. Reason: \(reason). Error code: \(code)")
            delegate.peerClosed(client: self)
        case .error(let error):
            isConnected = false
            print("websocket throwed a error: ", error?.localizedDescription ?? "nil")
            delegate.client(receiveError: error, client: self)
            
        case .peerClosed: delegate.peerClosed(client: self)
        case .text(let string): delegate.client(receiveText: string, client: self)
        case .binary(let data): delegate.client(receiveBinary: data, client: self)
        case .ping(_): break
        case .pong(_): break
        case .viabilityChanged(_): break
        case .reconnectSuggested(_): break
        case .cancelled: isConnected = false
        }
    }
}

//MARK: WebSocket Delegate
extension WebSocketClient {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        print("event received: ", event)
        handleEvent(event)
    }
}

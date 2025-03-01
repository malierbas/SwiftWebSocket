//
//  ViewController.swift
//  SwiftWebSocket
//
//  Created by Mehmet Ali Erbaş on 3/1/25.
//

import UIKit

class ViewController: UIViewController {
    //IBOutlets
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    //Variables
    var webSocketclient: WebSocketClient? = nil
    
    //Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup view
        setupView()
    }
    
    private func setupView() {
        //initialize web socket client
        webSocketclient = WebSocketClient(delegate: self)
    }

    //Actions
    @IBAction func connectButtonAction(_ sender: Any) {
        //use your needs
        webSocketclient?.connect()
    }
}

//MARK: WebSocket Delegate
extension ViewController: ClientDelegate {
    func clientConnected(client: WebSocketClient) { }
    func peerClosed(client: WebSocketClient) {}
    func client(receiveError: (any Error)?, client: WebSocketClient) {
        //you can reset the connection here
    }
    
    func client(receiveText: String, client: WebSocketClient) {
        //add decode methotds here
        print("socket broadcasting: \(receiveText)")
    }
    
    func client(receiveBinary: Data, client: WebSocketClient) {
        //add decode methotds here
        let convertedBinary: String = String(data: receiveBinary, encoding: .utf8) ?? ""
        print("socket broadcasting binary: ", convertedBinary)
    }
}

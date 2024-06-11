//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocket: WebSocketProvider
    
    weak var delegate: SignalClientDelegate?
    
    init(url: URL) {
        
        if #available(iOS 13.0, *) {
            self.webSocket = NativeWebSocket(url: url)
        } else {
            self.webSocket = StarscreamWebSocket(url: url)
        }
        if #available(iOS 13.0, *) {
            self.getAddress(url: url)
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 13.0, *)
    func getAddress(url: URL) -> Void {
        
            //var uniqueID = ""
            let options = PeerJSOption(host: "videochat-signaling-app.ue.r.appspot.com",
                                       port: 443,
                                       path: "/",
                                       key: "your_key_here",
                                       secure: true)
            
        let api = API(options: options, url: url)
        print(api.self)
        Task {
            await api.getAddress(url:url) { newUrl, error in
                if let error = error {
                                print("Error retrieving address: \(error)")
                                // Handle the error in your API (e.g., return an error response)
                            } else if let newUrl = newUrl {
                                // Use the new URL in your API logic
                                print("Received new URL from getAddress: \(newUrl)")
                                guard let url = URL(string: newUrl) else { return }
                                self.webSocket = NativeWebSocket(url: url)
                                self.connect()
                                

                            }
            }
        }
            
            //print("Unique ID OUTSIDE OF CODE IS ", uniqueID)
     
    }
    
    
    func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    func send(sdp rtcSdp: RTCSessionDescription) {
        let message = Message.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            debugPrint("sent message ", message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate) {
        let message = Message.candidate(IceCandidate(from: rtcIceCandidate))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        }
        catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}


extension SignalingClient: WebSocketProviderDelegate {
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        self.delegate?.signalClientDidDisconnect(self)
        
        // try to reconnect every two seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    

    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
        let message: Message
        do {
            message = try self.decoder.decode(Message.self, from: data)
            debugPrint("messager is ", message)
        }
        catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        }

    }
    
    func handleMessage(message: String){
        print("we are in handleMessage")
        
        // Print only the message string
        //print("Received message:", messageString)
        
        if let (messageType, payload, src) = processReceivedMessage(message: message) {
            // Use messageType, payload, and src as needed
            print("Processed message type:", messageType)
            if(messageType == "OFFER"){
                let msg = payload["sdp"] as? [String: Any]
                let sdp = msg?["sdp"]
                print("Processed sdp:", sdp as Any)
                createCandidateRTC(self.webSocket, sdp: sdp as! String)
            }

            print("Processed source:", src)
        } else {
            print("Failed to process received message")
        }
    }
    
    func createCandidateRTC(_ webSocket: WebSocketProvider, sdp: String){
        let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: 0,
                                        sdpMid: "video")
        
        print(candidate.sdp)
    }
    
    func processReceivedMessage(message: String) -> (String, [String: Any], String)? {
        // Print the received message
        print("Received message:", message)
        
        // Initialize variables to hold extracted information
        var messageType = ""
        var payload = [String: Any]()
        var src = ""
        
        // Convert the JSON string to data
        guard let jsonData = message.data(using: .utf8) else {
            print("Error converting message to data")
            return nil
        }
        
        do {
            // Deserialize the JSON data into a dictionary
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // Access the 'type', 'payload', and 'src' fields from the dictionary
                if let extractedMessageType = json["type"] as? String,
                   let extractedPayload = json["payload"] as? [String: Any],
                   let extractedSrc = json["src"] as? String {
                    // Assign extracted values to variables
                    messageType = extractedMessageType
                    payload = extractedPayload
                    src = extractedSrc
                    
                    // Print extracted information
                    print("Message type:", messageType)
                    print("Payload:", payload)
                    print("Source:", src)
                } else {
                    print("Error: Missing 'type', 'payload', or 'src' field(s) in the message")
                    return nil
                }
            } else {
                print("Error: Failed to deserialize JSON")
                return nil
            }
        } catch {
            print("Error deserializing JSON:", error)
            return nil
        }
        
        // Return the extracted information as a tuple
        return (messageType, payload, src)
    }
}

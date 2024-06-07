//
//  NativeSocketProvider.swift
//  WebRTC-Demo
//
//  Created by stasel on 15/07/2019.
//  Copyright © 2019 stasel. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class NativeWebSocket: NSObject, WebSocketProvider {
    
    var delegate: WebSocketProviderDelegate?
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    init(url: URL ) {
        //debugPrint("url is ", url)
        
        
        self.url = url
        super.init()
    }

    func connect() {
        
        
        debugPrint("WE ARE CONNECTING WITH URL", url)
        let socket = urlSession.webSocketTask(with: url)
        socket.resume()
        self.socket = socket
        self.readMessage()
    }

    func send(data: Data) {
        self.socket?.send(.data(data)) { _ in }
    }
    
    private func readMessage() {
        self.socket?.receive { [weak self] message in
            guard let self = self else { return }
            
            switch message {
            case .success(.data(let data)):
                self.delegate?.webSocket(self, didReceiveData: data)
                //debugPrint("message from server", message)
                self.readMessage()
            case .failure:
                self.disconnect()
            case .success(let message):
                        if case let .string(messageString) = message {
                            // Print only the message string
                            //print("Received message:", messageString)
                            
                            if let (messageType, payload, src) = processReceivedMessage(message: messageString) {
                                // Use messageType, payload, and src as needed
                                print("Processed message type:", messageType)
                                print("Processed payload:", payload)
                                print("Processed source:", src)
                            } else {
                                print("Failed to process received message")
                            }
                            //make a way to handle the messages
                            // Now you can parse the messageString as needed
                            // For example, you can parse it as JSON to extract the type, payload, etc.
                        } else {
                            print("Unexpected message type:", message)
                        }
                        
                        // Continue reading messages
                        self.readMessage()
            }
        }
    }
    
    private func disconnect() {
        self.socket?.cancel()
        self.socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
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



@available(iOS 13.0, *)
extension NativeWebSocket: URLSessionWebSocketDelegate, URLSessionDelegate  {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.webSocketDidConnect(self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.disconnect()
    }
}

// Define the equivalent of ServerMessageType enum
enum ServerMessageType: String {
    case answer = "ANSWER"
    case candidate = "CANDIDATE"
    // Add other message types as needed
}

// Define the ServerMessage class
class ServerMessage {
    let type: ServerMessageType
    let payload: Any // Use appropriate type for payload
    let src: String

    init(type: ServerMessageType, payload: Any, src: String) {
        self.type = type
        self.payload = payload
        self.src = src
    }
}

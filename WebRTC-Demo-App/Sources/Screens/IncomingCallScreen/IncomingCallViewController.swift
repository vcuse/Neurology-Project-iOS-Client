import CallKit
import UIKit

@available(iOS 13.0, *)
class IncomingCallViewController: UIViewController {
    let callManager = CallManager()
    
    func initiateOutgoingCall() {
        callManager.startCall(handle: "recipient")
    }
    
    func simulateIncomingCall() {
        let uuid = UUID()
        callManager.reportIncomingCall(uuid: uuid, handle: "caller")
    }
    
    func endCurrentCall() {
        // use uuid of current call
        let uuid = UUID()
        callManager.endCall(uuid: uuid)
    }
    
    
}

// set up the configuration for the call UI
import CallKit

class CallManager: NSObject, CXProviderDelegate {
    let provider: CXProvider
    let callController = CXCallController()
    
    override init() {
        let configuration = CXProviderConfiguration(localizedName: "VideoChatApp")
        configuration.supportsVideo = true
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.generic]
        
        provider = CXProvider(configuration: configuration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    func providerDidReset(_ provider: CXProvider) {
        // Handle provider reset if needed
    }
    
    func startCall(handle: String) {
        let handle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }
    
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = true) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        update.hasVideo = hasVideo
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("Error reporting incoming call: \(error)")
            } else {
                print("Incoming call successfully reported")
            }
        }
    }
    
    func endCall(uuid: UUID) {
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error ending call: \(error)")
            } else {
                print("Call ended successfully")
            }
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Handle starting the call UI
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Handle answering the call UI
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Handle ending the call UI
        action.fulfill()
    }
}

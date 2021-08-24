//
//  StateManager.swift
//  Google Drive Demo
//
//  Created by HaiboZhou on 2021/8/23.
//

import GoogleSignIn
import Foundation

class StateManager {
    // set your client id here
    let signInConfig = GIDConfiguration.init(clientID: "Client_ID")
    var googleAPIs: GoogleDriveAPI? = nil
}

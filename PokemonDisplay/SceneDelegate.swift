//
//  SceneDelegate.swift
//  PokemonDisplay
//
//  Created by lijia xu on 6/8/21.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            window
                .rootViewController = UIHostingController(
                    rootView:
                        ContentView().environmentObject(StateCenter())
                    )
            
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}


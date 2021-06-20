//
//  SceneDelegate.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/17/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    static let storyboardName = "Main"
    static let postUrlImage = "urlImage" // post url image to load
    static let productIdentifierKey = "com.ricardo.reddit.RedditList"

    // Activity type for restoring this scene (loaded from the plist).
    static let MainSceneActivityType = { () -> String in
        // Load the activity type from the Info.plist.
        let activityTypes = Bundle.main.infoDictionary?["NSUserActivityTypes"] as? [String]
        return activityTypes![0]
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity else { return }

        if configure(window: window, session: session, with: userActivity) {
            // Remember this activity for later when this app quits or suspends.
            scene.userActivity = userActivity
            // Mark this scene's session with this userActivity product identifier so you can update the UI later.
            if let urlImage = SceneDelegate.imageUrl(for: userActivity) {
                session.userInfo =
                    [SceneDelegate.productIdentifierKey: urlImage]
            }
        } else {
            print("Failed to restore scene from \(userActivity)")
        }
    }

    func configure(window: UIWindow?, session: UISceneSession, with activity: NSUserActivity) -> Bool {

        // Check the user activity type to know which part of the app to restore.
        if activity.activityType == SceneDelegate.MainSceneActivityType() {
            // The activity type is for restoring PostImageViewController.
            // Present PostImageViewController with imageUrl to load.
            let storyboard = UIStoryboard(name: SceneDelegate.storyboardName, bundle: .main)

            guard let postImageViewController =
                storyboard.instantiateViewController(withIdentifier: "PostImageController")
                    as? PostImageViewController else { return false }

            if let userInfo = activity.userInfo {
                // get imageUrl from the userInfo.
                if let imageUrl = userInfo[SceneDelegate.postUrlImage] as? String {
                    postImageViewController.imageUrl = imageUrl
                }
                // Push the postImage view controller.
                if let navigationController = window?.rootViewController as? UINavigationController {
                    navigationController.pushViewController(postImageViewController, animated: false)
                }
                return true
            }
        }
        return false
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if let userActivity = window?.windowScene?.userActivity {
            userActivity.becomeCurrent()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        DataModelManager.sharedInstance.saveDataModel()
        if let userActivity = window?.windowScene?.userActivity {
            userActivity.resignCurrent()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        DataModelManager.sharedInstance.saveDataModel()
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == SceneDelegate.MainSceneActivityType() else { return }
        if let rootViewController = window?.rootViewController as? UINavigationController {
            // Update the postImage view controller.
            if let postImageViewController = rootViewController.topViewController as? PostImageViewController {
                postImageViewController.imageUrl = SceneDelegate.imageUrl(for: userActivity)
            }
        }
    }

    // MARK: - StateRestoration
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        // Offer the user activity for this scene.
        return scene.userActivity
    }

    // Utility function to return a Product instance from the input user activity.
    class func imageUrl(for activity: NSUserActivity) -> String? {
         var imageUrl: String?
         if let userInfo = activity.userInfo {
             // Decode the user activity product identifier from the userInfo.
            if let url = userInfo[SceneDelegate.postUrlImage] as? String {
                 imageUrl = url
             }
         }
         return imageUrl
    }

}


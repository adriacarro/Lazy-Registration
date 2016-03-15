//
//  ViewController.swift
//  Lazy Registration
//
//  Created by Adrià Carro on 07/03/16.
//  Copyright © 2016 DigitalYou. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signInFacebookButton: FBSDKLoginButton!
    
    // indicators
    @IBOutlet var signInView: UIView!
    @IBOutlet var signInTitle: UILabel!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userEmail: UILabel!
    @IBOutlet var userPassword: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFacebookLogin()
        setupGoogleLogin()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "googleSignIn:", name: "GSignIn", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "signOut:", name: "SignOut", object: nil)
    }

    func setupFacebookLogin() {
        if FBSDKAccessToken.currentAccessToken() == nil {
            print("no login with facebook")
        }
        else {
            print("login with facebook")
        }
        
        signInFacebookButton.readPermissions = ["public_profile", "email"]
    }
    
    func setupGoogleLogin() {
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            print("login with google")
        }
        else {
            print("no login with Google")
        }
    }
    
    // MARK: - Google Login
    
    // Implement these methods only if the GIDSignInUIDelegate is not a subclass of
    // UIViewController.
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func googleSignIn(notification: NSNotification){
        if let info = notification.userInfo {
            if let user = info["user"] as? GIDGoogleUser {
                signInTitle.text = "Sign in with Google!"
                userName.text = user.profile.name
                userEmail.text = user.profile.email
                userPassword.text = user.authentication.idToken
                signInView.hidden = false
            }
        }
    }
    
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: FBSDKAccessToken.currentAccessToken().tokenString, version: nil, HTTPMethod: "GET")
            req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
                if error == nil {
                    self.signInTitle.text = "Sign in with Facebook!"
                    if let name = result["name"] as? String {
                        self.userName.text = name
                    }
                    if let email = result["email"] as? String {
                        self.userEmail.text = email
                    }
                    self.userPassword.text = ""
                    self.signInView.hidden = false
                } else {
                    print("error \(error)")
                }
            })
        }
        else if result.isCancelled {
            print(result.debugDescription)
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("user logged out")
    }
    
    
    
    // MARK: - Logout
    
    func signOut(notification: NSNotification){
        signInView.hidden = true
    }

}


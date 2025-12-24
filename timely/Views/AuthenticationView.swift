//
//  AuthenticationView.swift
//  Timely
//
//  Authentication flow with login and signup
//

import SwiftUI

struct AuthenticationView: View {
    @State private var isLoginMode = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @Binding var isAuthenticated: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo and title
                VStack(spacing: 16) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)

                    Text("Timely")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    Text("Track your time, boost your productivity")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 50)

                // Auth form
                VStack(spacing: 20) {
                    // Segmented control
                    Picker("Mode", selection: $isLoginMode) {
                        Text("Login").tag(true)
                        Text("Sign Up").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 40)

                    // Form fields
                    VStack(spacing: 16) {
                        if !isLoginMode {
                            TextField("Full Name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                                .frame(width: 300)
                        }

                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .frame(width: 300)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                            .frame(width: 300)
                            .textContentType(.password)
                    }
                    .padding(.top, 20)

                    // Error message
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 40)
                    }

                    // Action button
                    Button(action: handleAuthentication) {
                        Text(isLoginMode ? "Login" : "Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)

                    // Skip for now button (for testing)
                    Button("Skip for now") {
                        skipAuthentication()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 8)
                }
                .padding(40)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(radius: 20)

                Spacer()
                Spacer()
            }
        }
        .frame(minWidth: 600, minHeight: 700)
    }

    private func handleAuthentication() {
        // Validate inputs
        guard !email.isEmpty else {
            showError(message: "Please enter your email")
            return
        }

        guard !password.isEmpty else {
            showError(message: "Please enter your password")
            return
        }

        if !isLoginMode {
            guard !name.isEmpty else {
                showError(message: "Please enter your name")
                return
            }
        }

        // Simple email validation
        guard email.contains("@") && email.contains(".") else {
            showError(message: "Please enter a valid email")
            return
        }

        // For now, just create/load user (no real authentication)
        if isLoginMode {
            // Try to load existing user
            if let user = DataManager.shared.loadUser() {
                UserDefaults.standard.set(user.id, forKey: "currentUserId")
                isAuthenticated = true
            } else {
                showError(message: "No account found. Please sign up first.")
            }
        } else {
            // Create new user
            let newUser = User(name: name, email: email)
            DataManager.shared.saveUser(newUser)
            UserDefaults.standard.set(newUser.id, forKey: "currentUserId")
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            isAuthenticated = true
        }
    }

    private func skipAuthentication() {
        let defaultUser = User(name: "Guest User", email: nil)
        DataManager.shared.saveUser(defaultUser)
        UserDefaults.standard.set(defaultUser.id, forKey: "currentUserId")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isAuthenticated = true
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showError = false
        }
    }
}

// Custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}

#Preview {
    AuthenticationView(isAuthenticated: .constant(false))
}

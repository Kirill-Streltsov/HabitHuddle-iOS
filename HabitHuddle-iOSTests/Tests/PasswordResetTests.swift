//
//  PasswordResetTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import Foundation
@testable import HabitHuddle_iOS

// MARK: - ForgotPasswordViewModel

@Suite("ForgotPasswordViewModel")
struct ForgotPasswordViewModelTests {

    @Test("invalid email sets errorMessage without calling the network")
    @MainActor
    func invalidEmailShortCircuits() async {
        let mock = MockNetworkManager()
        let vm = ForgotPasswordView.ViewModel(network: mock)

        await vm.requestReset(email: "not-an-email")

        #expect(!vm.errorMessage.isEmpty)
        #expect(vm.didRequestReset == false)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("success sets didRequestReset and clears error")
    @MainActor
    func requestResetSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = ForgotPasswordView.ViewModel(network: mock)
        await vm.requestReset(email: "alice@example.com")

        #expect(vm.didRequestReset == true)
        #expect(vm.errorMessage == "")
        let log = await mock.requestLog
        #expect(log.first?.path == "auth/forgot-password")
        #expect(log.first?.method == .post)
    }

    @Test("network error sets errorMessage and leaves didRequestReset false")
    @MainActor
    func requestResetFailure() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.serverError)

        let vm = ForgotPasswordView.ViewModel(network: mock)
        await vm.requestReset(email: "alice@example.com")

        #expect(vm.didRequestReset == false)
        #expect(!vm.errorMessage.isEmpty)
    }

    @Test("trims whitespace before validating")
    @MainActor
    func trimsWhitespace() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = ForgotPasswordView.ViewModel(network: mock)
        await vm.requestReset(email: "  alice@example.com  ")

        #expect(vm.didRequestReset == true)
    }
}

// MARK: - ResetPasswordViewModel

@Suite("ResetPasswordViewModel")
struct ResetPasswordViewModelTests {

    @Test("short password sets errorMessage without calling the network")
    @MainActor
    func shortPasswordShortCircuits() async {
        let mock = MockNetworkManager()
        let vm = ResetPasswordView.ViewModel(network: mock)

        await vm.resetPassword(token: "valid-token", newPassword: "abc")

        #expect(!vm.errorMessage.isEmpty)
        #expect(vm.didResetPassword == false)
        let log = await mock.requestLog
        #expect(log.isEmpty)
    }

    @Test("success sets didResetPassword")
    @MainActor
    func resetSuccess() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.ok)

        let vm = ResetPasswordView.ViewModel(network: mock)
        await vm.resetPassword(token: "valid-token", newPassword: "newpassword123")

        #expect(vm.didResetPassword == true)
        #expect(vm.errorMessage == "")
        let log = await mock.requestLog
        #expect(log.first?.path == "auth/reset-password")
        #expect(log.first?.method == .post)
    }

    @Test(".gone status surfaces the expired message")
    @MainActor
    func expiredTokenMessage() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.gone)

        let vm = ResetPasswordView.ViewModel(network: mock)
        await vm.resetPassword(token: "expired", newPassword: "newpassword123")

        #expect(vm.didResetPassword == false)
        #expect(vm.errorMessage == String(localized: .thisResetLinkHasExpiredPleaseRequestANewOne))
    }

    @Test(".badRequest status surfaces the invalid-link message")
    @MainActor
    func invalidTokenMessage() async {
        let mock = MockNetworkManager()
        await mock.enqueue(HTTPStatus.badRequest)

        let vm = ResetPasswordView.ViewModel(network: mock)
        await vm.resetPassword(token: "junk", newPassword: "newpassword123")

        #expect(vm.didResetPassword == false)
        #expect(vm.errorMessage == String(localized: .invalidOrExpiredResetLink))
    }

    @Test("thrown network error sets errorMessage")
    @MainActor
    func networkError() async {
        let mock = MockNetworkManager()
        await mock.enqueueError(HHError.serverError)

        let vm = ResetPasswordView.ViewModel(network: mock)
        await vm.resetPassword(token: "any", newPassword: "newpassword123")

        #expect(vm.didResetPassword == false)
        #expect(!vm.errorMessage.isEmpty)
    }
}

// MARK: - DeepLinkRouter

@Suite("DeepLinkRouter")
struct DeepLinkRouterTests {

    @Test("returns token from valid reset URL")
    func validResetURL() {
        let url = URL(string: "https://habithuddle-backend.onrender.com/reset-password?token=abc123")!
        #expect(DeepLinkRouter.parseResetPasswordToken(from: url) == "abc123")
    }

    @Test("returns nil for non-reset path")
    func wrongPath() {
        let url = URL(string: "https://habithuddle-backend.onrender.com/something-else?token=abc")!
        #expect(DeepLinkRouter.parseResetPasswordToken(from: url) == nil)
    }

    @Test("returns nil when token query item is missing")
    func missingToken() {
        let url = URL(string: "https://habithuddle-backend.onrender.com/reset-password")!
        #expect(DeepLinkRouter.parseResetPasswordToken(from: url) == nil)
    }

    @Test("returns nil when token query item is empty")
    func emptyToken() {
        let url = URL(string: "https://habithuddle-backend.onrender.com/reset-password?token=")!
        #expect(DeepLinkRouter.parseResetPasswordToken(from: url) == nil)
    }

    @Test("ignores other query items")
    func extraQueryItems() {
        let url = URL(string: "https://habithuddle-backend.onrender.com/reset-password?other=foo&token=xyz&another=bar")!
        #expect(DeepLinkRouter.parseResetPasswordToken(from: url) == "xyz")
    }
}

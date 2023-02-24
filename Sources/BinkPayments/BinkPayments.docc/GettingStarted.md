# GettingStarted

Step by step guide on how to get started.

## Initialisation

The Bink Payments SDK provides the functionality to scan and/or manually add payment cards. The SDK provides a manager ``BinkPaymentsManager`` where you can configute the SDK and pass the necessary parameters to make the SDK work.

The first step would be to call the method ``BinkPaymentsManager/configure(token:refreshToken:environmentKey:configuration:email:isDebug:)`` on your app initialization:
```swift
BinkPaymentsManager.shared.configure(
environmentKey: "unique env key",
configuration: LoyaltyPlanConfiguration(testLoyaltyPlanID: "1",
                                        productionLoyaltyPlanID: "1",
                                        trustedCredentialType: .authorise),
email: "someemail@mail.com",
isDebug: true)
```

After requesting the access and refresh tokens from your API, those values need to be passed to the ``BinkPaymentsManager`` using the method ``BinkPaymentsManager/set(loyaltyIdentity:completion:)``

```swift
BinkPaymentsManager.shared.setToken(
token: "token returned from the API",
refreshToken: "rrefresh token returned from the API")
```

The initial setup is now complete and the API is ready to use.

Note: If other methods are called before the methods outlined above the SDK will assert as it will not contain the necessary parameters to continue.

## Adding payment cards

The SDK provides two ways in order to add a payment card: via a payment card scanner or manually typing the card details.
To launch the scanner you would call ``BinkPaymentsManager/launchScanner(fullScreen:)``
```swift
BinkPaymentsManager.shared.launchScanner(fullScreen: true)
```
To manually add a card you would call ``BinkPaymentsManager/launchAddPaymentCardScreen(_:)``
```swift
BinkPaymentsManager.shared.launchAddPaymentCardScreen(_ paymentCard: PaymentAccountCreateModel? = nil)
```
This methods takes an optional parameter of type ``PaymentAccountCreateModel``

## Trusted Channel

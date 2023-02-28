# GettingStarted

Step by step guide on how to get started.

## Initialisation

The Bink Payments SDK provides the functionality to scan and/or manually add payment cards as well as adding loyalty cards. The SDK provides a manager ``BinkPaymentsManager`` where you can configure the SDK and pass the necessary parameters for proper initialisation.

The first step would be to call the method ``BinkPaymentsManager/configure(environmentKey:configuration:email:isDebug:)`` on your app initialization:
```swift
BinkPaymentsManager.shared.configure(
environmentKey: "unique env key",
configuration: LoyaltyPlanConfiguration(testLoyaltyPlanID: "1",
                                        productionLoyaltyPlanID: "1",
                                        trustedCredentialType: .authorise),
email: "someemail@mail.com",
isDebug: true)
```

After requesting the access and refresh tokens from your API, those values need to be passed to the ``BinkPaymentsManager`` using the method ``BinkPaymentsManager/setToken(token:refreshToken:)``

```swift
BinkPaymentsManager.shared.setToken(
token: "token returned from the API",
refreshToken: "refresh token returned from the API")
```

_**Note: These two methods need to be called before any other method. The SDK will assert if the inialisation steps are not taken.**_

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

## Adding a Loyalty Card

A Loyalty Card can be added to the wallet by calling the ``BinkPaymentsManager/set(loyaltyId:accountId:completion:)`` method.
``` swift
BinkPaymentsManager.shared.set(loyaltyId: .email, accountId: id)
```
Loyalty identity cand eiter be email or card number and is of type ``LoyaltyIdType``. The account id is the retailer identifier which is any random string that the retailer has to reconciling a customer beyond the card number / email.

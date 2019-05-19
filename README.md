# XCallbackKit

[![Build Status](https://travis-ci.com/spookyd/XCallbackKit.svg?branch=master)](https://travis-ci.com/spookyd/XCallbackKit)

![XCallbackKit: Inter-application coomunication](https://raw.githubusercontent.com/spookyd/XCallbackKit/master/logo.png)

Provides mechanism for inter-application communications that is [x-callback-url](http://x-callback-url.com/specifications/) compliant.

## How to Use

There are two primary ways of using `XCallbackKit`, sending and handling requests.

### Sending Requests

To send a request to another application use the `send` method on an instance of `XCallbackKit` by passing in a 
`XCallbackRequestConvertable`.

```swift
do {
    try XCallbackKit().send(request)
} catch {
    // Handle error that may have occurred when trying to send the request
}
```

#### Create a request

The recommended way to create a request is by creating a `XCallbackRequest`.

```swift
var request = XCallbackRequest(targetScheme: "tapApp", action: "actionToRun")
// Example of adding custom properties
request.addParameter("param1", "value1")

// Example of adding 'x-callback-url' specific parameters
request.addXSuccessAction(scheme: "yourAppScheme", action: "successAction")
request.addXErrorAction(scheme: "yourAppScheme", action: "errorAction")
request.addXCancelAction(scheme: "yourAppScheme", action: "cancelAction")
```

> NOTE: When providing xSuccess, xError or xCancel actions there must be a registered action handler with a matching action; see [Handling Requests](#Handling Requests).

##### URL

URL conforms to the `XCallbackRequestConvertable` protocol which means a URL can be passed directly into the `send` method. Since,
`send` takes the `XCallbackRequestConvertable` protocol anything can be passed in as long as it also conforms to the protocol.

#### Declaring target application schemes

You must whitelist the URL schemes of any application your application intends to interact with by adding them to the
`LSApplicationQueriesSchemes` key within the `Info.plist`.

By editing your `Info.plist` file as source code, add the following snippet

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tapApp</string>
    <!- Additional Schemes ->
</array>
```

### Handling Requests

Handling action requests requires 4 main steps, [creating action handlers](#creating-action-handler), [registering the action handler](#registering-action-handler), 
[handling the action request](#handling-action) and [exposing your app scheme](#declaring-application-scheme).

#### Creating Action Handlers

An action handler is a  type that conforms to the `XCallbackActionHandling` protocol. This protocol has one method, handle, which passes
in the routed request and completion closure that must be executed after the action was handled.

```swift
import XCallbackKit

class CallbackResponseHandler: XCallbackActionHandling {
    func handle(_ request: XCallbackRequest, _ complete: @escaping XCallbackActionCompleteHandler) {
        // Perform an operation or show the user a screen
        // When complete call the complete block using one of the 3 response based on the context of 
        // your operation
        complete(.success(parameters: ["returnParam": "1234"]))
        complete(.error(code: 0, message: "Some meaningful error message")) // All parameters are url encoded
        complete(.cancel())
    }
}
```

When calling the complete block, `XCallbackKit` will automatically send a response to the calling application based on the response you 
provide and the callbacks they provide. However, if the calling application does not provide a callback that matches the response generated 
nothing will happen. Example, if the calling application provides both `x-success` and `x-error` callbacks but no `x-cancel` callback but 
your application produces a cancel response, nothing will occur.

#### Registering Action Handler

After you have defined your action handlers, you will need to register them with `XCallbackKit`. It is recommended to register your action 
handler(s) in the Application Delegate `application(_: didFinishLaunchingWithOptions:)` method. 

```swift
var xCallback: XCallbackKit = XCallbackKit()

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // ... Other Initialization ...
    xCallback.registerActionHandler("action1", Action1Handler())
    xCallback.registerActionHandler("action2", Action2Handler())
    return true
}
```

#### Handling Action

When `application(_ : open: options:)` is called pass the URL along to the `XCallback.handle()` method and the framework will 
route to proper handler.

```swift

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if xCallback.canHandle(url) {
        do {
            try xCallback.handle(url)
            return true
        } catch {
            return false
        }
    }
    return false
}
```

> Note: `canHandle()` is an optional way to check if the url has an action handler that can handle it.

#### Declaring Application Scheme 

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string></string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string><!- Declare scheme here ->></string>
        </array>
    </dict>
</array>
```

## Installing

### Carthage

This framework supports [Carthage](https://github.com/Carthage/Carthage)

Simply add `github "spookyd/XCallbackKit"` to your Cartfile and update the dependencies

# Twilio video iOS quickstart Picture in Picture integration guide.

This quickstart aims to help Twilio video iOS SDK users with the integration of Picture in Picture as well as 
supporting camera multitasking.

## Camera Multitasking

### Adding support for camera multitasking via the entitlement (iOS 13.5+, Twilio Video SDK 5.3.0+)

From iOS 13.5+ apps can request the `com.apple.developer.avfoundation.multitasking-camera-access` entitlement to be able to use the camera while another application is in foreground. 

The entitlement needs to be requested from Apple. This can be done [here](https://developer.apple.com/contact/request/multitasking-camera-access/)

Once you have received the entitlement it can be added to your app by following these steps:

1. Create an App.entitlements file with the following content

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.avfoundation.multitasking-camera-access</key>
	<true/>
</dict>
</plist>
```

2. Reference the entitlement file in the build setting.

<img width="700px" src="images/signing_settings.png">

3. Add the Background Mode capability for Audio, AirPlay and Picture in Picture
as well as Voice over IP

<img width="700px" src="images/capabilities.png">



### Adding support for camera multitasking via the API (iOS 16.0+, Twilio Video SDK 5.7.0+)

Starting from iOS 16.0 camera mutlitasking is supported on a small number of iPad devices via the following APIs
https://developer.apple.com/documentation/avkit/accessing_the_camera_while_multitasking_on_ipad

Starting from [Twilio Video 5.7.0](https://www.twilio.com/docs/video/changelog-twilio-video-ios-latest#570-june-14-2023) clients can use the following APIs from Twilio iOS Video SDK to enable camera multitasking.

```swift
func makeCameraSource() -> CameraSource? {
    let options = CameraSourceOptions() { builder in
        if let scene = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.windowScene {
            builder.orientationTracker = UserInterfaceTracker(scene: scene)
        }
        
        if #available(iOS 16.0, *) {
            builder.enableCameraMultitasking = self.appSettingStore.isCameraMultitaskingEnabled
        }
    }
    return CameraSource(options: options, delegate: nil)
}
```

The camera multitasking will be enabled if the device supports it. There is no official documentation on what devices support the feature (i.e. [isMultitaskingCameraAccessSupported](https://developer.apple.com/documentation/avfoundation/avcapturesession/4013227-ismultitaskingcameraaccessenable#:~:text=in%20page%20link-,var%20isMultitaskingCameraAccessSupported%3A%20Bool,-A%20Boolean%20value) is returning `true`). But here is a [link to a thread](https://developer.apple.com/forums/thread/710193?answerId=727571022#727571022) from an Apple forum where some of the supported devices (mainly newest iPads) are mentioned.

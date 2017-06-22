# NeteaseMusicPlugin
A plugin for Netease Music macOS client which forward dead music request to [UnblockNeteaseMusic](https://github.com/ITJesse/UnblockNeteaseMusic).

# What you need
1. Xcode
2. The latest version [UnblockNeteaseMusic](https://github.com/ITJesse/UnblockNeteaseMusic)
3. CocoaPods

# How to use

> Tested on 1.5.5 (566)

1. Clone the project
2. Run `pod install` in the project folder
3. Open the `NeteaseMusicPlugin.xcworkspace` with Xcode
4. Change the apiServer `http://127.0.0.1:8123` to your own UnblockNeteaseMusic address.
5. Build and run.
6. Have fun!

User in the Mainland China please comment out [this line](https://github.com/ITJesse/NeteaseMusicPlugin/blob/master/NeteaseMusicPlugin/hijack.m#L59).

# Thanks
The hijack.m is almost a copy from [Typcn](https://github.com/typcn/163music-mac-client-unlock/blob/master/hijack.m).

# Licence
GPLv3

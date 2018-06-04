## CloudTabs

Ever wonder how Safari knows what tabs you have open in Mobile Safari?

![Safari cloudtabs screenshot](safari.png)

It all happens via a key-value store in CloudKit, and there are some utilities to access that in a private framework, [SafariShared](http://developer.limneos.net/?ios=11.1.2&framework=SafariShared.framework). But why should Safari get to have all the fun?

![Chrome cloudtabs screenshot](chrome.png)

This project has a Chrome extension that replaces the New Tab screen with one that's CloudTabs aware.

### Caveats

- This will never work on anything but OSX.
- I don't think there's any way to distribute this in the Chrome Store. Due to limitations in WebAssembly/NativeClient, I had to use [native messaging](https://developer.chrome.com/extensions/nativeMessaging). This means a separate app is required in addition to the extension, which can't be packaged for the store, as far as I know.

### What's here

The extension uses Chrome's [native messaging](https://developer.chrome.com/extensions/nativeMessaging) functionality to talk to a [native host](CloudTabs). This is great because it lets us talk to the private framework we need, but less great because it's a pain in the ass to set up. There's a barebones Obj-C implementation of one of those [here](CloudTabs/SynchronousNativeHost.h).

Also of interest: [some headers and helpers](CloudTabs/SafariShared) for the relevant parts of the private framework, and [a script](make-framework-stub) to generate a stub to work around the issue of [linking against private frameworks in Xcode 8+](https://stackoverflow.com/questions/43962260/how-to-import-a-private-framework-in-xcode-8-3-without-getting-undefined-symbol).

### Installation

Hm... I ought to package this, eh?

1. Clone
2. Open and build the Xcode project.
3. In the newly-created `build` folder, you'll have the native host binary ("CloudTabs") and its manifest (the JSON file). Copy those to `/Library/Google/Chrome/NativeMessagingHosts/` (see note below).
4. In your browser, go to `about:extensions`, switch to developer mode, hit "Load Unpacked" up top, and point it at the `extension` directory in your cloned repo.
5. That's it, hopefully!

(You can also install the native host and its manifest in a per-user directory: `~/Library/Application Support/Google/Chrome/NativeMessagingHosts`. **But**, the path to the host binary in the manifest JSON must be absolute, so if you go this route, you'll need to pop it open and change the `path` value to `/Users/<your username>/Library/Application Support/Google/Chrome/NativeMessagingHosts/CloudTabs`. Or, for development, you could just point the `path` to the `build` directory in your clone.)


### Next steps

Pull requests welcome. I hate front-end stuff so, so, so much, so there's a lot that could be done there. See also the list of [TODOs](TODO.md).

# Chapter41

- メインスレットかどうかの判定スニペット

```swift
print("On main thread? " + (Thread.current.isMainThread ? "Yes" : "No"))
```

# Chapter44

![](https://i.imgur.com/1a0yopF.jpg)

![](https://i.imgur.com/U8blMqt.jpg)

# Chapter47

- `AppDelegate`でwindowが無い問題
    - `iOS13`,`Xcode11`で`SceneDelegate`が追加されてそちらに`window`が移動したため
    - [Chapter 32: Window variable is now in Scene rather than app delegate file](https://forums.raywenderlich.com/t/chapter-32-window-variable-is-now-in-scene-rather-than-app-delegate-file/92576)
- `SceneDelegate.swift`にかけばOK？




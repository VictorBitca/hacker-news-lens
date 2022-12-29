# HN Lens for Hacker News


**HN Lens** is an open source Hacker News client for iOS/macOS devices.

![App Image](images/ios_promo.png?)
![App Image](images/macos_promo.png?)
-------

The app consists of two main components, the SwiftUI part and the [**HackerNewsKit**](https://github.com/VictorBitca/HackerNewsKit) package that initially was part of the project.

**HackerNewsKit** was extracted after the line between strictly UI code and HN API wrappers and other services became clearer, it is responsible for most of the heavy lifting:
- Accessing the [public HN API](https://github.com/HackerNews/API) and the private API, basically, the functionality that's exposed through the website but not through the public API.
- Provides a search service based on [HN Algolia](https://hn.algolia.com)
- Provides a convenient way to generate site preview images for URLs and parses the comments into `NSAttributedStrings`

Building and running
-------

The HackerNewsKit dependency uses Firebase to access the public HN API, therefore the project requires a `GoogleService-Info.plist` config file in the `HN Lens` folder.
[See how to generate and download the Firebase config file for details](https://support.google.com/firebase/answer/7015592?hl=en#ios)

# Licence
HN Lens is free software available under Version 3 of the GNU General Public License. See COPYING for details.

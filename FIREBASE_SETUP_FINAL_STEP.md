# Firebase Setup - Final Step

The Firebase SDK is downloaded but needs to be linked to your app target. Follow these simple steps in Xcode:

## Link Firebase to Your App Target

1. **Open Xcode** and open the `WaffleWednesday.xcodeproj` project

2. **Select the project** in the navigator (blue icon at top)

3. **Select "WaffleWednesday" target** (under TARGETS in the middle panel)

4. **Click on "Build Phases" tab** at the top

5. **Expand "Link Binary With Libraries"** section

6. **Click the "+" button**

7. **Search and add these 3 Firebase products:**
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage

8. **Close Xcode** and **reopen it** (this refreshes the package cache)

9. **Build the project** (Cmd+B)

That's it! Firebase should now be fully integrated.

## Alternative: Faster Method

1. In Xcode, select your **WaffleWednesday** target
2. Go to **"General" tab**
3. Scroll down to **"Frameworks, Libraries, and Embedded Content"**
4. Click the **"+"** button
5. In the dialog, switch to the **"Add Other"** dropdown → **"Add Package Product"**
6. Select:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
7. Click **Add**

## If That Doesn't Work

Try removing and re-adding the package:
1. In Xcode project navigator, look for **"Package Dependencies"** section
2. Right-click **firebase-ios-sdk** → **"Remove Package"**
3. File → **Add Package Dependencies**
4. Enter: `https://github.com/firebase/firebase-ios-sdk`
5. Version: **10.0.0** (Up to Next Major)
6. Add Package
7. Select: FirebaseAuth, FirebaseFirestore, FirebaseStorage
8. Click Add Package

Your Firebase backend connection is complete once this builds successfully!

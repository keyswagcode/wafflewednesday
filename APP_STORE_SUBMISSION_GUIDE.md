# Complete App Store Submission Guide for Waffle Wednesday

## Overview

This guide will walk you through submitting Waffle Wednesday to the Apple App Store. All preparation documents have been created and are ready to use.

## Preparation Documents

You now have the following documents ready:

1. **PRIVACY_POLICY.md** - Privacy policy for your app
2. **APP_STORE_METADATA.md** - Complete App Store listing content
3. **FIREBASE_PRODUCTION_CHECKLIST.md** - Firebase configuration checklist
4. **DEMO_ACCOUNT_SETUP.md** - Instructions for creating demo account
5. **This guide** - Step-by-step submission process

## Pre-Submission Checklist

### 1. Host Your Privacy Policy

- [ ] Upload `PRIVACY_POLICY.md` to a public URL
  - **Options**:
    - GitHub Pages (free, recommended)
    - Your own website
    - Privacy policy hosting service
  - **Example**: `https://yourusername.github.io/wafflewednesday/privacy.html`
  - **Save this URL** - you'll need it for App Store Connect

### 2. Create Demo Account

- [ ] Follow instructions in `DEMO_ACCOUNT_SETUP.md`
- [ ] Create Apple ID for demo purposes
- [ ] Sign in to the app and create sample content:
  - [ ] Record 2-3 sample waffles
  - [ ] Upload profile picture
  - [ ] Create friend connection with second test account
  - [ ] Have friend send a reply (for Direct Waffles)
- [ ] Document credentials (email & password)

### 3. Configure Firebase Production Settings

- [ ] Go to [Firebase Console](https://console.firebase.google.com/project/waffle-wednesday-c9166)
- [ ] Deploy Firestore security rules (see `FIREBASE_PRODUCTION_CHECKLIST.md`)
- [ ] Deploy Storage security rules (see `FIREBASE_PRODUCTION_CHECKLIST.md`)
- [ ] Verify Sign in with Apple is properly configured
- [ ] Set up billing alerts if needed

### 4. Prepare Screenshots

You need screenshots for:
- iPhone 6.7" (Pro Max) - Required
- iPhone 6.5" - Required
- iPhone 5.5" - Optional but recommended

**To capture screenshots**:

1. Run the app on appropriate simulators or devices:
```bash
# iPhone 15 Pro Max (6.7")
xcrun simctl boot "iPhone 15 Pro Max"
open -a Simulator

# iPhone 11 Pro Max (6.5")
xcrun simctl boot "iPhone 11 Pro Max"
open -a Simulator

# iPhone 8 Plus (5.5")
xcrun simctl boot "iPhone 8 Plus"
open -a Simulator
```

2. Sign in with your demo account
3. Capture screenshots (Cmd+S in Simulator) of:
   - Friends Feed with waffles
   - Recording interface (mic button)
   - Reply recording screen
   - Direct Waffles tab
   - Profile view

4. Save screenshots in organized folders:
   ```
   Screenshots/
   ├── 6.7-inch/
   │   ├── 01-friends-feed.png
   │   ├── 02-recording.png
   │   ├── 03-reply.png
   │   ├── 04-direct.png
   │   └── 05-profile.png
   ├── 6.5-inch/
   │   └── [same screenshots]
   └── 5.5-inch/
       └── [same screenshots]
   ```

### 5. Build Archive for Submission

1. **Clean build folder**:
```bash
cd /Users/keyanchang/Desktop/WaffleWednesday
xcodebuild clean -project WaffleWednesday.xcodeproj -scheme WaffleWednesday
```

2. **Increment build number**:
   - Open `WaffleWednesday.xcodeproj` in Xcode
   - Select the project in the navigator
   - Go to "General" tab
   - Verify: Version = `1.0`, Build = `1`

3. **Create archive**:
   - In Xcode, select "Any iOS Device (arm64)" as build destination
   - Go to **Product** → **Archive**
   - Wait for archive to complete (2-5 minutes)
   - When finished, the Organizer window will open

4. **Distribute app**:
   - In Organizer, select your archive
   - Click "Distribute App"
   - Select "App Store Connect"
   - Select "Upload"
   - Choose automatic signing (recommended)
   - Click "Upload"
   - Wait for upload to complete (5-15 minutes)

## Step-by-Step Submission in App Store Connect

### Step 1: Create App Listing

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps**
3. Click the **+** button and select **New App**
4. Fill in:
   - **Platform**: iOS
   - **Name**: Waffle Wednesday
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select `Waffle-Wednesday.WaffleWednesday`
   - **SKU**: `waffle-wednesday-001` (unique identifier)
   - **User Access**: Full Access

### Step 2: Fill in App Information

Navigate to your app → **App Information**

1. **Privacy Policy URL**: [Your hosted privacy policy URL]
2. **Category**:
   - Primary: Social Networking
   - Secondary: Lifestyle
3. **Content Rights**: Check the box to confirm you have rights to all content
4. **Age Rating**: Click **Edit** → Answer questionnaire → Should result in **12+**

### Step 3: Prepare Version Information

Navigate to **App Store** tab → **Version 1.0**

#### Version Information

**Screenshot uploads**:
1. Click on **6.7" Display**
2. Drag and drop your 5 screenshots in order
3. Repeat for **6.5" Display** and **5.5" Display**

**Promotional Text** (copy from `APP_STORE_METADATA.md`):
```
Every Wednesday, share your voice. Listen to friends, reply with your stories, and build real connections. No filters, no likes - just authentic conversation.
```

**Description** (copy from `APP_STORE_METADATA.md` - the full description)

**Keywords** (copy from `APP_STORE_METADATA.md`):
```
voice,audio,social,friends,wednesday,messaging,authentic,weekly,community,connection,voice chat
```

**Support URL**: [Your support website or email support page]

**Marketing URL** (optional): [Your app website if you have one]

#### What's New in This Version

```
🎉 Welcome to Waffle Wednesday!

Start your weekly voice tradition:
• Record and share your Wednesday updates
• Listen to friends' waffles
• Reply with direct voice messages
• Discover new voices in the public feed
• Customize your profile

Every Wednesday is a chance to connect. Share your voice today!
```

### Step 4: Build Selection

1. In the **Build** section, click **Select a build before you submit your app**
2. Select the build you uploaded earlier
3. Click **Done**

**Export Compliance**:
- Select "Yes" (app uses encryption)
- Select "No" (no proprietary protocols, uses standard HTTPS only)

### Step 5: App Review Information

**Contact Information**:
- First Name: [Your first name]
- Last Name: [Your last name]
- Phone: [Your phone number]
- Email: [Your email]

**Demo Account** (copy from `DEMO_ACCOUNT_SETUP.md`):
- Username: [Demo Apple ID]
- Password: [Demo password]

**Notes** (copy from `APP_STORE_METADATA.md` - App Review Notes section):
```
Waffle Wednesday is a voice-based social app for sharing weekly audio updates.

MICROPHONE PERMISSION: Required to record voice messages (waffles)
PHOTO LIBRARY PERMISSION: Optional, only for uploading profile pictures
SIGN IN WITH APPLE: Required for authentication

To test the app:
1. Sign in with the demo account provided
2. Navigate to "Friends" tab to see friend waffles
3. Tap "Reply" on any waffle to record a response
4. Go to "Direct" tab to see received replies
5. Tap the center "Record" tab to create a new waffle
6. Visit "Profile" tab to see your account

The app is designed for weekly usage on Wednesdays, but testing can be done any day. All features are functional and ready for review.
```

**Attachment** (optional): If you want, you can attach a demo video

### Step 6: Version Release

- Select **Manually release this version**
  - This lets you control when it goes live after approval
- Or select **Automatically release this version**
  - It goes live immediately upon approval

### Step 7: App Privacy

Click **Edit** next to App Privacy

**Data Collection**:

1. **Contact Info**
   - [ ] Collect: Email Address (for authentication)
   - Used for: App Functionality
   - Linked to user: Yes
   - Used for tracking: No

2. **User Content**
   - [x] Collect: Audio Data
   - Used for: App Functionality
   - Linked to user: Yes
   - Used for tracking: No

   - [x] Collect: Photos
   - Used for: App Functionality (profile pictures)
   - Linked to user: Yes
   - Used for tracking: No

3. **Identifiers**
   - [x] Collect: User ID (Apple ID)
   - Used for: App Functionality
   - Linked to user: Yes
   - Used for tracking: No

**Data Use**:
- All data is used for app functionality only
- No data is used for advertising or third-party tracking
- No data is sold to third parties

Click **Publish**

### Step 8: Pricing and Availability

1. **Price**: Free
2. **Availability**: All countries (or select specific countries)
3. Click **Save**

### Step 9: Final Submission

1. Review all sections - ensure everything is filled in
2. Look for any red warning indicators
3. Click **Add for Review** (top right)
4. Review the summary
5. Click **Submit to App Review**

## After Submission

### Expected Timeline

- **Processing**: 1-2 hours for build to process
- **Waiting for Review**: 1-7 days (typically 24-48 hours)
- **In Review**: 1-24 hours
- **Total**: Usually 2-5 days from submission to approval

### Monitor Status

1. Check App Store Connect regularly
2. You'll receive emails about status changes:
   - "Ready for Review"
   - "In Review"
   - "Pending Developer Release" (if manual release)
   - "Ready for Sale" (approved and live)

### If Rejected

Common rejection reasons and fixes:

1. **Demo account doesn't work**
   - Verify credentials before resubmitting
   - Ensure demo account has sample content
   - Test sign-in flow yourself

2. **Missing privacy information**
   - Ensure Privacy Policy URL is accessible
   - Verify all data collection is disclosed

3. **Crashes during review**
   - Test on physical devices
   - Check Firebase logs for errors
   - Use TestFlight for pre-submission testing

4. **Permissions not explained**
   - Verify Info.plist has clear permission descriptions
   - Ensure permissions are requested at appropriate times

**To resubmit**: Fix the issue, create a new build with incremented build number, upload, and submit again.

### After Approval

1. **If manual release**: Click "Release this version" when ready
2. **Monitor**: Check Firebase usage, crash reports, user reviews
3. **Respond to reviews**: Reply to user feedback in App Store Connect
4. **Plan updates**: Address any bugs or feature requests

## Quick Reference Checklist

Complete this checklist before hitting "Submit to App Review":

- [ ] Privacy Policy hosted and URL added
- [ ] Demo account created with sample content
- [ ] Firebase production rules deployed
- [ ] Screenshots uploaded for all required sizes
- [ ] App description and metadata filled in
- [ ] Keywords added
- [ ] Support URL added
- [ ] Build selected and export compliance completed
- [ ] Demo account credentials provided
- [ ] App Review notes added
- [ ] App Privacy questionnaire completed
- [ ] Pricing set to Free
- [ ] Age rating set to 12+
- [ ] All sections show green checkmarks

## Support Resources

- **App Store Connect**: https://appstoreconnect.apple.com
- **Firebase Console**: https://console.firebase.google.com/project/waffle-wednesday-c9166
- **Apple Developer**: https://developer.apple.com/account
- **App Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **App Store Connect Help**: https://developer.apple.com/help/app-store-connect/

## Troubleshooting Common Issues

### "Invalid Binary" Error
- Ensure Bundle ID matches exactly
- Verify signing certificates are valid
- Check that all required icons are included

### "Missing Compliance" Error
- Answer export compliance questions
- Select "Yes" for encryption, "No" for proprietary

### Screenshots Not Uploading
- Verify correct dimensions for each device size
- Use PNG or JPEG format
- Max file size: 500KB per screenshot

### Build Not Appearing
- Wait 30-60 minutes after upload
- Refresh the page
- Check email for processing errors

## Tips for Success

1. **Test extensively** before submission
2. **Use TestFlight** for beta testing with real users
3. **Make demo content realistic** so reviewers see the value
4. **Respond quickly** if reviewers have questions
5. **Be patient** - reviews can take a few days
6. **Plan your launch** - build excitement before manual release

## Next Steps After This Guide

1. Choose a hosting solution for your Privacy Policy
2. Create and populate your demo account
3. Deploy Firebase production security rules
4. Take screenshots on all required device sizes
5. Create your App Store Connect listing
6. Archive and upload your build
7. Fill in all the metadata
8. Submit for review!

---

**Good luck with your submission!**

You've built a great app, and all the preparation work is done. Follow this guide step by step, and you'll have Waffle Wednesday in the App Store soon.

If you have questions during the submission process, refer back to the detailed documents:
- Privacy: `PRIVACY_POLICY.md`
- Metadata: `APP_STORE_METADATA.md`
- Firebase: `FIREBASE_PRODUCTION_CHECKLIST.md`
- Demo Account: `DEMO_ACCOUNT_SETUP.md`

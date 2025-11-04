# Demo Account Setup for App Review

## Challenge: Sign in with Apple

Waffle Wednesday uses "Sign in with Apple" as the authentication method. This presents a unique challenge for App Review because you cannot create a traditional username/password demo account.

## Solution Options

### Option 1: Use Apple's Sandbox Testing (RECOMMENDED)

Apple provides sandbox test accounts specifically for "Sign in with Apple" testing during App Review.

**Steps:**

1. **Create a Sandbox Apple ID** in App Store Connect:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Navigate to **Users and Access** → **Sandbox** → **Testers**
   - Click the **+** button to add a new tester
   - Fill in the information:
     - First Name: `Demo`
     - Last Name: `Reviewer`
     - Email: `demo.reviewer.wafflewed@icloud.com` (must be a non-existent email)
     - Password: Create a strong password (e.g., `ReviewTest2025!`)
     - Country/Region: United States
     - App Store Territory: United States
   - Click **Save**

2. **Provide credentials to App Review**:
   ```
   Demo Account Type: Sandbox Apple ID for Sign in with Apple
   Email: demo.reviewer.wafflewed@icloud.com
   Password: [The password you created]

   Instructions for reviewer:
   1. When prompted to sign in with Apple, use the sandbox account above
   2. The app will create a new user profile automatically
   3. You can then test all features: recording waffles, viewing feeds, replying to messages
   ```

3. **Pre-populate demo content** (Optional but recommended):
   - Sign in to the app using the sandbox account before submission
   - Record a few sample waffles
   - Add some friends (use your own account as a friend)
   - This ensures reviewers see actual content in the Friends feed

**Note**: Sandbox accounts only work on devices with developer mode or TestFlight builds. For App Review, you may need to use Option 2 or 3.

### Option 2: Temporary Email Method

Create a real Apple ID using a temporary or dedicated email address just for demo purposes.

**Steps:**

1. **Create a new Apple ID**:
   - Go to [appleid.apple.com](https://appleid.apple.com)
   - Click "Create Your Apple ID"
   - Use a dedicated email: `wafflewednesday.demo@[yourdomain].com`
   - Set a strong password you can share with Apple
   - Complete the verification process

2. **Set up the demo account in the app**:
   - Install the app on a physical device or simulator
   - Sign in with the Apple ID you just created
   - Set up the profile:
     - Name: "Demo User"
     - Upload a profile picture (use the waffle icon or any appropriate image)
   - Create sample content:
     - Record 2-3 sample waffles with various lengths
     - Make some public, some friends-only

3. **Create a second account for testing social features**:
   - Create another Apple ID: `wafflewednesday.friend@[yourdomain].com`
   - Sign in and add "Demo User" as a friend
   - Record a waffle from this account
   - Reply to "Demo User's" waffle so they have a Direct Waffle

4. **Provide to App Review**:
   ```
   Demo Account
   Apple ID: wafflewednesday.demo@[yourdomain].com
   Password: [Your password]

   Notes:
   - Sign in with this Apple ID when prompted by "Sign in with Apple"
   - The account has sample waffles in Friends and Public feeds
   - The account has a Direct Waffle reply in the Direct tab
   - You can record new waffles using the center Record tab

   Friend Account (optional for testing social features)
   Apple ID: wafflewednesday.friend@[yourdomain].com
   Password: [Your password]
   ```

### Option 3: Hide Apple ID Email (Recommended if maintaining privacy)

When signing in with Apple, you can use the "Hide My Email" feature. This creates a relay email that you can provide to App Review.

**Steps:**

1. Sign in to the app on your device using Sign in with Apple
2. When prompted, choose "Hide My Email"
3. Apple will generate a random email like: `abc123xyz@privaterelay.appleid.com`
4. Note this email - it's tied to your Apple ID for this app
5. You can later provide your actual Apple ID credentials to reviewers with instructions that this specific relay email is tied to the demo account

**Provide to App Review**:
```
Apple ID: [Your actual Apple ID]
Password: [Your password]

Note: When you sign in with Apple in the Waffle Wednesday app, it will show the email "abc123xyz@privaterelay.appleid.com" - this is correct and expected due to Apple's privacy features.
```

## Recommended Approach

**We recommend Option 2** (Temporary Email Method) because:
- It's the most straightforward for reviewers
- Works on all devices and builds
- You have full control over the account
- You can pre-populate it with realistic demo data
- No special sandbox setup required

## Demo Account Setup Checklist

Once you've created your demo account, ensure it has:

- [ ] Valid Apple ID that can sign in with Apple
- [ ] User profile created in Waffle Wednesday
- [ ] Profile picture uploaded (not default starter profile)
- [ ] At least 2-3 sample waffles recorded:
  - [ ] One short waffle (10-15 seconds)
  - [ ] One medium waffle (30-45 seconds)
  - [ ] One longer waffle (1-2 minutes)
- [ ] Mix of public and friends-only waffles
- [ ] At least one friend connection (create a second test account)
- [ ] At least one Direct Waffle (reply from friend account)
- [ ] Test all features work:
  - [ ] Recording new waffles
  - [ ] Playing back waffles
  - [ ] Replying to friends' waffles
  - [ ] Viewing Direct Waffles
  - [ ] Updating profile picture

## What to Include in App Review Notes

When submitting to App Store Connect, include these notes:

```
DEMO ACCOUNT INFORMATION

Authentication Method: Sign in with Apple

Demo Account Credentials:
Email/Apple ID: [your demo Apple ID]
Password: [your demo password]

HOW TO TEST:

1. Launch the app
2. Tap "Continue with Apple" on the welcome screen
3. Sign in with the demo Apple ID provided above
4. You'll be automatically logged into the demo account

FEATURES TO TEST:

Friends Feed Tab:
- View sample waffles from friends
- Tap play button to listen to audio waffles
- Tap "Reply" to record a voice reply
- Pull down to refresh

Public Feed Tab:
- Browse public waffles from the community
- Play audio recordings

Record Tab (Center):
- Tap the purple microphone button to start recording
- Tap the red stop button when finished
- Choose to share with friends or publicly
- Tap "Post Waffle" to upload

Direct Tab:
- View voice message replies sent to you
- Play audio messages
- See who sent each message

Profile Tab:
- View your waffles
- Tap camera icon to change profile picture
- Access settings

NOTES:
- Microphone permission is required for recording
- Photo library permission is optional (only for profile pictures)
- The app is designed for weekly Wednesday usage, but can be tested any day
- Sample content has been pre-populated for easier review
- All audio recordings are stored securely in Firebase Storage

If you encounter any issues during testing, please contact:
[Your contact email]
[Your phone number]
```

## After Submission

**Keep the demo account active**:
- Don't change the password during review
- Don't delete the account
- Don't remove sample content
- Keep the account accessible for 30 days post-submission

**Monitor for issues**:
- Check Firebase logs for any authentication errors
- Monitor storage usage
- Be ready to respond quickly if reviewers have questions

## Alternative: TestFlight Review

Before submitting to App Review, consider:
1. Uploading a TestFlight build
2. Inviting external beta testers
3. Getting feedback on the demo account setup
4. Ensuring reviewers can easily access all features

This helps catch any issues before official submission.

## Troubleshooting

**If reviewer can't sign in**:
- Verify the Apple ID exists and is active
- Check password hasn't been changed
- Ensure Sign in with Apple is configured correctly in Firebase
- Verify the Bundle ID matches in Apple Developer Console

**If reviewer reports missing content**:
- Sign in to the demo account before submission
- Verify sample waffles are visible
- Ensure friend connections are established
- Check that Direct Waffles appear

**If permissions are denied**:
- Ensure Info.plist has proper permission descriptions
- Verify microphone permission is requested
- Check that permissions work in TestFlight build first

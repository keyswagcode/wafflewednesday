# Firebase Console Setup - Phone Authentication

## Quick Setup Guide (5 minutes)

Follow these steps to enable phone authentication in your Firebase project:

### Step 1: Go to Firebase Console

1. Open https://console.firebase.google.com/
2. Select your project: **waffle-wednesday-c9166**

### Step 2: Enable Phone Authentication

1. In the left sidebar, click **Build** → **Authentication**
2. Click the **Sign-in method** tab at the top
3. Find **Phone** in the list of providers
4. Click on **Phone** to expand it
5. Toggle **Enable** to ON
6. Click **Save**

### Step 3: Add Test Phone Numbers (For Simulator Testing)

Since you're testing in the simulator, you need to add test phone numbers:

1. Scroll down to the section **"Phone numbers for testing"**
2. Click **Add phone number**
3. Enter:
   - **Phone number**: `+16505551234`
   - **Verification code**: `123456` (or any 6-digit code you prefer)
4. Click **Add**

You can add more test numbers if you want to test with different accounts:
```
+16505551235 → 123456
+16505551236 → 654321
+12125551234 → 111111
```

### Step 4: Set up Firestore Database (If Not Already Done)

1. In the left sidebar, click **Build** → **Firestore Database**
2. If you see "Get started", click it
3. Choose **Start in test mode** (for development)
4. Select a location (closest to your users, e.g., `us-central`)
5. Click **Enable**

### Step 5: Update Firestore Security Rules

Once Firestore is created:

1. Go to the **Rules** tab in Firestore
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can read their own profile
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Any authenticated user can read other users' profiles (for friends)
      allow read: if request.auth != null;
    }

    // Waffles collection
    match /waffles/{waffleId} {
      // Users can create their own waffles
      allow create: if request.auth != null &&
                      request.resource.data.userId == request.auth.uid;

      // Users can read waffles (to see friends' posts)
      allow read: if request.auth != null;

      // Users can only update/delete their own waffles
      allow update, delete: if request.auth != null &&
                               resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click **Publish**

### Step 6: Set up Firebase Storage (For Audio Files)

1. In the left sidebar, click **Build** → **Storage**
2. If you see "Get started", click it
3. Choose **Start in test mode** (for development)
4. Choose the same location as Firestore
5. Click **Done**

### Step 7: Update Storage Security Rules

1. Go to the **Rules** tab in Storage
2. Replace the default rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Waffles directory
    match /waffles/{userId}/{fileName} {
      // Users can upload their own waffles
      allow write: if request.auth != null && request.auth.uid == userId;

      // Any authenticated user can read waffles (to listen to friends' posts)
      allow read: if request.auth != null;
    }
  }
}
```

3. Click **Publish**

## Testing in the Simulator

Now you're ready to test!

### 1. Build and Run the App

```bash
xcodebuild -project WaffleWednesday.xcodeproj -scheme WaffleWednesday -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Or just press **Cmd+R** in Xcode

### 2. Test Phone Authentication

1. When the app launches, tap **"Continue with Phone Number"**
2. Enter a test phone number: `6505551234` or `+16505551234`
3. Tap **"Send Verification Code"**
4. Enter the verification code you configured: `123456`
5. Tap **"Verify & Sign In"**
6. You should be signed in!

### 3. Verify User Was Created

1. Go back to Firebase Console
2. Click **Authentication** → **Users**
3. You should see your test user with phone number `+16505551234`
4. Click **Firestore Database** → **users** collection
5. You should see a document with your user data

## Production Setup (When Ready for Real Devices)

When you're ready to deploy to real devices and send actual SMS:

### 1. Enable App Check (Recommended)

1. Go to **Build** → **App Check**
2. Click **Get started**
3. Register your iOS app
4. Follow the setup instructions

### 2. Enable Billing

Firebase phone authentication requires a paid plan for production use:

1. Click the gear icon → **Usage and billing**
2. Click **Details & settings**
3. Click **Modify plan**
4. Choose **Blaze (Pay as you go)**

### 3. SMS Costs

- **US & Canada**: $0.01 per SMS
- **Other countries**: $0.01 - $0.06 per SMS
- First ~10,000 SMS verifications per month are usually free with the Blaze plan

### 4. Remove Test Phone Numbers

Once you're testing on real devices, you can remove the test phone numbers or keep them for QA testing.

## Troubleshooting

### Error: "We have blocked all requests from this device"

**Solution**: Make sure you've:
1. Added your phone number as a test number in Firebase Console
2. Used the exact verification code you configured
3. Enabled Phone authentication in Firebase Console

### Error: "The SMS verification code used to create the phone auth credential is invalid"

**Solution**:
- Double-check you entered the correct verification code
- Make sure the phone number matches exactly what you configured
- Try adding the test number again in Firebase Console

### Error: "Missing or insufficient permissions"

**Solution**:
- Update your Firestore security rules (see Step 5 above)
- Make sure the rules allow authenticated users to read/write

### Phone Auth Not Working on Real Device

**Solution**:
- Make sure your Firebase project has billing enabled
- Remove test phone numbers and use real phone numbers
- Check your spam folder for SMS messages
- Verify the phone number format is correct (+1 for US)

## What's Next?

After phone auth is working:

1. **Test the full flow**: Sign up → Verify → Use the app
2. **Add friends**: Implement the contacts import feature
3. **Record a waffle**: Test the audio recording
4. **Post waffles**: Upload to Firebase Storage
5. **View friends' waffles**: Test the feed

Your authentication is now fully set up! 🎉

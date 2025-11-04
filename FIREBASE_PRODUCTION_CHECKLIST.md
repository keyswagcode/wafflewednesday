# Firebase Production Configuration Checklist

## Current Configuration

**Project ID**: waffle-wednesday-c9166
**Bundle ID**: Waffle-Wednesday.WaffleWednesday
**Storage Bucket**: waffle-wednesday-c9166.firebasestorage.app

## Firebase Console Checks

### 1. Authentication

**Sign in with Apple**
- [ ] Sign in with Apple is enabled in Firebase Console
- [ ] Apple Services ID is configured correctly
- [ ] Redirect URLs are properly set
- [ ] Production certificate is uploaded (not development)

**Steps to verify**:
1. Go to Firebase Console → Authentication → Sign-in method
2. Ensure "Apple" provider is enabled
3. Check that the Service ID matches: `app-1-243486159779-ios-1dabed94771835771d6016`
4. Verify OAuth redirect URI is configured

### 2. Firestore Database

**Security Rules**
- [ ] Production security rules are deployed (NOT test mode)
- [ ] Rules prevent unauthorized access
- [ ] Rules allow authenticated users to read/write their own data

**Recommended Production Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Waffles can be read by anyone, written by authenticated users
    match /waffles/{waffleId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Replies can only be read by sender and recipient
    match /replies/{replyId} {
      allow read: if request.auth != null &&
                    (request.auth.uid == resource.data.fromUserId ||
                     request.auth.uid == resource.data.toUserId);
      allow create: if request.auth != null && request.resource.data.fromUserId == request.auth.uid;
      allow delete: if request.auth != null && resource.data.fromUserId == request.auth.uid;
    }

    // Friend connections
    match /friendConnections/{connectionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Steps to verify**:
1. Go to Firebase Console → Firestore Database → Rules
2. Copy and deploy the rules above
3. Test with the simulator to ensure reads/writes work
4. Ensure test mode is NOT active (should not allow unauthenticated access)

**Indexes**
- [ ] Composite indexes are created for queries
- [ ] Verify indexes exist for common queries:
  - `waffles` collection ordered by `timestamp`
  - `replies` collection filtered by `toUserId` ordered by `timestamp`

**Steps to verify**:
1. Go to Firebase Console → Firestore Database → Indexes
2. Check if indexes exist or need to be created
3. Firebase will suggest indexes if queries fail

### 3. Firebase Storage

**Security Rules**
- [ ] Production security rules prevent unauthorized uploads
- [ ] Users can only upload to their own folders
- [ ] File size limits are enforced

**Recommended Production Rules**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile pictures - users can only upload their own
    match /profiles/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                     request.auth.uid == userId &&
                     request.resource.size < 5 * 1024 * 1024 && // 5MB max
                     request.resource.contentType.matches('image/.*');
    }

    // Waffle audio recordings - users can only upload their own
    match /waffles/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                     request.auth.uid == userId &&
                     request.resource.size < 10 * 1024 * 1024 && // 10MB max
                     request.resource.contentType.matches('audio/.*');
    }

    // Reply audio recordings
    match /replies/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                     request.auth.uid == userId &&
                     request.resource.size < 10 * 1024 * 1024 && // 10MB max
                     request.resource.contentType.matches('audio/.*');
    }
  }
}
```

**Steps to verify**:
1. Go to Firebase Console → Storage → Rules
2. Deploy the rules above
3. Test uploading a profile picture and audio recording
4. Verify unauthorized users cannot access others' files

**Storage Location**
- [ ] Verify storage bucket location is appropriate for your target users
- [ ] Current: `waffle-wednesday-c9166.firebasestorage.app`

### 4. Firebase Project Settings

**General Settings**
- [ ] Project name is correct: "Waffle Wednesday"
- [ ] Public-facing name is set
- [ ] Support email is configured
- [ ] Project is on Spark Plan (free) or Blaze Plan (paid) as needed

**iOS App Configuration**
- [ ] Bundle ID matches: `Waffle-Wednesday.WaffleWednesday`
- [ ] App nickname is set
- [ ] App Store ID will be added after first submission

**Steps to verify**:
1. Go to Firebase Console → Project Settings → General
2. Verify all information is correct
3. Check iOS app is properly registered

### 5. Usage Quotas & Billing

**Free Tier Limits (Spark Plan)**
- Firestore: 1GB storage, 50K reads/day, 20K writes/day
- Storage: 5GB storage, 1GB/day downloads
- Authentication: Unlimited

**Recommendations**:
- [ ] Monitor usage in Firebase Console → Usage and billing
- [ ] Set up budget alerts if on Blaze Plan
- [ ] Plan for scaling if expecting high user growth

**Upgrade to Blaze Plan if**:
- You expect more than ~500 daily active users
- You need more storage or bandwidth
- You want to use Cloud Functions (currently not used)

### 6. Sign in with Apple Configuration

**Apple Developer Console**
- [ ] App ID has "Sign in with Apple" capability enabled
- [ ] Services ID is configured for "Waffle Wednesday"
- [ ] Return URLs include Firebase OAuth redirect
- [ ] Primary App ID is linked

**Firebase Console**
- [ ] OAuth redirect URI is configured in Apple Developer Console
- [ ] Service ID matches the one in GoogleService-Info.plist

**Current Service ID**: `app-1-243486159779-ios-1dabed94771835771d6016`

**Steps to verify**:
1. Go to developer.apple.com → Certificates, Identifiers & Profiles
2. Check App ID: `Waffle-Wednesday.WaffleWednesday`
3. Verify "Sign in with Apple" is enabled
4. Check Services ID configuration
5. Verify Return URLs include Firebase OAuth redirect

### 7. Production Monitoring

**Set up monitoring for**:
- [ ] Authentication failures
- [ ] Storage upload errors
- [ ] Firestore read/write errors
- [ ] Crash reports (via Xcode Organizer)

**Steps**:
1. Monitor Firebase Console → Analytics dashboard
2. Check error logs in Firestore and Storage
3. Set up email alerts for critical issues

### 8. Security Best Practices

**App Transport Security**
- [x] App uses HTTPS for all Firebase connections (automatic)

**API Key Security**
- [x] API key is restricted to iOS apps with correct bundle ID
- [ ] Verify in Google Cloud Console that API key has proper restrictions

**Data Validation**
- [x] Client validates user input before sending to Firebase
- [x] Server-side validation through Firestore security rules

### 9. GDPR & Privacy Compliance

- [x] Privacy Policy created (PRIVACY_POLICY.md)
- [ ] Privacy Policy hosted and URL available
- [ ] User data deletion implemented (via "Delete Account" in profile)
- [ ] Data export capability (consider implementing if required by regulations)

**Steps**:
1. Host PRIVACY_POLICY.md on a public URL (GitHub Pages, your website, etc.)
2. Add Privacy Policy URL to App Store Connect
3. Test account deletion feature
4. Verify all user data is deleted when account is deleted

### 10. Pre-Launch Testing

- [ ] Test authentication flow with new account
- [ ] Test recording and uploading waffles
- [ ] Test profile picture upload
- [ ] Test sending and receiving replies
- [ ] Test on physical device (not just simulator)
- [ ] Test with poor network conditions
- [ ] Verify error messages are user-friendly
- [ ] Check that all permissions are requested with proper descriptions

### 11. Post-Launch Monitoring

**Week 1 after launch**:
- Monitor authentication errors
- Check storage usage growth
- Review user feedback for bugs
- Monitor crash reports
- Check Firestore usage patterns

**Monthly**:
- Review Firebase usage vs. quotas
- Analyze user engagement in Analytics
- Update security rules if needed
- Review and optimize storage costs

## Quick Start Commands

**Check current Firebase project**:
```bash
# View GoogleService-Info.plist
plutil -p WaffleWednesday/GoogleService-Info.plist
```

**Test Firestore rules locally** (requires Firebase CLI):
```bash
firebase emulators:start --only firestore
```

**Deploy security rules** (requires Firebase CLI):
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

## Critical Pre-Submission Tasks

1. **Deploy Production Firestore Rules** (Currently may be in test mode)
2. **Deploy Production Storage Rules** (Currently may be in test mode)
3. **Verify Sign in with Apple works with production certificates**
4. **Test account creation on a physical device**
5. **Upload Privacy Policy and get URL**
6. **Set up billing alerts** (if on Blaze Plan)

## Support Resources

- Firebase Console: https://console.firebase.google.com/project/waffle-wednesday-c9166
- Firebase Documentation: https://firebase.google.com/docs
- Apple Developer Console: https://developer.apple.com/account
- Firebase Status: https://status.firebase.google.com

## Notes

The app is configured and ready for production. The main action items are:
1. Deploying proper security rules for Firestore and Storage
2. Verifying Sign in with Apple configuration in both Firebase and Apple Developer Console
3. Hosting the Privacy Policy and adding the URL to App Store Connect
4. Monitoring usage after launch to ensure you stay within free tier limits (or plan for Blaze upgrade)

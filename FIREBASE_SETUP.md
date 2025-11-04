# Firebase Backend Setup Guide

## Overview
Your app is already configured to save waffles to Firebase! This guide shows you what to configure in the Firebase Console.

## How Waffles Are Saved (Already Implemented)

### 1. Week-Based System
- Each waffle is tagged with a `wednesdayDate` field (e.g., "2025-10-29")
- All waffles from Sunday-Saturday map to the same Wednesday date
- This creates weekly "waffle cycles" that reset each Wednesday

### 2. Storage Structure
```
Firebase Storage:
├── waffles/
│   └── {userId}/
│       └── {timestamp}.m4a    (actual audio files)
└── replies/
    └── {userId}/
        └── {timestamp}.m4a    (reply audio files)

Firestore Database:
├── users/                     (user profiles)
│   └── {userId}
│       ├── id: string
│       ├── name: string
│       ├── phoneNumber: string?
│       ├── appleId: string?
│       ├── friendIds: [string]
│       └── createdAt: timestamp
│
├── waffles/                   (weekly waffles)
│   └── {waffleId}
│       ├── id: string
│       ├── userId: string
│       ├── userName: string
│       ├── audioURL: string   (link to storage file)
│       ├── duration: number
│       ├── timestamp: timestamp
│       └── wednesdayDate: string  (e.g., "2025-10-29")
│
└── replies/                   (replies to waffles)
    └── {replyId}
        ├── id: string
        ├── fromUserId: string
        ├── fromUserName: string
        ├── toUserId: string
        ├── audioURL: string
        └── timestamp: timestamp
```

## Required Firebase Console Setup

### Step 1: Deploy Firestore Security Rules

1. Open Firebase Console: https://console.firebase.google.com
2. Select your project
3. Go to **Firestore Database** → **Rules** tab
4. Copy the contents of `firestore.rules` (in your project folder)
5. Paste into the rules editor
6. Click **Publish**

**What these rules do:**
- Users can only create waffles with their own userId
- Everyone can read waffles (for public feed)
- Users can only update/delete their own waffles
- Replies are private between sender and recipient

### Step 2: Deploy Storage Security Rules

1. In Firebase Console, go to **Storage** → **Rules** tab
2. Copy the contents of `storage.rules` (in your project folder)
3. Paste into the rules editor
4. Click **Publish**

**What these rules do:**
- Users can only upload audio to their own folder
- Audio files limited to 50MB
- Only audio MIME types allowed
- All authenticated users can read audio files

### Step 3: Create Firestore Indexes

**Option A: Automatic (Recommended)**
1. Just run your app and try to fetch waffles
2. Check the app logs for index creation URLs
3. Click the URL to auto-create the index
4. Wait 2-5 minutes for indexes to build

**Option B: Manual**
Go to **Firestore Database** → **Indexes** tab and create these composite indexes:

1. **Friends Feed Index**
   - Collection: `waffles`
   - Fields:
     - `wednesdayDate` (Ascending)
     - `userId` (Ascending)
     - `timestamp` (Descending)

2. **Public Feed Index**
   - Collection: `waffles`
   - Fields:
     - `wednesdayDate` (Ascending)
     - `timestamp` (Descending)

3. **Posted Check Index**
   - Collection: `waffles`
   - Fields:
     - `userId` (Ascending)
     - `wednesdayDate` (Ascending)

### Step 4: Configure Phone Authentication

1. Go to **Authentication** → **Sign-in method** tab
2. Enable **Phone** provider
3. Add your app to the authorized domains if needed

### Step 5: Configure Apple Sign In (if using)

1. Go to **Authentication** → **Sign-in method** tab
2. Enable **Apple** provider
3. Follow the setup instructions for your Apple Developer account

## Testing The System

### Test 1: Upload a Waffle
1. Login to your app
2. Record and upload a waffle
3. Check Firebase Console → **Firestore Database** → `waffles` collection
4. You should see a new document with all fields including `wednesdayDate`

### Test 2: Check Storage
1. Go to Firebase Console → **Storage**
2. Navigate to `waffles/{your-user-id}/`
3. You should see your uploaded `.m4a` file

### Test 3: Fetch Waffles
1. Navigate to the Public Feed in your app
2. Pull to refresh
3. Your waffle should appear
4. If you see an index error, follow the link to create the index

## How The Weekly System Works

```
Example: Today is Monday, October 27, 2025

getCurrentWednesdayDateString() returns: "2025-10-29"

All waffles uploaded from:
- Sunday, Oct 26
- Monday, Oct 27
- Tuesday, Oct 28
- Wednesday, Oct 29    ← The "anchor" date
- Thursday, Oct 30
- Friday, Oct 31
- Saturday, Nov 1

Will all have wednesdayDate = "2025-10-29"

Next Wednesday (Nov 5), the date changes to "2025-11-05"
```

This means:
- Waffles are grouped by week
- Users can only post one waffle per week
- Queries filter by `wednesdayDate` to show current week's waffles
- Old waffles from previous weeks are preserved but not shown in feeds

## Common Issues

### Issue: "Missing index" error
**Solution:** Click the link in the error message or create indexes manually (Step 3)

### Issue: "Permission denied" error
**Solution:** Verify security rules are deployed correctly (Step 1 & 2)

### Issue: Can't upload audio
**Solution:**
- Check Storage rules are deployed
- Verify audio file is under 50MB
- Check internet connection

### Issue: Can't see other users' waffles
**Solution:**
- Verify Firestore indexes are built
- Check that waffles have matching `wednesdayDate`
- Verify security rules allow read access

## Monitoring

To monitor your backend:
1. **Firestore Usage**: Console → Firestore Database → Usage tab
2. **Storage Usage**: Console → Storage → Usage tab
3. **Auth Users**: Console → Authentication → Users tab

## Cost Considerations

Firebase Free Tier includes:
- **Firestore:** 50K reads, 20K writes, 20K deletes per day
- **Storage:** 5GB storage, 1GB/day downloads
- **Authentication:** Unlimited

For a small user base (< 1000 users), you should stay within free tier limits.

## Need Help?

Check the Firebase documentation:
- Firestore: https://firebase.google.com/docs/firestore
- Storage: https://firebase.google.com/docs/storage
- Auth: https://firebase.google.com/docs/auth

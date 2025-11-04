# GitHub Pages Setup - Privacy Policy Hosting

I've created a beautiful HTML privacy policy for you at `docs/index.html`. Now let's get it hosted on GitHub Pages for free!

## Option 1: GitHub Pages (Recommended - Takes 5 minutes)

### Step 1: Create GitHub Repository

1. Go to [github.com](https://github.com) and sign in (or create an account)
2. Click the **+** icon in the top right → **New repository**
3. Fill in:
   - **Repository name**: `wafflewednesday` (or `waffle-wednesday-privacy`)
   - **Description**: "Privacy policy for Waffle Wednesday app"
   - **Public** (must be public for free GitHub Pages)
   - **Do NOT** check "Initialize with README"
4. Click **Create repository**

### Step 2: Push Your Code to GitHub

Copy and paste these commands in your terminal (one at a time):

```bash
cd /Users/keyanchang/Desktop/WaffleWednesday

# Add GitHub as remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/wafflewednesday.git

# Add all files
git add .

# Commit
git commit -m "Initial commit with privacy policy"

# Push to GitHub
git push -u origin main
```

**Note:** If you get an error about "main" branch, try:
```bash
git branch -M main
git push -u origin main
```

**If prompted for credentials:**
- You may need to use a Personal Access Token instead of your password
- Go to GitHub → Settings → Developer settings → Personal access tokens → Generate new token
- Use the token as your password when pushing

### Step 3: Enable GitHub Pages

1. Go to your GitHub repository page
2. Click **Settings** (top right)
3. Scroll down and click **Pages** (left sidebar)
4. Under "Source":
   - Select branch: **main**
   - Select folder: **/docs**
5. Click **Save**

### Step 4: Get Your Privacy Policy URL

After 1-2 minutes, your page will be live at:

```
https://YOUR_USERNAME.github.io/wafflewednesday/
```

**Example**: If your username is `keyanc`, it would be:
```
https://keyanc.github.io/wafflewednesday/
```

This is the URL you'll add to App Store Connect!

### Step 5: Verify It Works

1. Wait 2-3 minutes after enabling GitHub Pages
2. Visit your URL in a browser
3. You should see your beautifully formatted privacy policy!

### Step 6: Add to App Store Connect

When filling out your App Store listing:
- **Privacy Policy URL**: `https://YOUR_USERNAME.github.io/wafflewednesday/`

---

## Option 2: Quick Alternative - Netlify Drop (No coding required)

If you don't want to use GitHub:

1. Go to [app.netlify.com/drop](https://app.netlify.com/drop)
2. Drag and drop the **entire `docs` folder** onto the page
3. Wait 30 seconds
4. You'll get a URL like: `https://random-name-12345.netlify.app`
5. Use this URL for your App Store privacy policy

**Pros**: Super fast, no Git knowledge needed
**Cons**: Random URL (you can customize it with a free account)

---

## Option 3: Use a Privacy Policy Hosting Service

### Free Options:
- **GitHub Pages** (above) - Recommended
- **Netlify** (above) - Very easy
- **Firebase Hosting** (since you're already using Firebase)
- **Vercel** - Similar to Netlify

---

## What I've Created for You

**File**: `docs/index.html`
- Beautiful, professional design
- Purple gradient theme matching your app
- Mobile-responsive
- All your privacy policy content formatted nicely
- Ready to deploy!

**Preview**: You can open `docs/index.html` in your browser right now to see how it looks!

---

## Need Help?

### If you don't have a GitHub account:
1. Go to [github.com/join](https://github.com/join)
2. Sign up (it's free)
3. Come back and follow Step 1 above

### If git commands fail:
Make sure you've replaced `YOUR_USERNAME` with your actual GitHub username in the commands!

### If you get authentication errors:
You may need to set up a Personal Access Token:
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token → Select "repo" scope → Generate
3. Copy the token and use it as your password when pushing

---

## Quick Start (Copy-Paste Ready)

Once you've created your GitHub repo, just replace `YOUR_USERNAME` and run:

```bash
cd /Users/keyanchang/Desktop/WaffleWednesday
git remote add origin https://github.com/YOUR_USERNAME/wafflewednesday.git
git add .
git commit -m "Add privacy policy for App Store"
git push -u origin main
```

Then enable GitHub Pages in your repo settings → Pages → main branch → /docs folder.

Your privacy policy will be live at:
**https://YOUR_USERNAME.github.io/wafflewednesday/**

---

## Visual Preview

Before deploying, you can preview your privacy policy:

```bash
open docs/index.html
```

This will open it in your browser so you can see how beautiful it looks!

---

## After Hosting

Once your privacy policy is live:
1. ✅ Copy the URL
2. ✅ Add it to `APP_STORE_METADATA.md` (replace `[Privacy Policy URL]`)
3. ✅ Add it to App Store Connect when you submit
4. ✅ Check it off your submission checklist!

You're one step closer to launching on the App Store!

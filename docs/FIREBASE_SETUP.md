# Connecting Firebase (Google login + database)

You only need to do the clicks in **Part 1** and send me **5 values**. I handle
all the code. Until then the app runs fine on sample data.

> Why you have to do this part: creating the project needs *your* Google login.
> I can't (and shouldn't) sign into your Google account. Everything after the
> 5 values is done for you.

---

## Part 1 — what you do (about 5 minutes, in your own browser)

Do this on your phone or laptop, signed into your Google account.

1. **Create the project**
   - Go to **https://console.firebase.google.com**
   - Click **Create a project** (or **Add project**).
   - Name it `community-rashan` → Continue.
   - You can turn **Google Analytics OFF** (not needed) → Create project → wait → Continue.

2. **Turn on Google sign-in**
   - Left menu → **Build → Authentication → Get started**.
   - Open the **Sign-in method** tab → click **Google** → toggle **Enable** →
     pick your email as support email → **Save**.

3. **Turn on the database**
   - Left menu → **Build → Firestore Database → Create database**.
   - Choose **Start in test mode** (fine for now) → pick a location near you
     (e.g. `asia-south1` Mumbai) → **Enable**.

4. **Register an app and copy the config**
   - On the project home (click the ⚙️ **gear → Project settings**), scroll to
     **Your apps** → click the **Web** icon `</>`.
   - Nickname `community-rashan-web` → **Register app**.
   - Firebase shows a code box with `const firebaseConfig = { ... }`. Copy the
     **5 values** inside it and send them to me:

   ```
   apiKey:            "AIza........"
   appId:             "1:1234567890:web:abcdef...."
   messagingSenderId: "1234567890"
   projectId:         "community-rashan-xxxx"
   storageBucket:     "community-rashan-xxxx.appspot.com"
   ```

That's it. **Paste me those 5 lines.**

---

## Part 2 — what I do (no action from you)

- Put your values into `app/lib/firebase_options.dart`.
- The app then switches itself from offline/sample mode to **real Firebase**:
  Google login at launch, and the grocery catalogue loaded from Firestore
  (I seed the sample items on first run).
- I verify it compiles and hand you the updated app.

## Part 3 — later, for the installable Android app

Running on a real Android build also needs:
- `google-services.json` (downloaded from the same Project settings → Android app), and
- your app's **SHA-1** fingerprint added in Firebase (so Google sign-in works on Android).

I'll give you those exact steps when we package the Android build. For now the
web/preview build and the code are fully wired.

## Notes

- The 5 values above are **not secrets** — Firebase web config is meant to be
  public; security comes from Firestore rules + Auth, not from hiding these.
- Before real users, tighten Firestore from "test mode" to proper rules. I'll
  write those (`firestore.rules`) when we go past the pilot.

# Prompt for Claude Cowork — set up the A2Z Notes 3.0.0 listing in App Store Connect

Copy everything below the line into Claude Cowork. Have the repo folder
(`Alphabetical-List-App`) added to the Cowork session so it can read the files it references,
and be signed in to App Store Connect in the browser before you start.

---

I need you to prepare the App Store Connect listing for my iOS app **A2Z Notes**
(bundle id `com.nathanfennel.A2Z`, version 3.0.0, build 3000). I am already signed in to
App Store Connect. Everything you need to paste is in `APP_STORE_CONNECT.md` in this folder —
treat that file as the single source of truth for field values; don't rewrite the copy.

Do the following, in order, and check with me before anything that submits or publishes:

1. **Create the new version.** In My Apps → A2Z Notes, add version **3.0.0** (it was 2.3.3).

2. **App Information.** Set subtitle, primary category (Productivity) and secondary
   (Utilities) from §1 of the doc.

3. **Version metadata.** Paste in the promotional text, description, keywords and
   "What's New" exactly as given in the paste-ready blocks of §1. Set the support URL and
   marketing URL from the doc's URLs section.

4. **Screenshots.** Upload from `Graphics/AppStore/marketing/`:
   - iPhone 6.9": the 10 files I've picked from `marketing/iphone/` — if I haven't told you
     a selection yet, ask me before uploading; there are 15 candidates and only 10 slots.
   - iPad 13": same from `marketing/ipad/`.
   Do NOT upload anything from `marketing/mac/` (website use only) or from `raw/` unless I
   say otherwise. Keep the upload order matching the file numbering.

5. **Age rating questionnaire.** Answer per §5 of the doc (everything "None"; 4+).

6. **App Privacy.** Confirm it's set to "Data Not Collected" as described in the doc's
   privacy section; update the privacy policy URL if it differs.

7. **Review notes.** Paste the review-notes block from §3 into App Review Information. No
   demo account is needed (no login in the app).

8. **Build.** If build 3000 has been uploaded from Xcode it will appear under Builds —
   attach it. If no build is available yet, skip and tell me; do not try to upload a binary
   yourself.

9. **Pricing.** Leave the existing price tier untouched.

10. **Stop before submitting.** When every section shows complete, give me a checklist of
    what's set and anything still missing (e.g., build not uploaded, screenshot slots I
    haven't chosen). **Do not press "Submit for Review"** — I'll do that myself after a
    final look.

If any field the doc references doesn't exist in the current ASC UI, or a value gets
rejected (length limits, etc.), tell me rather than improvising new copy.

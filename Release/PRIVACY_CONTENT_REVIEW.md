# AtoZ Notes 3.0.0 (3002)

This snapshot preserves the prepared native redesign and rich note storage.
Build 3001 must not be used: its favicon helper could construct domains from
arbitrary note titles, despite a comment claiming only bundled domains were sent.
Build 3002 separates a fixed outbound domain allowlist from legacy local image
keys. Unknown titles use the existing local fallback. Existing online-icon
preferences/defaults are preserved, with a direct per-note switch and disclosure.
The callback respects a changed choice or custom icon before saving its result.

Public-content requests use an ephemeral session without cookies, saved
credentials or a disk response cache. This does not prevent provider IP/request
logging. The Bible request is a fixed verse-of-the-day URL with plain-text output.
Its response is validated; empty notes receive their first verse; existing rich
text is preserved; duplicate valid verses still update the last-fetch date.
NET attribution, source links and copyright credits are included with new verses.
A privacy/source notice is available from each note's settings. An empty iCloud
note title is ignored, and query observation begins before querying.

Run `sh Tests/ServicePrivacyChecks/run.sh` for Foundation checks of outbound
allowlisting, isolated networking configuration, empty/duplicate verse insertion
and malformed provider payloads. No native UI execution is claimed by these tests.

App Store privacy cannot be Data Not Collected: Bible.org documents retained
request URLs/IP addresses, and Google's policy describes request logging,
analytics and IP-derived general location. Current provider policies do not give
S2/Labs-specific retention periods. No raw note text is sent by build 3002's
content requests; no app accounts, IDFA, app analytics SDK or ad SDK are present.
Apple-only framework collection is not automatically developer collection.
The workspace report records exact recommended labels and remaining uncertainty.

Content Rights is not ready for an unconditional assertion. NET requires linked
attribution; its free-app permission differs from commercial publication terms.
Current AtoZ price/license evidence is not available in the release ledger. A
favicon response is not itself a grant to reuse each third-party logo. Preserve
the useful features while establishing the applicable permission/legal basis;
do not infer rights from a successful HTTP response or merely adding credits.

Primary sources:
- https://developer.apple.com/app-store/app-privacy-details/
- https://bible.org/article/privacy-policy-and-terms-use
- https://labs.bible.org/api_web_service
- https://netbible.com/copyright/
- https://policies.google.com/privacy
- https://policies.google.com/technologies/retention
- https://policies.google.com/terms

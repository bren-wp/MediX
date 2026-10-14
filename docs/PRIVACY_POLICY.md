# MediX Privacy Policy

**Effective date:** 14 October 2026  
**App:** MediX for Android (`com.brendigo.medix`)  
**Developer:** Brendigo, Rijeka, Croatia  
**Privacy contact:** info@brendigo.com

This policy describes how the MediX mobile app handles data. It applies to MediX specifically; Brendigo's general website privacy policy covers other services separately.

## What MediX stores

MediX can store the following information **on your Android device**:

- Medication IDs you mark as favorites or have recently viewed.
- Therapy-plan entries you choose to create: medication ID, dose description, selected weekdays, reminder times, and active/paused status.
- Your preferred interface language and whether you completed onboarding.
- Local scheduled notification information needed to show the reminders you requested.

Because therapy entries can reveal health information, treat your device and any exported documents as sensitive. MediX does not require an account, name, email address, or diagnosis to use its core functions.

MediX uses Android app-private storage and SharedPreferences for local settings and therapy entries. **The current app does not implement a separate application-layer encryption system for those entries.** Android backup of MediX application data is disabled.

## Network access and third parties

The medication catalog is bundled for offline use. The app does not upload therapy plans, favorites, or diagnoses to a MediX account or cloud service. The codebase does not include a third-party analytics or advertising SDK.

If you choose to open a public website, product source, or nearby-pharmacy search, an external web browser or mapping application handles that request under its own privacy policy. Your device/network may disclose ordinary connection data to that external provider. MediX does not attach your saved therapy plan to those links.

## Notifications

MediX requests notification and alarm permissions only for the local reminder feature. You can decline the permission and still use the medicine catalog and therapy planner. You can pause a plan or change notification permissions using Android settings.

## Exports and user-directed sharing

When you choose **Export my MediX data**, MediX generates a ZIP file containing PDF summaries of saved therapy, favorites, and app information. The archive is prepared in an app-specific temporary export folder, not automatically uploaded.

The Android share sheet allows **you** to choose a receiving application. That recipient may copy, store, sync or transmit the file under its own terms. Share sensitive exports only with recipients you trust.

Old MediX export ZIP archives more than 24 hours old are removed **when another export is created**, and Android may clear cached files independently. Do not interpret this as automatic deletion exactly 24 hours after creation.

## Retention and your choices

Favorites, recent items and therapy entries remain locally until you remove or change them or uninstall the app. You may remove individual therapy entries and favorites in the app. Uninstalling the app normally removes its app-private data, subject to Android/device-management behavior and any exports you deliberately shared or copied elsewhere.

If you shared an export into another app, you must use that receiving app's controls to delete its copies.

## Security

MediX restricts Android FileProvider access to its dedicated export cache folder, rejects non-HTTPS website links through its Android navigation bridge, and disables Android's application backup. No system can guarantee absolute security, especially on a compromised or unlocked device.

## Children, changes, and questions

MediX is a medical-information and therapy-planning aid, not a substitute for professional medical judgment. Guardians should supervise its use by children.

We may update this policy as the product changes and will revise the date above. For questions about the app or privacy, contact **info@brendigo.com**.

The applicable privacy and data-protection laws, including GDPR where relevant, continue to apply. This document does not replace any required Play Console disclosures or legal assessment.

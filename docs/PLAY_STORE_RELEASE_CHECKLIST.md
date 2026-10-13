# MediX Google Play Release Checklist

Production checklist for the Android package `com.brendigo.medix`.

## Build baseline

- [x] Target Android 16 / API 36.
- [x] Build Android App Bundle (AAB).
- [x] Analyze and test before the production bundle.
- [x] Verify the AAB signature.
- [x] Keep the private upload keystore outside the repository.
- [ ] Configure the four production signing secrets in GitHub before running the Google Play workflow.
- [ ] Upload the resulting signed AAB to Play Console and review Play's automated device / 16 KB page-size checks.

Required secrets:

- `MEDIX_UPLOAD_KEYSTORE_BASE64`
- `MEDIX_UPLOAD_KEY_ALIAS`
- `MEDIX_UPLOAD_KEY_PASSWORD`
- `MEDIX_UPLOAD_STORE_PASSWORD`

## Health app policy

- [ ] Complete the Health apps declaration in Play Console.
- [ ] Select the accurate health feature categories for MediX.
- [x] In-app medical disclaimer states that MediX is not a medical device and does not diagnose, treat, cure or prevent medical conditions.
- [x] In-app guidance tells users to consult a qualified healthcare professional.
- [ ] Include the same medical disclaimer in the Google Play store description.

## Privacy and Data safety

- [x] In-app privacy section is available without an account.
- [x] Public privacy policy: https://brendigo.com/politika-privatnosti/
- [x] Terms of use: https://brendigo.com/uvjeti-koristenja/
- [x] Cleartext Android traffic disabled.
- [x] Android cloud backup disabled for local therapy state.
- [x] Export uses app cache + FileProvider instead of broad storage access.
- [ ] Complete Play Console Data safety declarations to match the shipping app exactly.
- [ ] Re-check notification/alarm permission declarations in Play Console before production rollout.

## Store listing

- [ ] Complete content rating questionnaire.
- [ ] Upload current screenshots captured from the actual production build.
- [ ] Verify app name, short description and full description in every published store locale.
- [ ] Confirm support/contact details and privacy policy URL.
- [ ] Review tablet/large-screen presentation before broad rollout.

## Release gate

Do not promote a bundle to production until:

1. CI is green.
2. Release APK/AAB build is green.
3. Google Play production AAB workflow is green with the private upload key.
4. Play Console policy declarations are complete.
5. Automated Play pre-launch checks show no release-blocking findings.

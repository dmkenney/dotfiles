# Paramount+ looked soft in Brave (2026-10-25)

UFC on Paramount+ in Brave did not look HD. The player has no quality menu.

## Result

- Installed [Paramount Quality+](https://chromewebstore.google.com/detail/paramount-quality+/jdhjjddhdmhphkfgcfclekdngihnoann)
  (Chrome Web Store, works in Brave; source
  [Chaseos/ParamountQualityPlus](https://github.com/Chaseos/ParamountQualityPlus)).
  Its popup shows the active resolution, bitrate and the quality ladder.
  Turn on **Force Max Quality**, then refresh.
- First try did nothing; the extension was not in any Brave profile.
  Reinstalled into `Default` and turned Shields off for `paramountplus.com`.
  After that, playback went up to 1080p and looked better. Not tested which
  of the two steps fixed it.
- 1080p is the top of the ladder offered to Brave on Linux. 4K needs hardware
  Widevine (L1), which Linux browsers do not have. No extension changes that.
- Paramount+ says 4K is on "select titles" only. Not confirmed whether UFC is
  one of them. To check: play a fight in the app on a 4K TV or streaming
  device, Premium plan.

## Notes

- Brave already allowed location for Paramount+. The extension's README says
  blocked location can hide the quality ladder.
- No Paramount+ equivalent of the Netflix ChromeOS user-agent trick was found.

# Page snapshot

```yaml
- banner:
  - heading "Ethereum Login App" [level=1]
  - text: Not authenticated
- main:
  - heading "Scan QR Code" [level=2]
  - paragraph: Scan this QR code with your Ethereum wallet to login
  - img
  - paragraph: "Or copy the deep link:"
  - code: login://ethereum-login-app.com?aleatorio=0xf5a749b177599aeb7c3a1f95965abe0859a4a79a212b680b134df619058a87fa&timestamp=1754938693&address=0x09b3B85479A6Ec06072D67E904BA91c1ccca3Bc5&signature=0x6aaa57884e1bfed9feba58434d961d831bd64277988372d06cbe0503d96750b119a9263fcd5747af25b35dc24b6e0cf8a4f11d3f136622297f372fe405e180ea1b
  - code: xcrun simctl openurl booted "login://ethereum-login-app.com?aleatorio=0xf5a749b177599aeb7c3a1f95965abe0859a4a79a212b680b134df619058a87fa&timestamp=1754938693&address=0x09b3B85479A6Ec06072D67E904BA91c1ccca3Bc5&signature=0x6aaa57884e1bfed9feba58434d961d831bd64277988372d06cbe0503d96750b119a9263fcd5747af25b35dc24b6e0cf8a4f11d3f136622297f372fe405e180ea1b"
  - button "Cancel"
  - text: Waiting for wallet signature...
- alert
```
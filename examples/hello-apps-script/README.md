# Hello Apps Script example

This is a minimal Apps Script source example for testing a Codex-managed clasp workflow.

It intentionally does not include `.clasp.json` because this public repository should not be bound to a real Apps Script project ID.

## Files

```text
Code.js
appsscript.json
```

## Function

```javascript
function helloCodex() {
  console.log('Hello from Codex-managed Apps Script.');
  return 'Hello from Codex-managed Apps Script.';
}
```

## Usage pattern

Create or clone a real Apps Script project with clasp, then copy these files into that bound project folder.

Example:

```powershell
npx -y @google/clasp create-script --title codex-hello-script --rootDir codex-hello-script
Copy-Item .\examples\hello-apps-script\Code.js .\codex-hello-script\Code.js -Force
Copy-Item .\examples\hello-apps-script\appsscript.json .\codex-hello-script\appsscript.json -Force
Set-Location .\codex-hello-script
npx -y @google/clasp push
npx -y @google/clasp run-function helloCodex
```

If the run command requires authorization, complete the Google authorization flow and retry.

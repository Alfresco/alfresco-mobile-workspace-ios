# PDF.js based viewer

Current version is loaded as one file in the app via `loadHTMLString:baseURL:` and requires all resources are inlined.

**Do not** edit `viewer-inline.html` directly.

Edit files indepenedetly and use `inline.sh` to update the `viewer-inline.html` file.

`inline.sh` requires [html-inline](https://www.npmjs.com/package/html-inline) from npm to be installed.

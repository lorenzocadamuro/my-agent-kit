# Third-party material

## AminBlg/SimpleEnglish

`output-styles/STE.md` is an adapted copy of the rules in AminBlg/SimpleEnglish.

- Source: https://github.com/AminBlg/SimpleEnglish, file `prompts/system-prompt.md`, commit `32ea2d3f4404bfbff162c1861e5ae4f1bcc628b3`.
- License: MIT, reproduced below.

What was changed:

- The rules cover the texts written for the person to read, as the style's scope sentence lists them. Commit messages are not covered.
- The document rules ("THE DOCUMENT") apply to every text the scope covers. Each sentence is written directly in the allowed form, in one pass.
- The self-check ("SELF-CHECK") is not a second pass. Its search list became forms to avoid.
- The reply rules ("THE REPLY") were removed: the bans on headers, bullet lists, bold and tables, and the five-sentence limit. Lists, tables and code blocks are allowed when they help. The ban on openers and closers stays.
- The bans on bold lead-ins and on bold as emphasis were removed.
- The content rules were removed: the first sentence that gives the result, the definitions of terms, the name of the host, flag or prior step, and the ban on restating the question.
- The word-budget version (~60 tokens) was removed.
- Strict mode keeps the dictionary swaps and the statement that no tool guarantees compliance.
- The style says that it is in the spirit of ASD-STE100, not the official standard, and not certified by ASD.

ASD-STE100 is a registered trademark of ASD.

### License

```text
MIT License

Copyright (c) 2026 AminBlg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
